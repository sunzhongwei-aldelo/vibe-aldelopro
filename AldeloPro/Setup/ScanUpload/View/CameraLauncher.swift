//
//  CameraLauncher.swift
//  AldeloPro
//
//  Created by wanghui on 2026/06/09.
//

import UIKit
import VisionKit

@MainActor
final class CameraLauncher: NSObject, VNDocumentCameraViewControllerDelegate {

    private var onScanCompleted: (([UIImage]) -> Void)?
    private var onCancelled: (() -> Void)?

    func present(from sourceView: UIView?, onScanCompleted: @escaping ([UIImage]) -> Void, onCancelled: @escaping () -> Void) {
        self.onScanCompleted = onScanCompleted
        self.onCancelled = onCancelled

        let scanner = VNDocumentCameraViewController()
        scanner.delegate = self

        guard let topVC = Self.topViewController() else { return }
        topVC.present(scanner, animated: true)
    }

    // MARK: - VNDocumentCameraViewControllerDelegate

    nonisolated func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {
        Task { @MainActor [weak self] in
            var images: [UIImage] = []
            for i in 0..<scan.pageCount {
                images.append(scan.imageOfPage(at: i))
            }
            self?.onScanCompleted?(images)
            controller.dismiss(animated: true)
        }
    }

    nonisolated func documentCameraViewControllerDidCancel(_ controller: VNDocumentCameraViewController) {
        Task { @MainActor [weak self] in
            self?.onCancelled?()
            controller.dismiss(animated: true)
        }
    }

    nonisolated func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFailWithError error: Error) {
        Task { @MainActor [weak self] in
            self?.onCancelled?()
            controller.dismiss(animated: true)
        }
    }

    // MARK: - Helper

    private static func topViewController() -> UIViewController? {
        guard let windowScene = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first,
              let rootVC = windowScene.windows.first(where: { $0.isKeyWindow })?.rootViewController
        else { return nil }

        var top = rootVC
        while let presented = top.presentedViewController {
            top = presented
        }
        return top
    }
}
