//
//  PhotoPickerRepresentable.swift
//  AldeloPro
//
//  Created by wanghui on 2026/06/10.
//

import SwiftUI
import PhotosUI

struct PhotoPickerRepresentable: UIViewControllerRepresentable {

    let maxSelection: Int
    let onImagesPicked: ([UIImage]) -> Void
    let onCancelled: () -> Void

    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.selectionLimit = maxSelection
        config.filter = .images
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(onImagesPicked: onImagesPicked, onCancelled: onCancelled)
    }

    final class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let onImagesPicked: ([UIImage]) -> Void
        let onCancelled: () -> Void

        init(onImagesPicked: @escaping ([UIImage]) -> Void, onCancelled: @escaping () -> Void) {
            self.onImagesPicked = onImagesPicked
            self.onCancelled = onCancelled
        }

        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true)

            guard results.isEmpty == false else {
                onCancelled()
                return
            }

            var images: [UIImage] = []
            let group = DispatchGroup()

            for result in results {
                group.enter()
                result.itemProvider.loadObject(ofClass: UIImage.self) { object, _ in
                    if let image = object as? UIImage {
                        images.append(image)
                    }
                    group.leave()
                }
            }

            group.notify(queue: .main) { [weak self] in
                self?.onImagesPicked(images)
            }
        }
    }
}
