//
//  ScanUploadView.swift
//  AldeloPro
//
//  Created by wanghui on 2026/06/05.
//

import SwiftUI
import PhotosUI
import UniformTypeIdentifiers

struct ScanUploadView: View {

    // MARK: - Environment

    @Environment(\.dismiss) private var dismiss
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    // MARK: - State

    @State private var viewModel = ScanUploadViewModel()

    // MARK: - Properties

    var shouldLaunchCamera: Bool = true

    /// 弹窗标题（不同业务场景注入不同文案，默认为员工搭建场景）。
    var headerTitle: String = "Scan or Upload Employee"

    /// Scan 标签页底部对齐提示文案（默认为员工搭建场景）。
    var scanHint: String = "Please Align the Employee List for Scanning"

    // MARK: - Callbacks

    var onBack: (() -> Void)?
    var onNext: (([ScannedPage], [UploadedFile]) -> Void)?

    // MARK: - Computed

    private var isCompact: Bool {
        horizontalSizeClass == .compact
    }

    private var isCameraAvailable: Bool {
        #if targetEnvironment(simulator)
        return false
        #else
        return true
        #endif
    }

    // MARK: - Body

    var body: some View {
        GeometryReader { geo in
            ZStack {
                Color.black.opacity(0.4).ignoresSafeArea()

                if isCompact {
                    compactContent(width: geo.size.width)
                } else {
                    regularContent(width: geo.size.width)
                }

                // Permission alert overlay
                if viewModel.showPermissionAlert {
                    CameraPermissionAlertView(
                        onCancel: {
                            viewModel.showPermissionAlert = false
                        },
                        onGoToSettings: {
                            viewModel.showPermissionAlert = false
                            if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                                UIApplication.shared.open(settingsURL)
                            }
                        }
                    )
                }
            }
        }
        .task {
            // Determine default tab based on camera permission
            if shouldLaunchCamera && isCameraAvailable && viewModel.hasCameraPermission {
                viewModel.selectedTab = .scan
                try? await Task.sleep(nanoseconds: 500_000_000)
                viewModel.launchCameraDirectly()
            } else {
                viewModel.selectedTab = .uploadFile
            }
        }
        .onDisappear {
            viewModel.stopCamera()
        }
        .fileImporter(
            isPresented: $viewModel.showDocumentPicker,
            allowedContentTypes: ScanUploadViewModel.supportedContentTypes,
            allowsMultipleSelection: true
        ) { result in
            switch result {
            case .success(let urls):
                viewModel.addFiles(urls: urls)
            case .failure:
                break
            }
        }
        .autoDismissAlert(
            isPresented: alertPresented,
            title: "Upload disabled",
            message: currentAlertMessage
        )
    }

    // MARK: - Alert Binding

    private var alertPresented: Binding<Bool> {
        Binding(
            get: { viewModel.alertType != nil },
            set: { newValue in if newValue == false { viewModel.dismissAlert() } }
        )
    }

    private var currentAlertMessage: AttributedString {
        guard let type = viewModel.alertType else { return AttributedString("") }
        return alertMessage(for: type)
    }

    private func alertMessage(for type: ScanUploadAlertType) -> AttributedString {
        switch type {
        case .fileSizeExceeded:
            let result = AttributedString("Total file size exceeds ")
            var highlight = AttributedString("10M")
            highlight.foregroundColor = .red
            let dot = AttributedString(".")
            return result + highlight + dot
        case .fileCountExceeded:
            let result = AttributedString("Maximum ")
            var highlight = AttributedString("5 files")
            highlight.foregroundColor = .red
            let dot = AttributedString(" allowed.")
            return result + highlight + dot
        }
    }

    // MARK: - iPad Layout

    private func regularContent(width: CGFloat) -> some View {
        let modalWidth: CGFloat = 720

        return VStack(spacing: Spacing.md) {
            // Header
            headerSection

            // Tab bar
            tabBar
                .frame(height: 55)
                .padding(.horizontal, Spacing.lg)
            
            // Main content (flexible)
            VStack(spacing: Spacing.md) {
                // Content area (flexible height)
                mainContentArea
                    .frame(maxHeight: .infinity)

                // Hint text
                hintText

                // Thumbnail/file list area
                fileListSection(size: 80)
            }
            .padding(.horizontal, Spacing.lg)
            
            // Action button (Scan or Upload)
            actionButton(height: 55)
                .padding(.horizontal, Spacing.lg)

            // Bottom buttons
            bottomButtons(height: 55)
                .padding(.horizontal, Spacing.lg)
                .padding(.bottom, Spacing.md)
        }
        .frame(width: modalWidth)
        .background(AppColors.card)
        .cornerRadius(AppRadius.Tablet.md)
        .frame(maxWidth: .infinity)
    }

    // MARK: - iPhone Layout

    private func compactContent(width: CGFloat) -> some View {
        VStack(spacing: Spacing.md) {
            // Header
            compactHeaderSection

            // Tab bar
            tabBar
                .frame(height: 50)
                .padding(.horizontal, Spacing.md)

            // Main content (flexible)
            VStack(spacing: Spacing.md) {
                mainContentArea
                    .frame(maxHeight: .infinity)

                hintText

                fileListSection(size: 72)
            }
            .padding(.horizontal, Spacing.md)
            
            // Action button
            actionButton(height: 50)
                .padding(.horizontal, Spacing.md)
            
            // Bottom buttons
            bottomButtons(height: 50)
                .padding(.horizontal, Spacing.md)
                .padding(.bottom, Spacing.md)
        }
        .background(AppColors.card)
    }

    // MARK: - Tab Bar

    private var tabBar: some View {
        HStack(spacing: 0) {
            tabButton(title: "Scan", tab: .scan)
            tabButton(title: "Upload File", tab: .uploadFile)
        }
        .overlay(
            RoundedRectangle(cornerRadius: AppRadius.Tablet.sm)
                .stroke(AppColors.textTertiary, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.Tablet.sm))
    }

    private func tabButton(title: String, tab: ScanUploadTab) -> some View {
        let isSelected = viewModel.selectedTab == tab
        return Button {
            viewModel.switchToTab(tab)
        } label: {
            Text(title)
                .font(isCompact ? AppFont.mobileButton3Medium : AppFont.tabletButton3Medium)
                .foregroundColor(isSelected ? AppColors.primaryNormal : AppColors.textMuted)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(isSelected ? AppColors.pageBg : Color.clear)
                .cornerRadius(AppRadius.Tablet.sm)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    // MARK: - Main Content Area

    @ViewBuilder
    private var mainContentArea: some View {
        switch viewModel.selectedTab {
        case .scan:
            scanContentArea
        case .uploadFile:
            uploadContentArea
        }
    }

    // MARK: - Scan Content

    @ViewBuilder
    private var scanContentArea: some View {
        if viewModel.isCameraActive {
            CameraPreviewRepresentable(session: viewModel.cameraManager.captureSession)
                .clipShape(RoundedRectangle(cornerRadius: AppRadius.Tablet.md))
                .overlay(alignment: .topLeading) {
                    cornerMark(rotation: 0).offset(x: -4, y: -4)
                }
                .overlay(alignment: .topTrailing) {
                    cornerMark(rotation: 90).offset(x: 4, y: -4)
                }
                .overlay(alignment: .bottomLeading) {
                    cornerMark(rotation: 270).offset(x: -4, y: 4)
                }
                .overlay(alignment: .bottomTrailing) {
                    cornerMark(rotation: 180).offset(x: 4, y: 4)
                }
        } else if let lastPage = viewModel.scannedImages.last {
            Image(uiImage: lastPage.image)
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .cornerRadius(AppRadius.Tablet.md)
                .overlay(
                    RoundedRectangle(cornerRadius: AppRadius.Tablet.md)
                        .stroke(AppColors.primaryNormal, lineWidth: 2)
                )
        } else {
            scanPlaceholder
        }
    }

    private func cornerMark(rotation: Double) -> some View {
        CornerMarkShape()
            .stroke(AppColors.primaryNormal, lineWidth: 3)
            .frame(width: 24, height: 24)
            .rotationEffect(.degrees(rotation))
            .padding(4)
    }

    private struct CornerMarkShape: Shape {
        func path(in rect: CGRect) -> Path {
            var path = Path()
            path.move(to: CGPoint(x: rect.minX, y: rect.maxY))
            path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
            return path
        }
    }
    
    // MARK: - Upload Content

    @ViewBuilder
    private var uploadContentArea: some View {
        switch viewModel.uploadFileState {
        case .idle:
            uploadPlaceholder
        case .loading(let progress, let fileName):
            FileUploadLoadingView(progress: progress, fileName: fileName)
        case .preview:
            uploadPreviewArea
        }
    }

    private var uploadPlaceholder: some View {
        VStack(spacing: Spacing.lg) {
            // Upload icon
            VStack(spacing: 0) {
                Image(systemName: "tray.and.arrow.up")
                    .font(.system(size: 60))
                    .foregroundColor(AppColors.line)
            }
            .padding(.bottom, Spacing.md)

            Text("Please upload file")
                .font(AppFont.tabletBody2Regular)
                .foregroundColor(AppColors.textTertiary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppColors.buttonSecondaryBg)
        .cornerRadius(AppRadius.Tablet.md)
    }

    @ViewBuilder
    private var uploadPreviewArea: some View {
        if let file = viewModel.selectedFile {
            filePreviewContent(file: file)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(AppColors.buttonSecondaryBg)
                .cornerRadius(AppRadius.Tablet.md)
        } else {
            uploadPlaceholder
        }
    }

    private func filePreviewContent(file: UploadedFile) -> some View {
        Group {
            if file.isImage, let image = UIImage(contentsOfFile: file.url.path) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .cornerRadius(AppRadius.Tablet.md)
                    .padding(Spacing.xxs)
            } else {
                DocumentWebPreviewView(fileURL: file.url)
                    .cornerRadius(AppRadius.Tablet.md)
                    .padding(Spacing.xxs)
            }
        }
    }


    // MARK: - Scan Placeholder

    private var scanPlaceholder: some View {
        VStack(spacing: Spacing.md) {
            ForEach(0..<6, id: \.self) { _ in
                HStack(spacing: Spacing.sm) {
                    ForEach(0..<4, id: \.self) { _ in
                        RoundedRectangle(cornerRadius: 2)
                            .fill(AppColors.line)
                            .frame(height: 12)
                    }
                }
            }
        }
        .padding(Spacing.xxxl)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            Color(red: 0.569, green: 0.651, blue: 0.761).opacity(0.15)
        )
        .cornerRadius(AppRadius.Tablet.md)
    }

    // MARK: - Hint Text

    private var hintText: some View {
        HStack(spacing: Spacing.xxs) {
            Image(systemName: "info.circle")
                .font(isCompact ? AppFont.mobileBody2Regular : AppFont.tabletBody4Regular)
                .foregroundColor(AppColors.primaryNormal)

            Group {
                if viewModel.selectedTab == .scan {
                    Text(scanHint)
                } else {
                    Text("Supported formats: Excel, CSV, PDF, Word, PNG, JPG. Only same format allowed.")
                }
            }
            .font(isCompact ? AppFont.mobileBody2Regular : AppFont.tabletBody4Regular)
            .foregroundColor(AppColors.textTertiary)
            
            Spacer(minLength: 0)
        }
    }

    // MARK: - File List Section

    private func fileListSection(size: CGFloat) -> some View {
        Group {
            if viewModel.selectedTab == .scan {
                scanThumbnailSection(size: size)
            } else {
                uploadThumbnailSection(size: size)
            }
        }
    }

    private func scanThumbnailSection(size: CGFloat) -> some View {
        Group {
            if viewModel.hasScannedPages {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: Spacing.md) {
                        ForEach(viewModel.scannedImages) { page in
                            scanThumbnailItem(page: page, size: size)
                        }
                    }
                    .padding(.trailing, Spacing.sm)
                }
                .frame(height: size)
            } else {
                Color.clear
                    .frame(height: size)
            }
        }
    }

    private func uploadThumbnailSection(size: CGFloat) -> some View {
        Group {
            if viewModel.hasUploadedFiles {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: Spacing.md) {
                        ForEach(viewModel.uploadedFiles) { file in
                            uploadThumbnailItem(file: file, size: size)
                        }
                    }
                    .padding(.trailing, Spacing.sm)
                }
                .frame(height: size + 20) // extra for filename
            } else {
                Color.clear
                    .frame(height: size + 20)
            }
        }
    }

    // MARK: - Scan Thumbnail Item

    private func scanThumbnailItem(page: ScannedPage, size: CGFloat) -> some View {
        ZStack(alignment: .topTrailing) {
            Image(uiImage: page.image)
                .resizable()
                .scaledToFill()
                .frame(width: size, height: size)
                .clipShape(RoundedRectangle(cornerRadius: AppRadius.Tablet.xs))
                .overlay(
                    RoundedRectangle(cornerRadius: AppRadius.Tablet.xs)
                        .stroke(AppColors.line, lineWidth: 1)
                )
                .padding(.top, Spacing.xs)
                .padding(.trailing, Spacing.xs)

            Button {
                viewModel.removePageById(page.id)
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: 20, height: 20)
                    .background(Color(red: 0.31, green: 0.33, blue: 0.36).opacity(0.7))
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)
        }
    }

    // MARK: - Upload Thumbnail Item

    private func uploadThumbnailItem(file: UploadedFile, size: CGFloat) -> some View {
        VStack(spacing: Spacing.xs) {
            ZStack(alignment: .topTrailing) {
                Group {
                    if file.isImage, let image = UIImage(contentsOfFile: file.url.path) {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                    } else {
                        Image(fileIconName(for: file))
                            .resizable()
                            .scaledToFit()
                            .frame(width: size * 0.5, height: size * 0.5)
                    }
                }
                .frame(width: size, height: size)
                .background(AppColors.card)
                .clipShape(RoundedRectangle(cornerRadius: AppRadius.Tablet.xs))
                .overlay(
                    RoundedRectangle(cornerRadius: AppRadius.Tablet.xs)
                        .stroke(viewModel.selectedFileId == file.id ? AppColors.primaryNormal : AppColors.line, lineWidth: viewModel.selectedFileId == file.id ? 2 : 1)
                )
                .padding(.top, Spacing.xs)
                .padding(.trailing, Spacing.xs)

                Button {
                    viewModel.removeFile(file.id)
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.white)
                        .frame(width: 20, height: 20)
                        .background(Color(red: 0.31, green: 0.33, blue: 0.36).opacity(0.5))
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)
            }

            Text(file.fileName)
                .font(isCompact ? AppFont.mobileCaption1Regular : AppFont.tabletCaption2Regular)
                .foregroundColor(viewModel.selectedFileId == file.id ? AppColors.primaryNormal : AppColors.textTertiary)
                .lineLimit(1)
                .frame(width: size)
        }
        .onTapGesture {
            viewModel.selectedFileId = file.id
        }
    }

    // MARK: - File Icon Name

    private func fileIconName(for file: UploadedFile) -> String {
        if file.isExcel { return "exl" }
        if file.isCSV { return "csv" }
        if file.isPDF { return "pdf" }
        if file.isWord { return "doc" }
        return "doc"
    }

    // MARK: - Action Button

    private func actionButton(height: CGFloat) -> some View {
        Button {
            if viewModel.selectedTab == .scan {
                viewModel.capturePhoto()
            } else {
                viewModel.showDocumentPicker = true
            }
        } label: {
            HStack(spacing: Spacing.sm) {
                if viewModel.selectedTab == .scan {
                    cameraIcon
                    Text("Scan")
                        .font(isCompact ? AppFont.mobileButton3Medium : AppFont.tabletButton3Medium)
                        .foregroundColor(AppColors.textPrimary)
                } else {
                    uploadFolderIcon
                    Text("Upload")
                        .font(isCompact ? AppFont.mobileButton3Medium : AppFont.tabletButton3Medium)
                        .foregroundColor(AppColors.textPrimary)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: height)
            .overlay(
                RoundedRectangle(cornerRadius: AppRadius.Tablet.md)
                    .stroke(AppColors.line, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Icons

    private var cameraIcon: some View {
        Image(systemName: "camera.fill")
            .font(.system(size: 20))
            .foregroundColor(AppColors.textPrimary)
    }

    private var uploadFolderIcon: some View {
        Image(systemName: "folder.fill")
            .font(.system(size: 20))
            .foregroundColor(AppColors.textPrimary)
    }

    // MARK: - Bottom Buttons

    private func bottomButtons(height: CGFloat) -> some View {
        HStack(spacing: Spacing.md) {
            Button {
                onBack?()
                dismiss()
            } label: {
                Text("Back")
                    .font(isCompact ? AppFont.mobileButton3Medium : AppFont.tabletButton3Medium)
                    .foregroundColor(AppColors.textPrimary)
                    .frame(maxWidth: .infinity)
                    .frame(height: height)
                    .background(AppColors.buttonSecondaryBg)
                    .cornerRadius(AppRadius.Tablet.md)
            }
            .buttonStyle(.plain)

            Button {
                onNext?(viewModel.scannedImages, viewModel.uploadedFiles)
                dismiss()
            } label: {
                Text("Next")
                    .font(isCompact ? AppFont.mobileButton3Medium : AppFont.tabletButton3Medium)
                    .foregroundColor(AppColors.buttonPrimaryText)
                    .frame(maxWidth: .infinity)
                    .frame(height: height)
                    .background(AppColors.buttonPrimaryBg)
                    .cornerRadius(AppRadius.Tablet.md)
            }
            .buttonStyle(.plain)
        }
    }

    // MARK: - Header (iPad)

    private var headerSection: some View {
        HStack {
            Text(headerTitle)
                .font(AppFont.tabletH1Medium)
                .foregroundColor(AppColors.textPrimary)
            Spacer()
        }
        .padding(.horizontal, Spacing.lg)
        .padding(.top, Spacing.md)
    }

    // MARK: - Header (iPhone)

    private var compactHeaderSection: some View {
        HStack {
            Text(headerTitle)
                .font(AppFont.mobileH2Medium)
                .foregroundColor(AppColors.textPrimary)
            Spacer()
            Button {
                onBack?()
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(AppColors.textPrimary)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, Spacing.md)
        .padding(.top, Spacing.md)
    }
}

#Preview {
    ScanUploadView()
}
