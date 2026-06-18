//
//  DocumentWebPreviewView.swift
//  AldeloPro
//
//  Created by wanghui on 2026/06/10.
//

import SwiftUI
import WebKit

struct DocumentWebPreviewView: UIViewRepresentable {

    let fileURL: URL

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    func makeUIView(context: Context) -> UIView {
        let container = UIView()
        container.backgroundColor = .clear

        let config = WKWebViewConfiguration()
        let webView = WKWebView(frame: .zero, configuration: config)
        webView.backgroundColor = .clear
        webView.isOpaque = false
        webView.scrollView.backgroundColor = .clear
        webView.navigationDelegate = context.coordinator
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.alpha = 0

        let spinner = UIActivityIndicatorView(style: .medium)
        spinner.startAnimating()
        spinner.translatesAutoresizingMaskIntoConstraints = false

        container.addSubview(spinner)
        container.addSubview(webView)

        NSLayoutConstraint.activate([
            spinner.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            spinner.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            webView.topAnchor.constraint(equalTo: container.topAnchor),
            webView.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            webView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: container.trailingAnchor)
        ])

        context.coordinator.spinner = spinner
        context.coordinator.webView = webView

        webView.loadFileURL(fileURL, allowingReadAccessTo: fileURL.deletingLastPathComponent())

        return container
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        guard let webView = context.coordinator.webView else { return }
        if context.coordinator.currentURL != fileURL {
            context.coordinator.currentURL = fileURL
            webView.alpha = 0
            context.coordinator.spinner?.startAnimating()
            webView.loadFileURL(fileURL, allowingReadAccessTo: fileURL.deletingLastPathComponent())
        }
    }

    class Coordinator: NSObject, WKNavigationDelegate {
        weak var spinner: UIActivityIndicatorView?
        weak var webView: WKWebView?
        var currentURL: URL?

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            spinner?.stopAnimating()
            UIView.animate(withDuration: 0.2) {
                webView.alpha = 1
            }
        }
    }
}
