//
//  UploadItemImageViewModel.swift
//  AldeloPro
//
//  Created by jiangxia on 2026/06/12.
//

import Foundation
import UIKit
import AVFoundation

/// 驱动 `UploadItemImageView` 的相机生命周期与单张图片选择状态。
/// 复用 `CameraSessionManager`（AVFoundation 内嵌取景 + 拍照），与 `ScanUploadViewModel` 同模式。
@Observable
@MainActor
final class UploadItemImageViewModel {

    // MARK: - State

    /// 已确认的静态图（拍照快门或相册选中）；nil 表示当前处于实时取景。
    private(set) var capturedImage: UIImage?

    /// 实时取景是否运行中。
    private(set) var isCameraActive = false

    /// 是否将该图设为封面（对应 "Use As Cover Image"）。
    var useAsCover = true


    /// 无相机权限提示显隐。
    var showPermissionAlert = false

    // MARK: - Crop Transform（交互裁切：框固定，图片平移 + 缩放）

    /// 图片相对裁切框中心的平移量（点，显示坐标系），手势提交后更新。
    private(set) var cropOffset: CGSize = .zero

    /// 用户缩放系数（1 = 充满裁切框的基准比例，最小 1）。
    private(set) var cropScale: CGFloat = 1

    /// 裁切框尺寸（容器内 16:9 最大内接），由 `CropImagePreview` 报告，用于反算裁切区域。
    private var cropFrameSize: CGSize = .zero

    /// 「充满容器」基准比例（scale=1 时图恰好覆盖容器），与组件渲染/钳制同口径，用于反算裁切区域。
    private var cropBaseFillScale: CGFloat = 0

    // MARK: - Camera

    let cameraManager = CameraSessionManager()
    private let photoLauncher = PhotoLibraryLauncher()

    // MARK: - Computed

    /// 当前是否展示静态预览（已拍 / 已选图）。
    var isPreviewingStill: Bool {
        capturedImage != nil
    }

    /// 设备是否具备可用相机（模拟器无相机）。
    var isCameraAvailable: Bool {
        #if targetEnvironment(simulator)
        return false
        #else
        return true
        #endif
    }

    /// 是否已获得相机授权。
    var hasCameraPermission: Bool {
        AVCaptureDevice.authorizationStatus(for: .video) == .authorized
    }

    // MARK: - Lifecycle

