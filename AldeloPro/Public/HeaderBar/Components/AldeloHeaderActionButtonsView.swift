//
//  AldeloHeaderActionButtonsView.swift
//  AldeloPro
//
//  Created by Sen on 2026/06/12.
//

import SwiftUI

// MARK: - AldeloHeaderActionButtonsView
//
// 【作用】
// 顶栏右侧的动作按钮组原子，统一渲染 0 / 2 / 3 个 `AldeloHeaderAction`，
// 被 B 族 (`AldeloTransactionHeaderView`) 与 C 族 (`AldeloModalHeaderView`) 共用。
//
// 【支持的场景】
//   • 0 个：纯标题栏（Cashier / Time Card / Confirmation Mode）→ 调用方传空数组。
//   • 2 个：Back + Continue / Cancel + Save（B、C 族主流）。
//   • 3 个：Back + All + Confirm（Repeat 页）。
//
// 【能力】
// - 禁用置灰（如 Add Item 未填完时的 Add 按钮，`isEnabled: false`）。
// - 数字角标（如 Repeat 页 Confirm 右上角红色「1」，`badge: 1`）。
// - 样式区分：`.primary` 实心品牌蓝 / `.secondary` 白底描边。
// - 全程 Design Token + tablet/mobile 隔离（取代旧 `Public/HeaderActionButtons.swift`
//   的硬编码 `.system(size:14)` 与写死的 Back+Confirm）。
//
// 【使用案例】
// ```swift
// // 1) 两个按钮：Cancel + Save
// AldeloHeaderActionButtonsView(actions: [
//     .cancel({ dismiss() }),
//     .primary("Save", action: { save() })
// ])
//
// // 2) 主按钮禁用（表单未填完）
// AldeloHeaderActionButtonsView(actions: [
//     .cancel({ dismiss() }),
//     .primary("Add", isEnabled: isFormValid, action: { add() })
// ])
//
// // 3) 三个按钮 + 角标
// AldeloHeaderActionButtonsView(actions: [
//     .back({ back() }),
//     AldeloHeaderAction(title: "All", style: .secondary, action: { selectAll() }),
//     .primary("Confirm", badge: 1, action: { confirm() })
// ])
//
// // 4) 纯标题栏：不传按钮
// AldeloHeaderActionButtonsView(actions: [])
// ```

struct AldeloHeaderActionButtonsView: View {

    @Environment(\.horizontalSizeClass) private var hSizeClass

    /// 动作按钮数据数组（0 / 2 / 3 个）。
    let actions: [AldeloHeaderAction]

    private var isCompact: Bool { hSizeClass == .compact }

    var body: some View {
        HStack(spacing: Spacing.sm) {
            ForEach(actions) { action in
                button(for: action)
            }
        }
    }

    private func button(for action: AldeloHeaderAction) -> some View {
        Button(action: action.action) {
            Text(action.title)
                .font(isCompact ? AppFont.mobileButton2Medium : AppFont.tabletButton3Medium)
                .foregroundColor(foreground(action))
                .frame(width: buttonWidth, height: buttonHeight)
                .background(backgroundColor(action))
                .clipShape(RoundedRectangle(cornerRadius: radius))
                .overlay(strokeOverlay(action))
                .overlay(alignment: .topTrailing) { badge(action) }
        }
        .buttonStyle(.plain)
        .disabled(!action.isEnabled)
    }

    // MARK: 角标

    /// 右上角红色数字角标（badge > 0 时显示）。
    @ViewBuilder
    private func badge(_ action: AldeloHeaderAction) -> some View {
        if let count = action.badge, count > 0 {
            Text("\(count)")
                .font(AppFont.tabletCaption2Regular)
                .foregroundColor(AppColors.white100)
                .padding(4)
                .frame(minWidth: 16, minHeight: 16)
                .background(AppColors.errorNormal)
                .clipShape(Circle())
                .offset(x: 6, y: -6)
        }
    }

    // MARK: 样式（tablet / mobile 隔离）

    private var buttonWidth: CGFloat { isCompact ? 72 : 96 }
    private var buttonHeight: CGFloat { isCompact ? 36 : 40 }
    private var radius: CGFloat { isCompact ? AppRadius.Mobile.sm : AppRadius.Tablet.sm }

    /// 背景色：primary 实心蓝（禁用转灰），secondary 白底。
    private func backgroundColor(_ action: AldeloHeaderAction) -> Color {
        switch action.style {
        case .primary:
            return action.isEnabled ? AppColors.theme : AppColors.buttonDisabledBg
        case .secondary:
            return AppColors.card
        }
    }

    /// 文字色：primary 白（禁用转灰），secondary 主文本色。
    private func foreground(_ action: AldeloHeaderAction) -> Color {
        switch action.style {
        case .primary:
            return action.isEnabled ? AppColors.white100 : AppColors.textMuted
        case .secondary:
            return AppColors.textPrimary
        }
    }

    /// secondary 样式的描边。
    @ViewBuilder
    private func strokeOverlay(_ action: AldeloHeaderAction) -> some View {
        if action.style == .secondary {
            RoundedRectangle(cornerRadius: radius)
                .stroke(AppColors.line, lineWidth: 1)
        }
    }
}
