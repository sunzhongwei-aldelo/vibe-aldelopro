//
//  ClearBackgroundView.swift
//  AldeloPro
//
//  Created by LiZong on 2026/06/11.
//

import SwiftUI

struct ClearBackgroundView: UIViewRepresentable {
    func makeUIView(context: Context) -> UIView {
        let view = ClearBackgroundUIView()
        DispatchQueue.main.async {
            view.superview?.superview?.backgroundColor = .clear
        }
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {}
}

private final class ClearBackgroundUIView: UIView {
    override func didMoveToWindow() {
        super.didMoveToWindow()
        superview?.superview?.backgroundColor = .clear
    }
}
