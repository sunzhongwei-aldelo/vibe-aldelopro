//
//  AldeloAlert.swift
//  AldeloProject
//
//  Created by Sen on 2026/06/05.
//
//  ============================================================================
//  通用自定义模态弹窗组件（覆盖全部设计稿形态，一个组件搞定）
//  ============================================================================
//
//  ▸ 5 种语义弹窗（覆盖全部 10 张设计稿）：
//
//    ┌─ 1. confirm        标题 + [Cancel | Confirm(蓝)]                轻量确认（Setup Printer / Tip Out / Submit）
//    ├─ 2. destructive    (可带⚠️图标/副标题/勾选) + [Confirm(红) | Cancel]   危险操作（Clear All / Delete Group）
//    ├─ 3. single         标题 + [单个全宽按钮]                        单一确认（Done / 关灯提醒）
//    ├─ 4. errorNotice    右上✕ + 居中红圆! + 双色副标题 + 居中大标题      强提醒（现金不足 / Upload disabled）
//    └─ 5. inputAlert     右上✕ + 标题 + 输入框 + 分隔线 + [Cancel | Confirm(蓝)]   文本录入（Edit Tab Name）
//
//  ============================================================================
//  ★ 推荐方式一 · 全局一行调用（最省事，无需自己管显隐 / 遮罩 / 动画）★
//  ============================================================================
//
//    取一次：  @Environment(\.alert) private var alert
//    然后任意位置一行触发，5 种全演示：
//
//      // 1. 确认（蓝 Confirm 在右）
//      alert.confirm(title: "Setup Printer Now?") { setup() }
//
//      // 1b. 自定义按钮文字 + 取消回调
//      alert.confirm(title: "Tip Out $5.00 By Mike?",
//                    confirmTitle: "Confirm", cancelTitle: "Cancel",
//                    onConfirm: { tipOut() }, onCancel: { print("cancelled") })
//
//      // 2. 危险操作（红 Confirm 在左）。onConfirm 回传勾选状态（无勾选框时恒为 false）
//      alert.destructive(title: "Clear All?", confirmTitle: "Confirm") { _ in clearAll() }
//
//      // 2b. 危险操作 + ⚠️图标 + 副标题 + 勾选框（Delete Group 场景）
//      alert.destructive(title: "Delete Burgers & Sandwiches Group?",
//                        subtitle: "5 Items Exist Under This Group.",
//                        showIcon: true,
//                        checkboxText: "Permanently Delete All 5 Items",
//                        checkboxDefaultOn: true,
//                        confirmTitle: "Delete") { isChecked in delete(all: isChecked) }
//
//      // 3. 单按钮全宽（蓝 Done）
//      alert.single(title: "Please turn off all lights before ending the day.",
//                   buttonTitle: "Done", role: .primary, showIcon: true) { /* Done */ }
//
//      // 4. 居中强提醒（红圆 + 双色副标题，右上✕ 关闭）
//      alert.errorNotice(title: "Not Enough Cash for Tip Out",
//                        highlightLabel: "Cash Drawer Balance:", highlightValue: "$3.00")
//
//      // 5. 输入框弹窗（onConfirm 回传输入的最终文本）
//      alert.inputAlert(title: "Edit Tab Name", text: currentName, placeholder: "Name") { newName in
//          save(newName)
//      }
//
//  ============================================================================
//  ★ 推荐方式二 · 局部 overlay（自己用 @State 控显隐，适合页面内联弹窗）★
//  ============================================================================
//
//    用 .overlay 套住语义工厂，自己持有 @State Bool 控制显隐，5 种全演示：
//
//      @State private var showConfirm = false
//      @State private var deleteAll = false        // 勾选框状态（2b 用）
//      @State private var tabName = "Sophia"       // 输入框文本（5 用）
//      ...
//      .overlay {
//          // 1. 确认
//          if showConfirm {
//              AldeloAlert.confirm(title: "Setup Printer Now?",
//                                  onConfirm: { setup(); showConfirm = false },
//                                  onCancel:  { showConfirm = false })
//          }
//
//          // 2b. 危险操作 + 勾选框（勾选状态用 .destructive 的 isChecked: Binding）
//          if showDelete {
//              AldeloAlert.destructive(title: "Delete \(group.name) Group?",
//                                      subtitle: "5 Items Exist Under This Group.",
//                                      showIcon: true,
//                                      checkboxText: "Permanently Delete All 5 Items",
//                                      isChecked: $deleteAll,
//                                      confirmTitle: "Delete",
//                                      onConfirm: { delete(all: deleteAll); showDelete = false },
//                                      onCancel:  { showDelete = false })
//          }
//
//          // 3. 单按钮
//          if showDone {
//              AldeloAlert.single(title: "Please turn off all lights before ending the day.",
//                                 buttonTitle: "Done", showIcon: true,
//                                 onTap: { showDone = false })
//          }
//
//          // 4. 居中强提醒
//          if showCash {
//              AldeloAlert.centeredNotice(title: "Not Enough Cash for Tip Out",
//                                         highlightLabel: "Cash Drawer Balance:",
//                                         highlightValue: "$3.00",
//                                         onClose: { showCash = false })
//          }
//
//          // 5. 输入框（文本用 .input 的 text: Binding）
//          if showRename {
//              AldeloAlert.input(title: "Edit Tab Name", text: $tabName, placeholder: "Name",
//                                onConfirm: { save(tabName); showRename = false },
//                                onCancel:  { showRename = false })
//          }
//      }
//
//    注：局部入口的工厂名是 .confirm / .destructive / .single / .centeredNotice / .input
//        （第 4 种局部叫 centeredNotice，全局叫 errorNotice，行为一致）。
//
//  ============================================================================
//  ▸ 其它兼容入口（无需改动现有代码）：
//      • @Environment(AppUIManager.self) private var ui → ui.confirm(...) 等，与 \.alert 等价（\.alert 更推荐：只暴露弹窗能力）。
//      • 旧的 AldeloAlert(style:title:...) 直接构造器全部保留，历史调用点零改动。
//  ============================================================================

