//
//  UploadItemImageView.swift
//  AldeloPro
//
//  Created by jiangxia on 2026/06/11.
//

import SwiftUI

/// "Upload Item Image" 弹窗：顶部内嵌实时取景（取景/相册选图阶段无裁切框）；
/// "Take Product Photo" 为快门，拍后进入静态预览，叠加 16:9 蓝色四角裁切框；
/// "Upload From Album" 每次选一张。可勾 "Use As Cover Image"。
/// Next 时若用户未手动裁切，则按 16:9 居中默认裁切后单张回传给 `AddItemView`。
struct UploadItemImageView: View {
    // MARK: - Environment
    @Environment(\.dismiss) private var dismiss

    // MARK: - State
    @State private var viewModel = UploadItemImageViewModel()

    // MARK: - Props
    /// 选定图片后回传：图片 + 是否设为封面。
    let onConfirm: (UIImage, Bool) -> Void

    // MARK: - Init
    init(onConfirm: @escaping (UIImage, Bool) -> Void) {
        self.onConfirm = onConfirm
    }

    // MARK: - Body
    var body: some View {
        ZStack {
            AppColors.mask
                .ignoresSafeArea()
                .onTapGesture { dismiss() }

            dialogCard

            if viewModel.showPermissionAlert {
                CameraPermissionAlertView(
                    onCancel: { viewModel.showPermissionAlert = false },
                    onGoToSettings: {
                        viewModel.showPermissionAlert = false
                        if let url = URL(string: UIApplication.openSettingsURLString) {
                            UIApplication.shared.open(url)
                        }
                    }
                )
            }
        }
        .task { viewModel.onAppear() }
        .onDisappear { viewModel.onDisappear() }
    }

    // MARK: - Dialog Card
    private var dialogCard: some View {
        VStack(spacing: Spacing.lg) {
            header
            previewRegion
            coverAndAlbumRow
            shutterButton
            bottomButtons
        }
        .padding(Spacing.lg)
        .frame(maxWidth: 760)
        .background(AppColors.card)
        .cornerRadius(AppRadius.Tablet.lg)
        .padding(.horizontal, Spacing.xxxl)
        .shadow(color: AppColors.black20, radius: 24, y: 8)
    }

    // MARK: - Header
    private var header: some View {
        HStack {
            Text("Upload Item Image")
                .font(AppFont.tabletH1Medium)
                .foregroundColor(AppColors.textPrimary)
            Spacer()
            Button(action: { dismiss() }) {
                Image(systemName: "xmark")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(AppColors.textPrimary)
            }
        }
    }

    // MARK: - Preview Region (live viewfinder / captured still / placeholder)
    private var previewRegion: some View {
        ZStack {
            if let image = viewModel.capturedImage {
                // 静态预览：框固定居中，图片可单指平移 + 双指捏合缩放，Next 时反算裁切区域。
                CropImagePreview(
                    image: image,
                    onGeometryResolved: { frameSize, fillScale in
                        viewModel.updateCropGeometry(frameSize: frameSize, baseFillScale: fillScale)
                    },
                    onTransformCommit: { offset, scale in
                        viewModel.commitCropTransform(offset: offset, scale: scale)
                    }
                )
            } else if viewModel.isCameraActive {
                CameraPreviewRepresentable(session: viewModel.cameraManager.captureSession)
            } else {
                placeholderContent
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 320)
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.Tablet.md))
    }

    private var placeholderContent: some View {
        ZStack {
            AppColors.pageBgDeep
            VStack(spacing: Spacing.sm) {
                Image(systemName: "camera")
                    .font(.system(size: 48))
                    .foregroundColor(AppColors.textTertiary)
                Text("Camera Unavailable")
                    .font(AppFont.tabletBody3Regular)
                    .foregroundColor(AppColors.textTertiary)
            }
        }
    }

    // MARK: - Cover Toggle + Album Link
    private var coverAndAlbumRow: some View {
        HStack(spacing: Spacing.sm) {
            Button(action: { viewModel.useAsCover.toggle() }) {
                HStack(spacing: Spacing.sm) {
                    checkbox
                    Text("Use As Cover Image")
                        .font(AppFont.tabletBody2Regular)
                        .foregroundColor(AppColors.textSecondary)
                }
            }
            .buttonStyle(.plain)

            Spacer()

            Button(action: { viewModel.presentAlbumPicker() }) {
                Text("Upload From Album")
                    .font(AppFont.tabletBody2Regular)
                    .foregroundColor(AppColors.primaryNormal)
            }
            .buttonStyle(.plain)
        }
    }

    private var checkbox: some View {
        ZStack {
            RoundedRectangle(cornerRadius: AppRadius.Tablet.xs)
                .fill(viewModel.useAsCover ? AppColors.primaryNormal : AppColors.card)
                .overlay(
                    RoundedRectangle(cornerRadius: AppRadius.Tablet.xs)
                        .stroke(viewModel.useAsCover ? Color.clear : AppColors.line, lineWidth: 1)
                )
            if viewModel.useAsCover {
                Image(systemName: "checkmark")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(AppColors.buttonPrimaryText)
            }
        }
        .frame(width: 24, height: 24)
    }

    // MARK: - Shutter (Take Product Photo / Retake)
    private var shutterButton: some View {
        Button(action: handleShutter) {
            HStack(spacing: Spacing.xs) {
                Image(systemName: viewModel.isPreviewingStill ? "arrow.counterclockwise" : "Scan or Upload")
                    .font(.system(size: 18))
                    .foregroundColor(AppColors.textPrimary)
                Text(viewModel.isPreviewingStill ? "Retake" : "Take Product Photo")
                    .font(AppFont.tabletBody2Regular)
                    .foregroundColor(AppColors.textPrimary)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 64)
            .background(AppColors.card)
            .cornerRadius(AppRadius.Tablet.lg)
            .overlay(
                RoundedRectangle(cornerRadius: AppRadius.Tablet.lg)
                    .stroke(AppColors.line, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Bottom Buttons
    private var bottomButtons: some View {
        HStack(spacing: Spacing.md) {
            Button(action: { dismiss() }) {
                Text("Back")
                    .font(AppFont.tabletH3Medium)
                    .foregroundColor(AppColors.textPrimary)
                    .frame(maxWidth: .infinity)
                    .frame(height: 64)
                    .background(AppColors.buttonSecondaryBg)
                    .cornerRadius(AppRadius.Tablet.lg)
            }
            .buttonStyle(.plain)

            Button(action: handleNext) {
                Text("Next")
                    .font(AppFont.tabletH3Medium)
                    .foregroundColor(AppColors.buttonPrimaryText)
                    .frame(maxWidth: .infinity)
                    .frame(height: 64)
                    .background(AppColors.buttonPrimaryBg)
                    .cornerRadius(AppRadius.Tablet.lg)
            }
            .buttonStyle(.plain)
        }
    }

    // MARK: - Actions
    private func handleShutter() {
        if viewModel.isPreviewingStill {
            viewModel.retake()
        } else {
            viewModel.capturePhoto()
        }
    }

    private func handleNext() {
        // 用户未手动裁切 → 默认按 16:9 居中裁切后回传。
        if let cropped = viewModel.croppedCoverImage() {
            onConfirm(cropped, viewModel.useAsCover)
        }
        dismiss()
    }
}

// MARK: - Preview

#Preview {
    UploadItemImageView { _, _ in }
}
