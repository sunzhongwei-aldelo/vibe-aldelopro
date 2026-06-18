//
//  CameraPreviewRepresentable.swift
//  AldeloPro
//
//  Created by wanghui on 2026/06/09.
//

import SwiftUI
import AVFoundation

struct CameraPreviewRepresentable: UIViewRepresentable {

    let session: AVCaptureSession

    func makeUIView(context: Context) -> AVCapturePreviewContainerView {
        let view = AVCapturePreviewContainerView()
        view.previewLayer.session = session
        view.previewLayer.videoGravity = .resizeAspectFill
        return view
    }

    func updateUIView(_ uiView: AVCapturePreviewContainerView, context: Context) {
        uiView.previewLayer.session = session
    }
}

final class AVCapturePreviewContainerView: UIView {

    override class var layerClass: AnyClass {
        AVCaptureVideoPreviewLayer.self
    }

    var previewLayer: AVCaptureVideoPreviewLayer {
        layer as! AVCaptureVideoPreviewLayer
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        updateVideoRotation()
    }

    private func updateVideoRotation() {
        guard let connection = previewLayer.connection,
              connection.isVideoRotationAngleSupported(currentRotationAngle) else { return }
        connection.videoRotationAngle = currentRotationAngle
    }

    private var currentRotationAngle: CGFloat {
        guard let windowScene = window?.windowScene else { return 90 }
        switch windowScene.interfaceOrientation {
        case .portrait:
            return 90
        case .landscapeRight:
            return 0
        case .landscapeLeft:
            return 180
        case .portraitUpsideDown:
            return 270
        default:
            return 90
        }
    }
}
