//
//  CameraSessionManager.swift
//  AldeloPro
//
//  Created by wanghui on 2026/06/09.
//

import AVFoundation
import UIKit

@Observable
@MainActor
final class CameraSessionManager: NSObject {

    // MARK: - State

    var isSessionRunning = false
    var capturedImage: UIImage?

    // MARK: - AVFoundation

    let captureSession = AVCaptureSession()
    private let photoOutput = AVCapturePhotoOutput()
    private let sessionQueue = DispatchQueue(label: "com.aldelo.camerasession.session")
    private var onPhotoCaptured: ((UIImage) -> Void)?

    // MARK: - Setup

    func configureSession() {
        guard captureSession.inputs.isEmpty else { return }

        captureSession.beginConfiguration()
        captureSession.sessionPreset = .photo

        guard let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
              let input = try? AVCaptureDeviceInput(device: camera)
        else {
            captureSession.commitConfiguration()
            return
        }

        if captureSession.canAddInput(input) {
            captureSession.addInput(input)
        }

        if captureSession.canAddOutput(photoOutput) {
            captureSession.addOutput(photoOutput)
        }

        captureSession.commitConfiguration()
    }

    func startSession() {
        guard captureSession.isRunning == false else { return }
        // AVCaptureSession 非 Sendable，用 nonisolated(unsafe) 显式跨队列传递；
        // 启停操作下沉到串行后台队列，标志位在主线程同步置位（与 ScanReceiptViewModel 同模式）。
        nonisolated(unsafe) let session = captureSession
        sessionQueue.async {
            session.startRunning()
        }
        isSessionRunning = true
    }

    func stopSession() {
        guard captureSession.isRunning else { return }
        nonisolated(unsafe) let session = captureSession
        sessionQueue.async {
            session.stopRunning()
        }
        isSessionRunning = false
    }

    // MARK: - Capture

    func capturePhoto(completion: @escaping (UIImage) -> Void) {
        onPhotoCaptured = completion
        // 拍照前把照片输出连接的旋转角对齐当前界面方向（预览连接已在
        // CameraPreviewRepresentable 中对齐）。否则横屏拍出的照片会被旋转 90°。
        if let connection = photoOutput.connection(with: .video),
           connection.isVideoRotationAngleSupported(currentRotationAngle) {
            connection.videoRotationAngle = currentRotationAngle
        }
        let settings = AVCapturePhotoSettings()
        photoOutput.capturePhoto(with: settings, delegate: self)
    }

    /// 当前界面方向对应的视频旋转角（与 CameraPreviewRepresentable 同一套映射）。
    private var currentRotationAngle: CGFloat {
        let orientation = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first { $0.activationState == .foregroundActive }?
            .interfaceOrientation ?? .portrait
        switch orientation {
        case .landscapeRight: return 0
        case .landscapeLeft: return 180
        case .portraitUpsideDown: return 270
        default: return 90 // .portrait 及未知
        }
    }
}

// MARK: - AVCapturePhotoCaptureDelegate

extension CameraSessionManager: AVCapturePhotoCaptureDelegate {

    nonisolated func photoOutput(
        _ output: AVCapturePhotoOutput,
        didFinishProcessingPhoto photo: AVCapturePhoto,
        error: Error?
    ) {
        guard error == nil,
              let data = photo.fileDataRepresentation(),
              let image = UIImage(data: data)
        else { return }

        // 把方向信息烘焙进像素，统一为 .up：下游 jpegData()/pngData() 编码后
        // 在不读 EXIF 的场景（缩略图、网络上传）也不会再被旋转。
        let normalized = image.normalizedUp()

        Task { @MainActor [weak self] in
            self?.capturedImage = normalized
            self?.onPhotoCaptured?(normalized)
            self?.onPhotoCaptured = nil
        }
    }
}

// MARK: - UIImage Orientation Normalization

extension UIImage {
    /// 返回方向为 `.up` 的等价图片：若已是 `.up` 直接返回自身，否则重绘一张把
    /// `imageOrientation` 烘焙进像素，避免下游编码丢失方向标记后被旋转。
    nonisolated func normalizedUp() -> UIImage {
        guard imageOrientation != .up else { return self }
        let format = UIGraphicsImageRendererFormat.default()
        format.scale = scale
        let renderer = UIGraphicsImageRenderer(size: size, format: format)
        return renderer.image { _ in
            draw(in: CGRect(origin: .zero, size: size))
        }
    }
}
