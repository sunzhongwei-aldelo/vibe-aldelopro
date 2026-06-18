//
//  KeyboardHeightModifier.swift
//  AldeloPro
//
//  Created by jiangxia on 2026/06/11.
//

import SwiftUI

/// 仅把当前键盘高度写回绑定，**不做任何布局副作用**。
///
/// 与 `keyboardAvoidingScroll` 的区别：
/// - `keyboardAvoidingScroll` 适合整屏滚动表单，靠 `.safeAreaInset` 自动抬升聚焦框。
/// - 本 modifier 只负责「告诉你键盘多高」，布局（垫底、滚动定位）由调用方自己控制，
///   适合居中弹窗这类需要精确控制滚动锚点、且整体不随键盘上移的场景。
struct KeyboardHeightObserver: ViewModifier {
    @Binding var height: CGFloat

    /// 键盘出现/消失时高度过渡的动画时长，与系统键盘动画保持一致。
    private let animationDuration: TimeInterval = 0.25

    func body(content: Content) -> some View {
        content
            .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)) { notification in
                guard let frame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
                withAnimation(.easeOut(duration: animationDuration)) {
                    height = frame.height
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)) { _ in
                withAnimation(.easeOut(duration: animationDuration)) {
                    height = 0
                }
            }
    }
}

extension View {
    /// 持续把键盘高度写回 `height`，自身不改变任何布局。
    ///
    /// ```swift
    /// @State private var keyboardHeight: CGFloat = 0
    /// someView.observingKeyboardHeight($keyboardHeight)
    /// ```
    func observingKeyboardHeight(_ height: Binding<CGFloat>) -> some View {
        modifier(KeyboardHeightObserver(height: height))
    }
}