import SwiftUI

// MARK: - Alert Style（样式：图标 + 颜色语义）

/// 弹窗样式枚举，控制「图标」与「确认按钮默认颜色」。只负责视觉语义，不负责排版（排版见 `AldeloAlertLayout`）。
enum AldeloAlertStyle {
    case warning       // ⚠️ 黄色警告（默认确认按钮红色）
    case error         // ❌ 红色错误
    case success       // ✅ 绿色成功
    case info          // ℹ️ 蓝色信息
    case notice        // ⚠️ 圆形警告图标 + 蓝色确认按钮（普通通知提示）

    /// 该样式对应的 SF Symbol 图标名（standard 布局使用）。
    var iconName: String {
        switch self {
        case .warning: return "exclamationmark.triangle.fill"
        case .error: return "xmark.circle.fill"
        case .success: return "checkmark.circle.fill"
        case .info: return "info.circle.fill"
        case .notice: return "exclamationmark.circle"
        }
    }

    /// 图标颜色（centeredNotice 圆形底色也取自这里）。
    var iconColor: Color {
        switch self {
        case .warning, .notice: return AppColors.warningNormal
        case .error: return AppColors.errorNormal
        case .success: return AppColors.successNormal
        case .info: return AppColors.theme
        }
    }

    /// 确认按钮默认底色（外部传 `confirmColor` 可覆盖）。
    var defaultConfirmColor: Color {
        switch self {
        case .warning, .error: return AppColors.errorNormal
        case .success: return AppColors.successNormal
        case .info, .notice: return AppColors.buttonPrimaryBg
        }
    }
}

// MARK: - 按钮角色

/// 弹窗按钮的视觉角色。
enum AldeloAlertButtonRole {
    case primary      // 主按钮：蓝底白字
    case destructive  // 危险按钮：红底白字
    case secondary    // 次按钮：浅灰底黑字

    var background: Color {
        switch self {
        case .primary:     return AppColors.buttonPrimaryBg
        case .destructive: return AppColors.errorNormal
        case .secondary:   return AppColors.buttonSecondaryBg
        }
    }

    var foreground: Color {
        switch self {
        case .primary, .destructive: return AppColors.buttonPrimaryText
        case .secondary:             return AppColors.buttonSecondaryText
        }
    }
}

// MARK: - Alert Layout（布局：排版结构）

/// 弹窗布局形态。与样式正交：任意样式都可搭配任意布局。
/// 内部使用维度，外部不直接传值 —— 走语义工厂（.confirm/.destructive/...）即可。
enum AldeloAlertLayout {
    case standard        // 默认：左对齐「(图标) + 标题」/ 内容 / 底部按钮行
    case centeredNotice  // 居中提示：右上关闭叉 + 居中圆形图标 + 双色副标题 + 居中大标题
    case input           // 输入：右上关闭叉 + 左对齐标题 + 输入框 + 分隔线 + 底部按钮行
}

// MARK: - AldeloAlert

/// 通用自定义模态弹窗（详尽用法见文件顶部速查注释）。
///
/// - 优先用语义工厂：`.confirm` / `.destructive` / `.single` / `.centeredNotice` / `.input`；
/// - 也保留底层直接构造器以兼容历史调用点；
/// - 典型局部用法：`.overlay { if showAlert { AldeloAlert.confirm(...) } }`；
/// - 全局一行用法见 `AppUIManager` 扩展。
struct AldeloAlert<Content: View>: View {

    // MARK: 公开参数（standard 布局通用，兼容历史调用点）

