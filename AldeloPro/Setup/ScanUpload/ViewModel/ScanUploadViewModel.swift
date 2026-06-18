//
//  ScanUploadViewModel.swift
//  AldeloPro
//
//  Created by wanghui on 2026/06/05.
//

import Foundation
import UIKit
import AVFoundation
import UniformTypeIdentifiers

// MARK: - Tab State

enum ScanUploadTab: Equatable {
    case scan
    case uploadFile
}

// MARK: - Upload State

enum UploadFileState: Equatable {
    case idle
    case loading(progress: Double, fileName: String)
    case preview
}

// MARK: - Alert Type

enum ScanUploadAlertType: Equatable {
    case fileSizeExceeded
    case fileCountExceeded
}

// MARK: - Uploaded File

struct UploadedFile: Identifiable, Equatable {
    let id: UUID = UUID()
    let url: URL
    let fileName: String
    let fileSize: Int64
    let fileExtension: String

    var isExcel: Bool {
        ["xlsx", "xls"].contains(fileExtension.lowercased())
    }

    var isCSV: Bool {
        fileExtension.lowercased() == "csv"
    }

    var isPDF: Bool {
        fileExtension.lowercased() == "pdf"
    }

    var isWord: Bool {
        ["doc", "docx"].contains(fileExtension.lowercased())
    }

    var isImage: Bool {
        ["png", "jpg", "jpeg"].contains(fileExtension.lowercased())
    }
}

// MARK: - ViewModel

@Observable
@MainActor
final class ScanUploadViewModel {

    // MARK: - Constants

    static let maxTotalFileSize: Int64 = 10 * 1024 * 1024 // 10MB
    static let maxFileCount = 5

    // MARK: - Tab

    var selectedTab: ScanUploadTab = .scan

    // MARK: - Scan State

    var scannedImages: [ScannedPage] = []
    var isCameraActive = false

    // MARK: - Upload State

    var uploadFileState: UploadFileState = .idle
    var uploadedFiles: [UploadedFile] = []
    var showDocumentPicker = false
    var showPhotoPicker = false
    var showUploadOptions = false

    // MARK: - Alert

    var showPermissionAlert = false
    var alertType: ScanUploadAlertType?

    // MARK: - Camera

    let cameraManager = CameraSessionManager()

    // MARK: - Computed

    var hasScannedPages: Bool {
        scannedImages.isEmpty == false
    }

    var pageCount: Int {
        scannedImages.count
    }

    var selectedFileId: UUID?

    var hasUploadedFiles: Bool {
        uploadedFiles.isEmpty == false
    }

    var selectedFile: UploadedFile? {
        if let id = selectedFileId {
            return uploadedFiles.first(where: { $0.id == id })
        }
        return uploadedFiles.last
    }

    var totalUploadedSize: Int64 {
        uploadedFiles.reduce(0) { $0 + $1.fileSize }
    }

    var hasCameraPermission: Bool {
        AVCaptureDevice.authorizationStatus(for: .video) == .authorized
    }

    // MARK: - Supported File Types

    static var supportedContentTypes: [UTType] {
        [
            .spreadsheet,
            .commaSeparatedText,
            .pdf,
            UTType("com.microsoft.word.doc") ?? .data,
            UTType("org.openxmlformats.wordprocessingml.document") ?? .data,
            .png,
            .jpeg
        ]
    }

    // MARK: - Tab Switching

    func switchToTab(_ tab: ScanUploadTab) {
        if tab == .scan {
            let status = AVCaptureDevice.authorizationStatus(for: .video)
            if status == .denied || status == .restricted {
                showPermissionAlert = true
                return
            }
            if status == .notDetermined {
                AVCaptureDevice.requestAccess(for: .video) { granted in
                    Task { @MainActor [weak self] in
                        if granted {
                            self?.selectedTab = .scan
                            self?.resumeCamera()
                        } else {
                            self?.showPermissionAlert = true
                        }
                    }
                }
                return
            }
            // authorized
            selectedTab = .scan
            resumeCamera()
        } else {
            selectedTab = .uploadFile
            pauseCamera()
        }
    }

    // MARK: - Camera Permission & Launch

    func launchCameraDirectly() {
        startCamera()
    }

    private func startCamera() {
        cameraManager.configureSession()
        cameraManager.startSession()
        isCameraActive = true
    }

