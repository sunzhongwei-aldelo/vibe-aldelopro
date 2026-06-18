//
//  DocumentPickerRepresentable.swift
//  AldeloPro
//
//  Created by wanghui on 2026/06/05.
//

import SwiftUI
import UniformTypeIdentifiers

struct DocumentPickerRepresentable: UIViewControllerRepresentable {

    var contentTypes: [UTType] = [.spreadsheet, .commaSeparatedText]
    var allowsMultipleSelection: Bool = false
    var onFilesPicked: (([URL]) -> Void)?
    var onFilePicked: ((URL) -> Void)?
    var onCancelled: () -> Void

    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: contentTypes)
        picker.delegate = context.coordinator
        picker.allowsMultipleSelection = allowsMultipleSelection
        return picker
    }

    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(
            onFilesPicked: onFilesPicked,
            onFilePicked: onFilePicked,
            onCancelled: onCancelled
        )
    }

    final class Coordinator: NSObject, UIDocumentPickerDelegate {
        let onFilesPicked: (([URL]) -> Void)?
        let onFilePicked: ((URL) -> Void)?
        let onCancelled: () -> Void

        init(
            onFilesPicked: (([URL]) -> Void)?,
            onFilePicked: ((URL) -> Void)?,
            onCancelled: @escaping () -> Void
        ) {
            self.onFilesPicked = onFilesPicked
            self.onFilePicked = onFilePicked
            self.onCancelled = onCancelled
        }

        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            if let onFilesPicked {
                onFilesPicked(urls)
            } else if let url = urls.first {
                onFilePicked?(url)
            }
        }

        func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
            onCancelled()
        }
    }
}