    let style: AldeloAlertStyle            // 样式（图标 + 颜色语义）
    let title: String                      // 主标题（必填）
    var message: String? = nil             // 副标题说明文本（可选）
    var confirmTitle: String = "Confirm"   // 确认按钮文字
    var cancelTitle: String = "Cancel"     // 取消按钮文字
    var confirmColor: Color? = nil         // 确认按钮底色（nil 则用样式默认色）
    var showCancelButton: Bool = true      // 是否显示取消按钮（单按钮场景设 false）
    let onConfirm: () -> Void              // 点击确认回调
    var onCancel: (() -> Void)? = nil      // 点击取消 / 点遮罩回调
    let content: Content                   // 自定义内容区（@ViewBuilder，无则为 EmptyView）

    // MARK: 内部细节（语义工厂专用，均为 private，外部无法直接设置）

    private var layout: AldeloAlertLayout = .standard
    private var showStandardIcon: Bool = true              // standard 布局是否显示左侧图标
    private var confirmRole: AldeloAlertButtonRole = .primary  // 确认按钮角色
    private var confirmOnLeft: Bool = false                // 确认按钮是否在左（危险操作设计如此）
    private var dimsMaskBackground: Bool = true            // 是否自带半透明遮罩
    // 勾选框（destructive 删除组场景）
    private var checkboxText: String? = nil
    private var isCheckedBinding: Binding<Bool>? = nil
    // centeredNotice 双色副标题
    private var highlightLabel: String? = nil
    private var highlightValue: String? = nil
    private var highlightValueColor: Color? = nil
    // input 输入框
    private var inputTextBinding: Binding<String>? = nil
    private var inputPlaceholder: String = ""
    // 右上关闭叉回调
    private var onClose: (() -> Void)? = nil

    /// 确认按钮最终底色：优先外部传入色 → 角色色 → 样式默认色。
    private var resolvedConfirmColor: Color {
        confirmColor ?? confirmRole.background
    }

    // MARK: 主体

    var body: some View {
        ZStack {
            if dimsMaskBackground {
                AppColors.mask
                    .ignoresSafeArea()
                    .onTapGesture { (onCancel ?? onClose ?? onConfirm)() }
            }

            switch layout {
            case .standard:       standardCard
            case .centeredNotice: centeredNoticeCard
            case .input:          inputCard
            }
        }
    }

    // MARK: - 默认布局（(图标) + 标题 / 内容 / 底部按钮）

