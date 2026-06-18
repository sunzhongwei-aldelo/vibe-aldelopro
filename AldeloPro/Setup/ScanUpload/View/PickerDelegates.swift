//
//  PickerDelegates.swift
//  AldeloPro
//
//  Created by wanghui on 2026/06/10.
//

import UIKit
import PhotosUI
import UniformTypeIdentifiers

// MARK: - Document Picker Delegate

final class DocumentPickerDelegate: NSObject, UIDocumentPickerDelegate {

    static let shared = DocumentPickerDelegate()
    var onPicked: (([URL]) -> Void)?

    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        onPicked?(urls)
        onPicked = nil
    }

    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        onPicked = nil
    }
}

// MARK: - Photo Picker Delegate

final class PhotoPickerDelegate: NSObject, PHPickerViewControllerDelegate {

    static let shared = PhotoPickerDelegate()
    var onPicked: (([UIImage]) -> Void)?

    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)

        guard results.isEmpty == false else {
            onPicked = nil
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
            self?.onPicked?(images)
            self?.onPicked = nil
        }
    }
}
