//
//  KeyboardFocusScrollModifier.swift
//  AldeloPro
//
//  Created by wanghui on 2026/06/12.
//

import SwiftUI

/// 键盘弹出时把当前聚焦控件滚到键盘上方，且**不顶起同层固定顶栏**。
///
/// ## 为什么需要它
/// 在 `.fullScreenCover` 弹出的页面里，系统键盘自动避让一直生效且无法用
/// `.ignoresSafeArea(.keyboard)`（挂在子层无效）关掉。任何「随 keyboardHeight 改布局」
/// 的写法（`.safeAreaInset(keyboardHeight)`、动态 `.padding(.bottom, keyboardHeight)`）都会
/// 与系统避让**叠加**，把固定顶栏（甚至输入框）推出屏幕。
///
/// ## 本方案
/// 完全不手动改布局，只做两件**不影响布局尺寸**的事：
/// 1. 监听键盘高度（仅用于判断键盘何时弹出）。
/// 2. 键盘弹出后延迟一拍 `scrollTo(focused, anchor:)` —— 只改滚动位置，不改尺寸，故不顶顶栏。
///
/// ## 用法
/// 调用方需自备：`@FocusState`、每个输入框 `.focused(_:equals:)` + 行 `.id(_:)`、
/// 以及 ScrollView 内容底部一段**固定** padding 作为滚动余量（如 `.padding(.bottom, 300)`）。
/// ```swift
/// @FocusState private var focused: Field?
/// ScrollViewReader { proxy in
///     ScrollView {
///         VStack {
///             TextField(...).focused($focused, equals: .name).id(Field.name)
///             // ...
///         }
///         .padding(.bottom, 300) // 固定滚动余量（常量，不随键盘变化，不会叠加避让）
///     }
///     .keyboardFocusScroll(focused: focused, proxy: proxy)
/// }
/// ```
///
/// > `@FocusState` 声明与 `.focused()`/`.id()` 是页面自身信息，无法封装进 modifier。
struct KeyboardFocusScrollModifier<Value: Hashable>: ViewModifier {
    let focused: Value?
    let proxy: ScrollViewProxy
    /// 滚动锚点。`.center` 体验较稳；`.bottom` 会贴键盘但靠下字段易被挡。
    var anchor: UnitPoint

    @State private var keyboardHeight: CGFloat = 0

    func body(content: Content) -> some View {
        content
            .onChange(of: keyboardHeight) { _, height in
                guard height > 0, let focused else { return }
                scroll(to: focused)
            }
            .onChange(of: focused) { _, newValue in
                guard keyboardHeight > 0, let newValue else { return }
                scroll(to: newValue)
            }
            .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)) { note in
                if let frame = note.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
                    keyboardHeight = frame.height
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)) { _ in
                keyboardHeight = 0
            }
    }

    /// 延迟一拍，等系统键盘避让完成后再滚动，避免与系统避让抢同一帧。
    private func scroll(to value: Value) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            withAnimation(.easeOut(duration: 0.25)) {
                proxy.scrollTo(value, anchor: anchor)
            }
        }
    }
}

extension View {
    /// 键盘弹出时把聚焦控件滚到键盘上方（不顶固定顶栏）。
    /// 需放在 `ScrollViewReader` 内的 `ScrollView` 上；详见 ``KeyboardFocusScrollModifier``。
    func keyboardFocusScroll<Value: Hashable>(
        focused: Value?,
        proxy: ScrollViewProxy,
        anchor: UnitPoint = .center
    ) -> some View {
        modifier(KeyboardFocusScrollModifier(focused: focused, proxy: proxy, anchor: anchor))
    }
}