    func stopCamera() {
        cameraManager.stopSession()
        isCameraActive = false
    }

    func pauseCamera() {
        if isCameraActive {
            cameraManager.stopSession()
            isCameraActive = false
        }
    }

    func resumeCamera() {
        if selectedTab == .scan && hasCameraPermission {
            cameraManager.startSession()
            isCameraActive = true
        }
    }

    func capturePhoto() {
        cameraManager.capturePhoto { [weak self] image in
            Task { @MainActor in
                self?.addScannedPages([image])
            }
        }
    }

    // MARK: - Scan Actions

    func addScannedPages(_ images: [UIImage]) {
        var newPages: [ScannedPage] = []
        for img in images {
            newPages.append(ScannedPage(image: img))
        }
        scannedImages.append(contentsOf: newPages)
    }

    func removePageById(_ id: UUID) {
        scannedImages.removeAll(where: { page in page.id == id })
    }

    // MARK: - File Upload Actions

    func addFiles(urls: [URL]) {
        for url in urls {
            guard url.startAccessingSecurityScopedResource() else { continue }
            defer { url.stopAccessingSecurityScopedResource() }

            let fileName = url.lastPathComponent
            let ext = url.pathExtension

            guard let attrs = try? FileManager.default.attributesOfItem(atPath: url.path),
                  let size = attrs[.size] as? Int64 else { continue }

            // Check count limit
            if uploadedFiles.count >= Self.maxFileCount {
                alertType = .fileCountExceeded
                return
            }

            // Check size limit
            if totalUploadedSize + size > Self.maxTotalFileSize {
                alertType = .fileSizeExceeded
                return
            }

            // Copy to temp for persistence
            let tempDir = FileManager.default.temporaryDirectory
            let destURL = tempDir.appendingPathComponent(UUID().uuidString + "." + ext)
            do {
                try FileManager.default.copyItem(at: url, to: destURL)
            } catch {
                continue
            }

            let file = UploadedFile(
                url: destURL,
                fileName: fileName,
                fileSize: size,
                fileExtension: ext
            )
            uploadedFiles.append(file)
        }

        if hasUploadedFiles {
            simulateUploadProgress()
        }
    }

    func removeFile(_ id: UUID) {
        if let file = uploadedFiles.first(where: { $0.id == id }) {
            try? FileManager.default.removeItem(at: file.url)
        }
        uploadedFiles.removeAll(where: { $0.id == id })
        if uploadedFiles.isEmpty {
            uploadFileState = .idle
        } else if let id = selectedFileId, uploadedFiles.firstIndex(where: { $0.id == id }) == nil {
            uploadFileState = .preview
            selectedFileId = uploadedFiles.last?.id
        }
    }

    func dismissAlert() {
        alertType = nil
    }

    // MARK: - Upload Simulation

    private func simulateUploadProgress() {
        let fileName = uploadedFiles.last?.fileName ?? "file"
        uploadFileState = .loading(progress: 0, fileName: fileName)

        Task {
            for i in 1...10 {
                try? await Task.sleep(nanoseconds: 100_000_000)
                uploadFileState = .loading(progress: Double(i) / 10.0, fileName: fileName)
            }
            uploadFileState = .preview
            selectedFileId = uploadedFiles.last?.id
        }
    }

    // MARK: - Photos Picker

    func addPhotoImages(_ images: [UIImage]) {
        for image in images {
            // Check count limit
            if uploadedFiles.count >= Self.maxFileCount {
                alertType = .fileCountExceeded
                return
            }

            // Save to temp
            let ext = "jpg"
            let fileName = "Photo_\(UUID().uuidString.prefix(8)).\(ext)"
            let tempDir = FileManager.default.temporaryDirectory
            let destURL = tempDir.appendingPathComponent(fileName)

            guard let jpegData = image.jpegData(compressionQuality: 0.85) else { continue }
            let size = Int64(jpegData.count)

            // Check size limit
            if totalUploadedSize + size > Self.maxTotalFileSize {
                alertType = .fileSizeExceeded
                return
            }

            do {
                try jpegData.write(to: destURL)
            } catch {
                continue
            }

            let file = UploadedFile(
                url: destURL,
                fileName: fileName,
                fileSize: size,
                fileExtension: ext
            )
            uploadedFiles.append(file)
        }

        if hasUploadedFiles {
            simulateUploadProgress()
        }
    }
}
