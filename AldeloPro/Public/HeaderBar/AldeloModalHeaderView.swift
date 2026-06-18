//
//  AldeloModalHeaderView.swift
//  AldeloPro
//
//  Created by Sen on 2026/06/12.
//

import SwiftUI

// MARK: - AldeloModalHeaderView（形态 C：配置 / 弹窗栏）
//
// 对应 Add Employee / Add Item / Repeat / Cashier / Time Card / Custom Prep Time 等。结构：
//   leading  = AldeloHeaderBreadcrumbTitleView（可选图标 + 可选面包屑前缀 + 标题）
//   center   = 可选 AI 指令搜索条（aiState 非 nil 时显示，复用 A 族 AICommandField）
//   trailing = AldeloHeaderActionButtonsView（0 / 2 / 3 个按钮，支持禁用 + 角标）
//
// 覆盖三种按钮场景：
//   • 0 按钮：纯标题（Cashier、Confirmation Mode、Time Card、Custom Prep Time）
//   • 2 按钮：Back/Cancel + Save/Apply/Add（可禁用）
//   • 3 按钮：Back + All + Confirm（带角标）
// iPhone 竖屏：单行，面包屑前缀隐藏只留当前标题。
//
// 【AI 中心槽】部分配置页（如 Custom Prep Time、Order Action）在标题与按钮之间还有
// 一条 AI 语音搜索胶囊。传入 aiState 即在 center 渲染 AldeloHeaderAICommandFieldView；
// 默认 nil = 无 AI 条（保持纯标题/按钮版式）。

public struct AldeloModalHeaderView: View {

    private let leadingIcon: String?
    private let pathPrefix: String?
    private let title: String
    private let trailingText: String?
    private let actions: [AldeloHeaderAction]
    private let aiState: AICommandState?
    private let onCommandTap: (() -> Void)?
    private let onClose: (() -> Void)?
    /// 自定义 trailing 内容（最高优先级）。用于右侧需放非标准按钮组的场景，
    /// 如 CashCount 的「用户簇(头像+姓名+打卡) + Back」。传 nil 则按 actions/onClose 渲染。
    private let customTrailing: (() -> AnyView)?
    /// 顶栏背景色（nil = 默认白卡 AppColors.card；如 CashCount 用 pageBgDeep 与内容区融合）。
    private let background: Color?

    public init(
        leadingIcon: String? = nil,
        pathPrefix: String? = nil,
        title: String,
        trailingText: String? = nil,
        actions: [AldeloHeaderAction] = [],
        aiState: AICommandState? = nil,
        onCommandTap: (() -> Void)? = nil,
        onClose: (() -> Void)? = nil,
        customTrailing: (() -> AnyView)? = nil,
        background: Color? = nil
    ) {
        self.leadingIcon = leadingIcon
        self.pathPrefix = pathPrefix
        self.title = title
        self.trailingText = trailingText
        self.actions = actions
        self.aiState = aiState
        self.onCommandTap = onCommandTap
        self.onClose = onClose
        self.customTrailing = customTrailing
        self.background = background
    }

    public var body: some View {
        AldeloHeaderBarShellView(height: .standard, background: background ?? AppColors.card) {
            // 有 AI 中心槽时，center 按设计稿 391/1440 比例固定宽度并相对整条 header 居中；
            // 无 AI 槽（纯标题/按钮）时 ratio=nil，走默认 Spacer 布局（标题靠左、按钮靠右）。
            AldeloHeaderLayoutView(centerWidthRatio: aiState != nil ? 391.0 / 1440.0 : nil) {
                AldeloHeaderBreadcrumbTitleView(leadingIcon: leadingIcon, pathPrefix: pathPrefix, title: title, trailingText: trailingText)
            } center: {
                if let aiState {
                    AldeloHeaderAICommandFieldView(state: aiState, onTap: onCommandTap)
                } else {
                    EmptyView()
                }
            } trailing: {
                trailingContent
            }
        }
    }

    // trailing：优先渲染文字按钮组；若仅传 onClose（无 actions）则渲染右上角关闭 X。
    @ViewBuilder
    private var trailingContent: some View {
        if let customTrailing {
            customTrailing()
        } else if !actions.isEmpty {
            AldeloHeaderActionButtonsView(actions: actions)
        } else if let onClose {
            AldeloHeaderCloseButton(onClose: onClose)
        } else {
            EmptyView()
        }
    }
}

// MARK: - Previews

#Preview("iPad 纯标题（0 按钮）") {
    VStack(spacing: 0) {
        AldeloModalHeaderView(leadingIcon: "cart", title: "Cashier")
        Spacer()
    }
    .environment(\.horizontalSizeClass, .regular)
}

#Preview("iPad 两按钮 - Add Employee") {
    VStack(spacing: 0) {
        AldeloModalHeaderView(
            title: "Add Employee",
            actions: [.cancel({}), .primary("Save", action: {})]
        )
        Spacer()
    }
    .environment(\.horizontalSizeClass, .regular)
}

#Preview("iPad 面包屑 - Select Option Group") {
    VStack(spacing: 0) {
        AldeloModalHeaderView(
            pathPrefix: "Add Item",
            title: "Select Option Group",
            actions: [.back({}), .primary("Apply", action: {})]
        )
        Spacer()
    }
    .environment(\.horizontalSizeClass, .regular)
}

#Preview("iPad Add 禁用态") {
    VStack(spacing: 0) {
        AldeloModalHeaderView(
            title: "Add Item",
            actions: [.cancel({}), .primary("Add", isEnabled: false, action: {})]
        )
        Spacer()
    }
    .environment(\.horizontalSizeClass, .regular)
}

#Preview("iPad 三按钮 - Repeat（角标）") {
    VStack(spacing: 0) {
        AldeloModalHeaderView(
            leadingIcon: "arrow.triangle.2.circlepath",
            title: "Repeat",
            actions: [
                .back({}),
                AldeloHeaderAction(title: "All", style: .secondary, action: {}),
                .primary("Confirm", badge: 1, action: {})
            ]
        )
        Spacer()
    }
    .environment(\.horizontalSizeClass, .regular)
}

#Preview("iPad 纯标题 - Dark") {
    VStack(spacing: 0) {
        AldeloModalHeaderView(leadingIcon: "clock", title: "Custom Prep Time")
        Spacer()
    }
    .environment(\.horizontalSizeClass, .regular)
    .environment(\.colorScheme, .dark)
}

#Preview("iPhone 两按钮 - 单行") {
    VStack(spacing: 0) {
        AldeloModalHeaderView(
            pathPrefix: "Add Item",
            title: "Select Option Group",
            actions: [.back({}), .primary("Apply", action: {})]
        )
        Spacer()
    }
    .environment(\.horizontalSizeClass, .compact)
}