    /// 弹窗出现：申请权限并启动实时取景（首次会弹系统权限框）。
    func onAppear() {
        guard isCameraAvailable else { return }
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        switch status {
        case .authorized:
            startCamera()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                Task { @MainActor [weak self] in
                    if granted {
                        self?.startCamera()
                    } else {
                        self?.showPermissionAlert = true
                    }
                }
            }
        default:
            showPermissionAlert = true
        }
    }

    /// 弹窗消失：停止取景，释放相机。
    func onDisappear() {
        stopCamera()
    }

    private func startCamera() {
        guard capturedImage == nil else { return }
        cameraManager.configureSession()
        cameraManager.startSession()
        isCameraActive = true
    }

    func stopCamera() {
        cameraManager.stopSession()
        isCameraActive = false
    }

    // MARK: - Actions

    /// "Take Product Photo" 快门：拍一张并进入静态预览（不裁剪）。
    func capturePhoto() {
        guard isCameraActive else {
            if isCameraAvailable && hasCameraPermission == false {
                showPermissionAlert = true
            }
            return
        }
        cameraManager.capturePhoto { [weak self] image in
            Task { @MainActor in
                guard let self else { return }
                self.capturedImage = image
                self.resetCropTransform()
                self.stopCamera()
            }
        }
    }

    /// "Retake"：丢弃当前静态图，回到实时取景。
    func retake() {
        capturedImage = nil
        resetCropTransform()
        startCamera()
    }

    /// "Upload From Album"：命令式呈现系统相册（每次一张），选中后回填静态预览。
    func presentAlbumPicker() {
        photoLauncher.present(maxSelection: 1) { [weak self] images in
            guard let self, let first = images.first else { return }
            self.setAlbumImage(first)
        }
    }

    /// 相册选图回填（单张），停止取景并进入静态预览。
    func setAlbumImage(_ image: UIImage) {
        capturedImage = image
        resetCropTransform()
        stopCamera()
    }

    // MARK: - Crop

    /// `CropImagePreview` 报告当前裁切框尺寸与充满容器的基准比例。
    func updateCropGeometry(frameSize: CGSize, baseFillScale: CGFloat) {
        cropFrameSize = frameSize
        cropBaseFillScale = baseFillScale
    }

    /// 手势结束后提交已钳制的平移/缩放。
    func commitCropTransform(offset: CGSize, scale: CGFloat) {
        cropOffset = offset
        cropScale = scale
    }

    /// 切换图片时复位裁切交互（回到充满框、居中）。
    private func resetCropTransform() {
        cropOffset = .zero
        cropScale = 1
    }

    /// 按裁切框相对图片的位置反算 16:9 区域并裁切，返回新图；无图返回 nil。
    /// 使用 `image.draw` 绘制，自动尊重相机照片的 `imageOrientation`，不会裁错区域。
    func croppedCoverImage(aspectRatio: CGFloat = 16.0 / 9.0) -> UIImage? {
        guard let image = capturedImage else { return nil }
        let imageSize = image.size
        guard imageSize.width > 0, imageSize.height > 0, aspectRatio > 0 else { return image }

        let cropRect = cropRectInImageSpace(imageSize: imageSize, aspectRatio: aspectRatio)

        let format = UIGraphicsImageRendererFormat.default()
        format.scale = image.scale
        format.opaque = true
        let renderer = UIGraphicsImageRenderer(size: cropRect.size, format: format)
        return renderer.image { _ in
            image.draw(at: CGPoint(x: -cropRect.origin.x, y: -cropRect.origin.y))
        }
    }

    /// 反算裁切矩形（图片坐标系）：有交互 transform + 框尺寸时按 offset/scale 反算；否则居中最大内接兜底。
    private func cropRectInImageSpace(imageSize: CGSize, aspectRatio: CGFloat) -> CGRect {
        guard cropFrameSize.width > 0, cropFrameSize.height > 0, cropBaseFillScale > 0 else {
            return centeredCropRect(imageSize: imageSize, aspectRatio: aspectRatio)
        }
        let totalScale = cropBaseFillScale * cropScale
        guard totalScale > 0 else {
            return centeredCropRect(imageSize: imageSize, aspectRatio: aspectRatio)
        }
        let cropWidth = cropFrameSize.width / totalScale
        let cropHeight = cropFrameSize.height / totalScale
        let centerX = imageSize.width / 2 - cropOffset.width / totalScale
        let centerY = imageSize.height / 2 - cropOffset.height / totalScale
        let originX = min(max(centerX - cropWidth / 2, 0), max(0, imageSize.width - cropWidth))
        let originY = min(max(centerY - cropHeight / 2, 0), max(0, imageSize.height - cropHeight))
        return CGRect(x: originX, y: originY, width: cropWidth, height: cropHeight)
    }

    /// 居中最大内接 aspectRatio 矩形（无交互时的兜底）。
    private func centeredCropRect(imageSize: CGSize, aspectRatio: CGFloat) -> CGRect {
        var cropWidth = imageSize.width
        var cropHeight = imageSize.width / aspectRatio
        if cropHeight > imageSize.height {
            cropHeight = imageSize.height
            cropWidth = imageSize.height * aspectRatio
        }
        return CGRect(
            x: (imageSize.width - cropWidth) / 2,
            y: (imageSize.height - cropHeight) / 2,
            width: cropWidth,
            height: cropHeight
        )
    }
}
