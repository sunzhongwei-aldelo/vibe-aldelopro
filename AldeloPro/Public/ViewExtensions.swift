//
//  ViewExtensions.swift
//  AldeloPro
//
//  Created by 孙仲伟 on 6/10/26.
//
import SwiftUI

// 恢复手势的辅助 View
struct SwipeBackGestureEnabler: UIViewRepresentable {
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        DispatchQueue.main.async {
            // 找到 UINavigationController 并恢复手势
            if let navigationController = view.findNavigationController() {
                if #available(iOS 26.0, *) {
                    navigationController.interactiveContentPopGestureRecognizer?.isEnabled = true
                    navigationController.interactiveContentPopGestureRecognizer?.delegate = nil
                } else {
                    // Fallback on earlier versions
                    navigationController.interactivePopGestureRecognizer?.isEnabled = true
                    navigationController.interactivePopGestureRecognizer?.delegate = nil
                }
                
            }
        }
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {}
}

// UIView 扩展：查找 NavigationController
extension UIView {
    func findNavigationController() -> UINavigationController? {
        var responder: UIResponder? = self
        while let r = responder {
            if let nav = r as? UINavigationController {
                return nav
            }
            responder = r.next
        }
        return nil
    }
}
