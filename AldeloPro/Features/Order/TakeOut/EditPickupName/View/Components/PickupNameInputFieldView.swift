//
//  PickupNameInputFieldView.swift
//  AldeloProject
//
//  Created by Sen on 2026/06/10.
//

import SwiftUI

/// 核心姓名文本输入舱：圆角矩形卡片，淡灰色凹陷底。
/// 焦点由父级持有并以 binding 注入，使弹窗出现时可自动获取第一响应者。
/// 处于聚焦激活态时，框内最右侧由系统渲染主题蓝色高频闪烁的垂直光标（通过 `.tint` 注入）。
/// 仅为子组件 —— 绝不以 `MainView` 结尾命名。
///
/// 背景色说明：本弹窗的输入框位于**白卡 `card` 上**，而共享资产 `inputBg` 在浅色下
/// 解析为纯白 `#FFFFFF`（它服务于蓝灰 `pageBg` 页面底，那里白色对比清晰），叠在白卡上会
/// 完全隐形。设计图（SVG）中输入框与 Cancel 按钮共用同一灰面 `#F8F8F8`，恰为
/// `buttonSecondaryBg` 的浅色值；其暗色 `#373737` 在暗卡上同样清晰。故此处采用
/// `buttonSecondaryBg` 作为凹陷底，既精准对齐设计、又在明暗两态都与白/暗卡保持对比，
/// 且不改动被 50+ 处共享引用的 `inputBg` 资产。
struct PickupNameInputFieldView: View {

    @Environment(\.horizontalSizeClass) private var hSizeClass

    let text: String
    let placeholder: String
    let onChange: (String) -> Void
    var focus: FocusState<Bool>.Binding

    private var isPad: Bool { hSizeClass == .regular }
    private var corner: CGFloat { isPad ? AppRadius.Tablet.md : AppRadius.Mobile.md }
    private var fieldHeight: CGFloat { isPad ? 60 : 52 }

    var body: some View {
        TextField(
            placeholder,
            text: Binding(get: { text }, set: onChange)
        )
        .font(isPad ? AppFont.tabletBody1Regular : AppFont.mobileBody1Regular)
        .foregroundStyle(AppColors.textPrimary)
        .tint(AppColors.theme) // 聚焦时的主题蓝垂直闪烁光标
        .autocorrectionDisabled()
        .textInputAutocapitalization(.words)
        .submitLabel(.done)
        .focused(focus)
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(height: fieldHeight)
        .padding(.horizontal, isPad ? Spacing.md : Spacing.sm)
        .background(
            RoundedRectangle(cornerRadius: corner, style: .continuous)
                .fill(AppColors.buttonSecondaryBg)
        )
    }
}

// MARK: - Previews

private struct PickupNameInputPreviewHost: View {
    @FocusState private var focus: Bool
    let text: String
    let isPad: Bool

    var body: some View {
        PickupNameInputFieldView(
            text: text,
            placeholder: "Pickup Name",
            onChange: { _ in },
            focus: $focus
        )
        .padding()
        .background(AppColors.card)
        .environment(\.horizontalSizeClass, isPad ? .regular : .compact)
        .onAppear { focus = true }
    }
}

#Preview("iPad - 聚焦") {
    PickupNameInputPreviewHost(text: "Sophie", isPad: true)
}

#Preview("iPhone - 聚焦") {
    PickupNameInputPreviewHost(text: "Sophie", isPad: false)
}

#Preview("iPad - 空态 placeholder") {
    PickupNameInputPreviewHost(text: "", isPad: true)
}
