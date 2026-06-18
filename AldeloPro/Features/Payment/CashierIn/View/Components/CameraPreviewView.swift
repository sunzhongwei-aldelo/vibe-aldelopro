//
//  CameraPreviewView.swift
//  AldeloPro
//
//  Created by Sen on 2026/06/04.
//

import SwiftUI
import AVFoundation

// MARK: - 摄像头预览视图

/// 将 AVCaptureVideoPreviewLayer 桥接为 SwiftUI View
/// 用于在面部识别页面显示前置摄像头实时画面
/// 自动裁剪为圆形并居中填充，锁定方向防止画面旋转
struct CameraPreviewView: UIViewRepresentable {
    /// 预览图层（从 FaceScanCameraService 获取）
    let previewLayer: AVCaptureVideoPreviewLayer?

    func makeUIView(context: Context) -> CameraPreviewUIView {
        let view = CameraPreviewUIView()
        if let layer = previewLayer {
            layer.videoGravity = .resizeAspectFill
            layer.frame = view.bounds
            // 锁定预览方向为竖屏，防止随设备旋转而翻转
            if let connection = layer.connection {
                connection.videoRotationAngle = 0
            }
            view.layer.addSublayer(layer)
        }
        return view
    }

    func updateUIView(_ uiView: CameraPreviewUIView, context: Context) {
        // 更新 frame 以适配布局变化（横竖屏切换）
        if let layer = previewLayer {
            layer.frame = uiView.bounds
            // 保持方向锁定，不随设备旋转
            if let connection = layer.connection {
                connection.videoRotationAngle = 0
            }
        }
    }
}

// MARK: - 承载预览图层的 UIView

/// 自定义 UIView，确保 previewLayer 始终跟随 bounds 变化
final class CameraPreviewUIView: UIView {
    override func layoutSubviews() {
        super.layoutSubviews()
        // 遍历所有子图层，同步更新 frame
        layer.sublayers?.forEach { sublayer in
            if let previewLayer = sublayer as? AVCaptureVideoPreviewLayer {
                previewLayer.frame = bounds
            }
        }
    }
}

// MARK: - Preview

#Preview("摄像头预览 - 圆形") {
    CameraPreviewView(previewLayer: nil)
        .frame(width: 300, height: 300)
        .clipShape(Circle())
        .background(Color.gray.opacity(0.2))
}
