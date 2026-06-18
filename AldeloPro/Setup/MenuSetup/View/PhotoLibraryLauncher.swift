//
//  PhotoLibraryLauncher.swift
//  AldeloPro
//
//  Created by jiangxia on 2026/06/12.
//

import UIKit
import PhotosUI

/// 以命令式方式（topViewController.present）呈现系统相册选择器，
/// 避免在 SwiftUI 嵌套 `.fullScreenCover` 中呈现 PHPicker 导致的呈现/消失异常。
/// 复用 `PhotoPickerDelegate.shared` 完成图片加载，模式与 `CameraLauncher` 一致。
@MainActor
final class PhotoLibraryLauncher {

    /// 呈现相册选择器。
    /// - Parameters:
    ///   - maxSelection: 最多可选张数。
    ///   - onPicked: 选择完成回调（已切回主 Actor 触发）。
    func present(maxSelection: Int, onPicked: @escaping @MainActor ([UIImage]) -> Void) {
        var config = PHPickerConfiguration()
        config.selectionLimit = maxSelection
        config.filter = .images

        let picker = PHPickerViewController(configuration: config)
        let delegate = PhotoPickerDelegate.shared
        delegate.onPicked = { images in
            Task { @MainActor in onPicked(images) }
        }
        picker.delegate = delegate

        guard let topVC = Self.topViewController() else { return }
        topVC.present(picker, animated: true)
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