    private var standardCard: some View {
        VStack(alignment: .leading, spacing: Spacing.lg) {
            // (可选图标) + 标题
            HStack(alignment: .top, spacing: Spacing.sm) {
                if showStandardIcon {
                    Image(systemName: style.iconName)
                        .font(.system(size: 24))
                        .foregroundColor(style.iconColor)
                }
                Text(title)
                    .font(AppFont.tabletH3Medium)
                    .foregroundColor(AppColors.textPrimary)
            }

            // 副标题说明
            if let message {
                Text(message)
                    .font(AppFont.tabletBody3Regular)
                    .foregroundColor(AppColors.textSecondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

            // 勾选框（删除组场景）
            if let checkboxText, let isCheckedBinding {
                checkboxRow(text: checkboxText, isOn: isCheckedBinding)
            }

            // 自定义内容
            if Content.self != EmptyView.self {
                content
            }

            // 底部按钮行
            actionRow
        }
        .padding(Spacing.xl)
        .frame(maxWidth: 480)
        .background(cardBackground)
    }

    // MARK: - 居中提示布局（右上关闭叉 + 圆形图标 + 双色副标题 + 居中大标题）

    private var centeredNoticeCard: some View {
        VStack(spacing: Spacing.md) {
            // 实心圆 + 白色感叹号
            ZStack {
                Circle()
                    .fill(style.iconColor)
                    .frame(width: 64, height: 64)
                Image(systemName: "exclamationmark")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(AppColors.white100)
            }
            .padding(.top, Spacing.sm)

            // 双色副标题：灰色说明 + 高亮数值（一行内两色）
            if let highlightLabel {
                (
                    Text(highlightLabel + " ")
                        .foregroundColor(AppColors.textSecondary)
                    + Text(highlightValue ?? "")
                        .foregroundColor(highlightValueColor ?? style.iconColor)
                )
                .font(AppFont.tabletH4Medium)
                .multilineTextAlignment(.center)
            }

            // 主标题（居中加粗）
            Text(title)
                .font(AppFont.tabletH2Medium)
                .foregroundColor(AppColors.textPrimary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(Spacing.xl)
        .frame(maxWidth: 480)
        .background(cardBackground)
        .overlay(alignment: .topTrailing) { closeButton }
    }

    // MARK: - 输入布局（右上关闭叉 + 标题 + 输入框 + 分隔线 + 底部按钮）

    private var inputCard: some View {
        VStack(alignment: .leading, spacing: Spacing.lg) {
            Text(title)
                .font(AppFont.tabletH1Medium)
                .foregroundColor(AppColors.textPrimary)

            if let inputTextBinding {
                TextField(inputPlaceholder, text: inputTextBinding)
                    .font(AppFont.tabletBody1Regular)
                    .foregroundColor(AppColors.textPrimary)
                    .tint(AppColors.theme)
                    .autocorrectionDisabled()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .frame(height: 60)
                    .padding(.horizontal, Spacing.md)
                    .background(
                        RoundedRectangle(cornerRadius: AppRadius.Tablet.md, style: .continuous)
                            .fill(AppColors.buttonSecondaryBg)
                    )
            }

            AppColors.line.frame(height: 1)

            actionRow
        }
        .padding(Spacing.xl)
        .frame(maxWidth: 540)
        .background(cardBackground)
        .overlay(alignment: .topTrailing) { closeButton }
    }

    // MARK: - 复用零件

    /// 底部按钮行：根据 confirmOnLeft 决定左右顺序；showCancelButton 决定是否双按钮。
    private var actionRow: some View {
        HStack(spacing: Spacing.md) {
            if showCancelButton {
                if confirmOnLeft {
                    confirmButton
                    cancelButton
                } else {
                    cancelButton
                    confirmButton
                }
            } else {
                confirmButton
            }
        }
    }

    private var confirmButton: some View {
        Button(action: onConfirm) {
            Text(confirmTitle)
                .font(AppFont.tabletButton3Medium)
                .foregroundColor(confirmRole.foreground)
                .frame(maxWidth: .infinity)
                .frame(height: 64)
                .background(
                    RoundedRectangle(cornerRadius: AppRadius.Tablet.lg)
                        .fill(resolvedConfirmColor)
                )
        }
        .buttonStyle(.plain)
    }

    private var cancelButton: some View {
        Button(action: { (onCancel ?? onClose ?? {})() }) {
            Text(cancelTitle)
                .font(AppFont.tabletButton3Medium)
                .foregroundColor(AppColors.buttonSecondaryText)
                .frame(maxWidth: .infinity)
                .frame(height: 64)
                .background(
                    RoundedRectangle(cornerRadius: AppRadius.Tablet.lg)
                        .fill(AppColors.buttonSecondaryBg)
                )
        }
        .buttonStyle(.plain)
    }

    private func checkboxRow(text: String, isOn: Binding<Bool>) -> some View {
        Button(action: { isOn.wrappedValue.toggle() }) {
            HStack(spacing: Spacing.sm) {
                Image(systemName: isOn.wrappedValue ? "checkmark.square.fill" : "square")
                    .font(.system(size: 22))
                    .foregroundColor(isOn.wrappedValue ? AppColors.theme : AppColors.textSecondary)
                Text(text)
                    .font(AppFont.tabletBody3Regular)
                    .foregroundColor(AppColors.textPrimary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .buttonStyle(.plain)
    }

    private var closeButton: some View {
        Button(action: { (onClose ?? onCancel ?? onConfirm)() }) {
            Image(systemName: "xmark")
                .font(.system(size: 20, weight: .medium))
                .foregroundColor(AppColors.textPrimary)
                .padding(Spacing.md)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    private var cardBackground: some View {
        RoundedRectangle(cornerRadius: AppRadius.Tablet.lg)
            .fill(AppColors.card)
            .shadow(color: AppColors.black20, radius: 16, y: 4)
    }
}

// MARK: - 历史兼容构造器（standard 布局，保留原签名，现有调用点无需改动）

extension AldeloAlert where Content == EmptyView {
    /// 简单弹窗（仅标题 + 可选 message）。等价于旧版用法。
    init(
        style: AldeloAlertStyle,
        title: String,
        message: String? = nil,
        confirmTitle: String = "Confirm",
        cancelTitle: String = "Cancel",
        confirmColor: Color? = nil,
        showCancelButton: Bool = true,
        onConfirm: @escaping () -> Void,
        onCancel: (() -> Void)? = nil
    ) {
        self.style = style
        self.title = title
        self.message = message
        self.confirmTitle = confirmTitle
        self.cancelTitle = cancelTitle
        self.confirmColor = confirmColor
        self.showCancelButton = showCancelButton
        self.onConfirm = onConfirm
        self.onCancel = onCancel
        self.content = EmptyView()
    }
}

extension AldeloAlert {
    /// 自定义内容弹窗（支持富文本、规则列表等复杂布局）。
    init(
        style: AldeloAlertStyle,
        title: String,
        confirmTitle: String = "Confirm",
        cancelTitle: String = "Cancel",
        confirmColor: Color? = nil,
        showCancelButton: Bool = true,
        onConfirm: @escaping () -> Void,
        onCancel: (() -> Void)? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.style = style
        self.title = title
        self.message = nil
        self.confirmTitle = confirmTitle
        self.cancelTitle = cancelTitle
        self.confirmColor = confirmColor
        self.showCancelButton = showCancelButton
        self.onConfirm = onConfirm
        self.onCancel = onCancel
        self.content = content()
    }
}

// MARK: - 语义工厂（推荐入口，覆盖全部设计稿）

extension AldeloAlert where Content == EmptyView {

    /// 1. 确认弹窗：标题 + [Cancel | Confirm(蓝)]。轻量操作确认。
    static func confirm(
        title: String,
        confirmTitle: String = "Confirm",
        cancelTitle: String = "Cancel",
        onConfirm: @escaping () -> Void,
        onCancel: (() -> Void)? = nil
    ) -> AldeloAlert {
        var a = AldeloAlert(style: .info, title: title, confirmTitle: confirmTitle,
                            cancelTitle: cancelTitle, onConfirm: onConfirm, onCancel: onCancel)
        a.showStandardIcon = false
        a.confirmRole = .primary
        a.confirmOnLeft = false
        return a
    }

    /// 2. 危险操作弹窗：(可带⚠️图标/副标题/勾选) + [Confirm(红) | Cancel]。
    /// - showIcon: 是否显示黄色⚠️图标（Delete Group 场景为 true）。
    /// - subtitle / checkboxText + isChecked：删除组场景的说明与勾选框。
    static func destructive(
        title: String,
        subtitle: String? = nil,
        showIcon: Bool = false,
        checkboxText: String? = nil,
        isChecked: Binding<Bool>? = nil,
        confirmTitle: String = "Confirm",
        cancelTitle: String = "Cancel",
        onConfirm: @escaping () -> Void,
        onCancel: (() -> Void)? = nil
    ) -> AldeloAlert {
        var a = AldeloAlert(style: .warning, title: title, message: subtitle,
                            confirmTitle: confirmTitle, cancelTitle: cancelTitle,
                            onConfirm: onConfirm, onCancel: onCancel)
        a.showStandardIcon = showIcon
        a.confirmRole = .destructive
        a.confirmOnLeft = true
        a.checkboxText = checkboxText
        a.isCheckedBinding = isChecked
        return a
    }

    /// 3. 单按钮弹窗：标题 + [单个全宽按钮]。Done / 提醒类。
    static func single(
        title: String,
        buttonTitle: String = "Done",
        role: AldeloAlertButtonRole = .primary,
        showIcon: Bool = false,
        style: AldeloAlertStyle = .notice,
        onTap: @escaping () -> Void
    ) -> AldeloAlert {
        var a = AldeloAlert(style: style, title: title, confirmTitle: buttonTitle,
                            showCancelButton: false, onConfirm: onTap)
        a.showStandardIcon = showIcon
        a.confirmRole = role
        return a
    }

    /// 4. 居中强提醒：右上✕ + 居中红圆! + 双色副标题 + 居中大标题（无底部按钮）。
    static func centeredNotice(
        style: AldeloAlertStyle = .error,
        title: String,
        highlightLabel: String? = nil,
        highlightValue: String? = nil,
        highlightValueColor: Color? = nil,
        onClose: @escaping () -> Void
    ) -> AldeloAlert {
        var a = AldeloAlert(style: style, title: title, showCancelButton: false,
                            onConfirm: onClose, onCancel: onClose)
        a.layout = .centeredNotice
        a.highlightLabel = highlightLabel
        a.highlightValue = highlightValue
        a.highlightValueColor = highlightValueColor
        a.onClose = onClose
        return a
    }

    /// 5. 输入框弹窗：右上✕ + 标题 + 输入框 + 分隔线 + [Cancel | Confirm(蓝)]。
    static func input(
        title: String,
        text: Binding<String>,
        placeholder: String = "",
        confirmTitle: String = "Confirm",
        cancelTitle: String = "Cancel",
        onConfirm: @escaping () -> Void,
        onCancel: (() -> Void)? = nil
    ) -> AldeloAlert {
        var a = AldeloAlert(style: .info, title: title, confirmTitle: confirmTitle,
                            cancelTitle: cancelTitle, onConfirm: onConfirm, onCancel: onCancel)
        a.layout = .input
        a.confirmRole = .primary
        a.inputTextBinding = text
        a.inputPlaceholder = placeholder
        a.onClose = onCancel
        return a
    }
}

// MARK: - 内部：嵌入全局宿主时关闭自带遮罩（AppUIManager 已提供 zIndex:20 遮罩层）

extension AldeloAlert {
    /// 供 AppUIManager 全局入口使用：关闭组件自带遮罩，避免与宿主遮罩叠加成双层。
    fileprivate func withoutOwnMask() -> AldeloAlert {
        var copy = self
        copy.dimsMaskBackground = false
        return copy
    }
}

// MARK: - 全局一行式调用（AppUIManager 底层实现）
//
// 这是全局弹窗的底层实现。业务方推荐用环境入口 \.alert（见文件末尾）：
//     @Environment(\.alert) private var alert
//     alert.confirm(title: "Setup Printer Now?") { setup() }
// 也可直接用 AppUIManager（等价，但要写出类型名）：
//     @Environment(AppUIManager.self) private var ui
//     ui.confirm(title: "Setup Printer Now?") { setup() }
//
// 每个方法对应一个语义工厂，点击后自动 dismissAlert() 再执行业务回调。

extension AppUIManager {

    /// 1. 确认弹窗：[Cancel | Confirm(蓝)]。
    func confirm(
        title: String,
        confirmTitle: String = "Confirm",
        cancelTitle: String = "Cancel",
        onConfirm: @escaping () -> Void,
        onCancel: (() -> Void)? = nil
    ) {
        showAlert {
            AldeloAlert.confirm(
                title: title, confirmTitle: confirmTitle, cancelTitle: cancelTitle,
                onConfirm: { [weak self] in self?.dismissAlert(); onConfirm() },
                onCancel: { [weak self] in self?.dismissAlert(); onCancel?() }
            )
            .withoutOwnMask()
            .frame(maxWidth: 480)
        }
    }

    /// 2. 危险操作弹窗：[Confirm(红) | Cancel]，可带⚠️图标 / 副标题 / 勾选框。
    /// 勾选框场景下 onConfirm 回传当前勾选状态。
    func destructive(
        title: String,
        subtitle: String? = nil,
        showIcon: Bool = false,
        checkboxText: String? = nil,
        checkboxDefaultOn: Bool = false,
        confirmTitle: String = "Confirm",
        cancelTitle: String = "Cancel",
        onConfirm: @escaping (_ isChecked: Bool) -> Void,
        onCancel: (() -> Void)? = nil
    ) {
        // 有勾选框：交给持有 @State 的包装视图，确保点击勾选能正确重绘
        //（普通引用盒写值不会触发 SwiftUI 刷新，勾选框会点了不变色）。
        if let checkboxText {
            showAlert {
                GlobalDestructiveCheckboxAlert(
                    title: title, subtitle: subtitle, showIcon: showIcon,
                    checkboxText: checkboxText, defaultOn: checkboxDefaultOn,
                    confirmTitle: confirmTitle, cancelTitle: cancelTitle,
                    onConfirm: { [weak self] checked in self?.dismissAlert(); onConfirm(checked) },
                    onCancel: { [weak self] in self?.dismissAlert(); onCancel?() }
                )
            }
        } else {
            // 无勾选框：无内部可变状态，直接构造即可。
            showAlert {
                AldeloAlert.destructive(
                    title: title, subtitle: subtitle, showIcon: showIcon,
                    confirmTitle: confirmTitle, cancelTitle: cancelTitle,
                    onConfirm: { [weak self] in self?.dismissAlert(); onConfirm(false) },
                    onCancel: { [weak self] in self?.dismissAlert(); onCancel?() }
                )
                .withoutOwnMask()
                .frame(maxWidth: 480)
            }
        }
    }

    /// 3. 单按钮弹窗：[单个全宽按钮]。Done / 提醒类。
    func single(
        title: String,
        buttonTitle: String = "Done",
        role: AldeloAlertButtonRole = .primary,
        showIcon: Bool = false,
        style: AldeloAlertStyle = .notice,
        onTap: (() -> Void)? = nil
    ) {
        showAlert {
            AldeloAlert.single(
                title: title, buttonTitle: buttonTitle, role: role,
                showIcon: showIcon, style: style,
                onTap: { [weak self] in self?.dismissAlert(); onTap?() }
            )
            .withoutOwnMask()
            .frame(maxWidth: 480)
        }
    }

    /// 4. 居中强提醒：右上✕ + 红圆! + 双色副标题 + 居中大标题。
    func errorNotice(
        style: AldeloAlertStyle = .error,
        title: String,
        highlightLabel: String? = nil,
        highlightValue: String? = nil,
        highlightValueColor: Color? = nil,
        onClose: (() -> Void)? = nil
    ) {
        showAlert {
            AldeloAlert.centeredNotice(
                style: style, title: title,
                highlightLabel: highlightLabel, highlightValue: highlightValue,
                highlightValueColor: highlightValueColor,
                onClose: { [weak self] in self?.dismissAlert(); onClose?() }
            )
            .withoutOwnMask()
            .frame(maxWidth: 480)
        }
    }

    /// 5. 输入框弹窗：右上✕ + 标题 + 输入框 + 分隔线 + [Cancel | Confirm(蓝)]。
    /// onConfirm 回传输入框最终文本。
    func inputAlert(
        title: String,
        text: String = "",
        placeholder: String = "",
        confirmTitle: String = "Confirm",
        cancelTitle: String = "Cancel",
        onConfirm: @escaping (_ text: String) -> Void,
        onCancel: (() -> Void)? = nil
    ) {
        // 交给持有 @State 的包装视图，确保 TextField 写入能正确重绘并回读最终文本。
        showAlert {
            GlobalInputAlert(
                title: title, initialText: text, placeholder: placeholder,
                confirmTitle: confirmTitle, cancelTitle: cancelTitle,
                onConfirm: { [weak self] value in self?.dismissAlert(); onConfirm(value) },
                onCancel: { [weak self] in self?.dismissAlert(); onCancel?() }
            )
        }
    }
}

// MARK: - 内部：持有 @State 的全局弹窗包装视图

/// 全局 destructive（带勾选框）包装：用 @State 持有勾选状态，保证点击能重绘。
private struct GlobalDestructiveCheckboxAlert: View {
    let title: String
    let subtitle: String?
    let showIcon: Bool
    let checkboxText: String
    let defaultOn: Bool
    let confirmTitle: String
    let cancelTitle: String
    let onConfirm: (Bool) -> Void
    let onCancel: () -> Void

    @State private var isChecked: Bool

    init(title: String, subtitle: String?, showIcon: Bool, checkboxText: String,
         defaultOn: Bool, confirmTitle: String, cancelTitle: String,
         onConfirm: @escaping (Bool) -> Void, onCancel: @escaping () -> Void) {
        self.title = title; self.subtitle = subtitle; self.showIcon = showIcon
        self.checkboxText = checkboxText; self.defaultOn = defaultOn
        self.confirmTitle = confirmTitle; self.cancelTitle = cancelTitle
        self.onConfirm = onConfirm; self.onCancel = onCancel
        _isChecked = State(initialValue: defaultOn)
    }

    var body: some View {
        AldeloAlert.destructive(
            title: title, subtitle: subtitle, showIcon: showIcon,
            checkboxText: checkboxText, isChecked: $isChecked,
            confirmTitle: confirmTitle, cancelTitle: cancelTitle,
            onConfirm: { onConfirm(isChecked) }, onCancel: onCancel
        )
        .withoutOwnMask()
        .frame(maxWidth: 480)
    }
}

/// 全局 input 包装：用 @State 持有输入文本，保证 TextField 正确重绘并回读。
private struct GlobalInputAlert: View {
    let title: String
    let placeholder: String
    let confirmTitle: String
    let cancelTitle: String
    let onConfirm: (String) -> Void
    let onCancel: () -> Void

    @State private var text: String

    init(title: String, initialText: String, placeholder: String,
         confirmTitle: String, cancelTitle: String,
         onConfirm: @escaping (String) -> Void, onCancel: @escaping () -> Void) {
        self.title = title; self.placeholder = placeholder
        self.confirmTitle = confirmTitle; self.cancelTitle = cancelTitle
        self.onConfirm = onConfirm; self.onCancel = onCancel
        _text = State(initialValue: initialText)
    }

    var body: some View {
        AldeloAlert.input(
            title: title, text: $text, placeholder: placeholder,
            confirmTitle: confirmTitle, cancelTitle: cancelTitle,
            onConfirm: { onConfirm(text) }, onCancel: onCancel
        )
        .withoutOwnMask()
        .frame(maxWidth: 540)
    }
}

// MARK: - 环境入口 \.alert（推荐：任意 View 一行取、一行用）
//
//     @Environment(\.alert) private var alert
//     ...
//     alert.confirm(title: "Clear All?") { clearAll() }
//
// 只暴露 alert 能力（不暴露整个 AppUIManager），是 SwiftUI 官方 \.dismiss / \.openURL 同款模式。

/// 轻量 alert 呈现器：转发到环境中的 AppUIManager。无宿主时所有方法为安全空操作。
/// 注意：struct 本身不标 @MainActor（仅持有引用，需在 nonisolated 的 EnvironmentKey.defaultValue 中实例化）；
/// 只有真正调用 AppUIManager 的转发方法标 @MainActor。
struct AlertPresenter {
    private let manager: AppUIManager?

    init(manager: AppUIManager? = nil) {
        self.manager = manager
    }

    @MainActor
    func confirm(
        title: String,
        confirmTitle: String = "Confirm",
        cancelTitle: String = "Cancel",
        onConfirm: @escaping () -> Void,
        onCancel: (() -> Void)? = nil
    ) {
        manager?.confirm(title: title, confirmTitle: confirmTitle, cancelTitle: cancelTitle,
                         onConfirm: onConfirm, onCancel: onCancel)
    }

    @MainActor
    func destructive(
        title: String,
        subtitle: String? = nil,
        showIcon: Bool = false,
        checkboxText: String? = nil,
        checkboxDefaultOn: Bool = false,
        confirmTitle: String = "Confirm",
        cancelTitle: String = "Cancel",
        onConfirm: @escaping (_ isChecked: Bool) -> Void,
        onCancel: (() -> Void)? = nil
    ) {
        manager?.destructive(title: title, subtitle: subtitle, showIcon: showIcon,
                             checkboxText: checkboxText, checkboxDefaultOn: checkboxDefaultOn,
                             confirmTitle: confirmTitle, cancelTitle: cancelTitle,
                             onConfirm: onConfirm, onCancel: onCancel)
    }

    @MainActor
    func single(
        title: String,
        buttonTitle: String = "Done",
        role: AldeloAlertButtonRole = .primary,
        showIcon: Bool = false,
        style: AldeloAlertStyle = .notice,
        onTap: (() -> Void)? = nil
    ) {
        manager?.single(title: title, buttonTitle: buttonTitle, role: role,
                        showIcon: showIcon, style: style, onTap: onTap)
    }

    @MainActor
    func errorNotice(
        style: AldeloAlertStyle = .error,
        title: String,
        highlightLabel: String? = nil,
        highlightValue: String? = nil,
        highlightValueColor: Color? = nil,
        onClose: (() -> Void)? = nil
    ) {
        manager?.errorNotice(style: style, title: title,
                             highlightLabel: highlightLabel, highlightValue: highlightValue,
                             highlightValueColor: highlightValueColor, onClose: onClose)
    }

    @MainActor
    func inputAlert(
        title: String,
        text: String = "",
        placeholder: String = "",
        confirmTitle: String = "Confirm",
        cancelTitle: String = "Cancel",
        onConfirm: @escaping (_ text: String) -> Void,
        onCancel: (() -> Void)? = nil
    ) {
        manager?.inputAlert(title: title, text: text, placeholder: placeholder,
                            confirmTitle: confirmTitle, cancelTitle: cancelTitle,
                            onConfirm: onConfirm, onCancel: onCancel)
    }
}

private struct AlertPresenterKey: EnvironmentKey {
    // 默认无宿主：方法均为空操作，未注入时不会崩溃（仅不弹窗）。
    static let defaultValue = AlertPresenter()
}

extension EnvironmentValues {
    /// 全局 alert 呈现器。由 BaseViewContainer 注入真实 AppUIManager。
    var alert: AlertPresenter {
        get { self[AlertPresenterKey.self] }
        set { self[AlertPresenterKey.self] = newValue }
    }
}

// MARK: - Previews

#Preview("1. Confirm") {
    AldeloAlert.confirm(title: "Setup Printer Now?", onConfirm: {}, onCancel: {})
        .padding().background(AppColors.pageBg)
}

#Preview("2a. Destructive - Clear All") {
    AldeloAlert.destructive(title: "Clear All?", onConfirm: {}, onCancel: {})
        .padding().background(AppColors.pageBg)
}

#Preview("2b. Destructive - Delete Group") {
    AldeloAlert.destructive(
        title: "Delete Burgers & Sandwiches Group?",
        subtitle: "5 Items Exist Under This Group.",
        showIcon: true,
        checkboxText: "Permanently Delete All 5 Items",
        isChecked: .constant(true),
        confirmTitle: "Delete",
        onConfirm: {}, onCancel: {}
    )
    .padding().background(AppColors.pageBg)
}

#Preview("3. Single - Done") {
    AldeloAlert.single(
        title: "Please turn off all lights before ending the day.",
        buttonTitle: "Done", showIcon: true, onTap: {}
    )
    .padding().background(AppColors.pageBg)
}

#Preview("4. Centered Notice") {
    AldeloAlert.centeredNotice(
        title: "Not Enough Cash for Tip Out",
        highlightLabel: "Cash Drawer Balance:",
        highlightValue: "$3.00",
        onClose: {}
    )
    .padding().background(AppColors.pageBg)
}

#Preview("5. Input - Edit Tab Name") {
    AldeloAlert.input(
        title: "Edit Tab Name",
        text: .constant("Sophia"),
        placeholder: "Name",
        onConfirm: {}, onCancel: {}
    )
    .padding().background(AppColors.pageBg)
}

#Preview("兼容 - 旧构造器 Notice") {
    AldeloAlert(
        style: .notice,
        title: "Please reset all count down item qty to 100 before ending the day.",
        confirmTitle: "Done",
        showCancelButton: false,
        onConfirm: {}
    )
    .padding().background(AppColors.pageBg)
}
