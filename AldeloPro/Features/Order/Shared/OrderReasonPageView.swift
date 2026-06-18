//
//  OrderReasonPageView.swift
//  AldeloPro
//
//  Created by Sen on 2026/06/03.
//

import SwiftUI

// MARK: - OrderReasonPageView

/// 订单原因输入页面 — Deny Order / Void Order 共用的完整页面模板
///
/// 包含以下区域（从上到下）：
/// 1. HeaderBar — 页面标题 + Back/Confirm 按钮
/// 2. 区域标题（如 "Deny Reason" / "Void Reason"）
/// 3. 自定义原因文本输入框（可滚动，支持长文本）
/// 4. 预设原因 Chip 列表（WrappingHFlowLayout 自动换行）
///
/// 响应式适配：
/// - iPad / iPhone 横屏（regular）: 大字号，内容区宽度 960pt 按比例缩放
/// - iPhone 竖屏（compact）: 小字号，内容区满宽 + padding
///
/// 调用方只需传入文案配置和回调，无需关心布局细节：
/// ```swift
/// OrderReasonPageView(
///     pageTitle: "Deny Order",
///     sectionTitle: "Deny Reason",
///     placeholder: "Custom Deny Reason About This Order",
///     presetReasons: viewModel.presetReasons,
///     ...
/// )
/// ```
struct OrderReasonPageView: View {

    // MARK: - 配置参数

    /// 顶部导航栏标题（如 "Deny Order"、"Void Order"）
    let pageTitle: String

    /// 内容区标题（如 "Deny Reason"、"Void Reason"）
    let sectionTitle: String

    /// 文本输入框占位文字
    let placeholder: String

    /// 预设原因列表
    let presetReasons: [String]

    /// 当前选中的预设原因（nil 表示未选中）
    let selectedReason: String?

    /// 输入框显示的文本（选中预设时显示预设文本，否则显示用户输入）
    let displayedInputText: String

    /// Confirm 按钮是否可点击
    let canConfirm: Bool

    // MARK: - 回调

    /// 点击 Back 按钮
    let onBack: () -> Void

    /// 点击 Confirm 按钮
    let onConfirm: () -> Void

    /// 选择/取消选择某个预设原因
    let onSelectReason: (String) -> Void

    /// 用户手动编辑文本框内容
    let onUpdateCustomReason: (String) -> Void

    // MARK: - Environment

    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    // MARK: - Focus

    @FocusState private var isTextFieldFocused: Bool

    // MARK: - 计算属性

    /// 是否为 iPhone 竖屏紧凑布局
    private var isCompact: Bool {
        horizontalSizeClass == .compact
    }

    // MARK: - Body

    var body: some View {
        GeometryReader { geometry in
            let scaleFactor = geometry.size.width / 1440

            VStack(spacing: 0) {
                headerSection
                scrollContent(scaleFactor: scaleFactor)
            }
            .background(AppColors.pageBg)
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
    }

    // MARK: - 顶部导航栏

    private var headerSection: some View {
        // 迁移至通用 AldeloModalHeaderView（C 族）：图标+标题 LEFT，Back/Confirm RIGHT。
        AldeloModalHeaderView(
            leadingIcon: "doc.text",
            title: pageTitle,
            actions: [
                .back(onBack),
                .primary("Confirm", isEnabled: canConfirm, action: onConfirm)
            ]
        )
    }

    // MARK: - 滚动内容区

    private func scrollContent(scaleFactor: CGFloat) -> some View {
        ScrollView(.vertical, showsIndicators: true) {
            VStack(alignment: .leading, spacing: isCompact ? Spacing.md : Spacing.lg) {
                sectionTitleView
                textInputArea
                reasonChipsSection
            }
            .frame(
                width: isCompact ? nil : 960 * scaleFactor,
                alignment: .leading
            )
            .frame(maxWidth: .infinity)
            .padding(.horizontal, isCompact ? Spacing.md : 0)
            .padding(.top, isCompact ? Spacing.md : Spacing.lg)
        }
        .onTapGesture {
            isTextFieldFocused = false
        }
    }

    // MARK: - 区域标题

    private var sectionTitleView: some View {
        Text(sectionTitle)
            .font(isCompact ? AppFont.mobileH1Medium : AppFont.tabletH2Medium)
            .foregroundColor(AppColors.textPrimary)
    }

    // MARK: - 文本输入区

    /// 自定义原因输入框，固定高度，内容超出可内部滚动
    private var textInputArea: some View {
        ZStack(alignment: .topLeading) {
            RoundedRectangle(cornerRadius: AppRadius.Tablet.sm)
                .fill(AppColors.inputBg)
                .frame(height: isCompact ? 120 : 150)

            // 占位文字（输入为空时显示）
            if displayedInputText.isEmpty {
                Text(placeholder)
                    .font(isCompact ? AppFont.mobileBody1Regular : AppFont.tabletBody2Regular)
                    .foregroundColor(AppColors.inputPlaceholder)
                    .padding(.horizontal, Spacing.md)
                    .padding(.top, Spacing.md)
                    .allowsHitTesting(false)
            }

            // 实际输入区域（TextEditor 支持多行 + 内部滚动）
            TextEditor(text: textBinding)
                .font(isCompact ? AppFont.mobileBody1Regular : AppFont.tabletBody2Regular)
                .foregroundColor(AppColors.textPrimary)
                .scrollContentBackground(.hidden)
                .padding(.horizontal, Spacing.sm)
                .padding(.vertical, Spacing.sm)
                .frame(height: isCompact ? 120 : 150)
                .focused($isTextFieldFocused)
        }
    }

    private var textBinding: Binding<String> {
        Binding(
            get: { displayedInputText },
            set: { onUpdateCustomReason($0) }
        )
    }

    // MARK: - 预设原因 Chip 列表

    /// 使用 WrappingHFlowLayout 自动换行，短文本并排、长文本独占一行
    private var reasonChipsSection: some View {
        WrappingHFlowLayout(spacing: isCompact ? Spacing.sm : Spacing.md) {
            ForEach(presetReasons, id: \.self) { reason in
                OrderReasonChip(
                    title: reason,
                    isSelected: selectedReason == reason,
                    isCompact: isCompact,
                    action: {
                        onSelectReason(reason)
                        isTextFieldFocused = false
                    }
                )
            }
        }
    }
}

// MARK: - Preview

#Preview("iPad") {
    OrderReasonPageView(
        pageTitle: "Deny Order",
        sectionTitle: "Deny Reason",
        placeholder: "Custom Deny Reason About This Order",
        presetReasons: ["Order Mistake", "Out Of Stock", "Restaurant Closing", "Customer Request", "Too Busy"],
        selectedReason: nil,
        displayedInputText: "",
        canConfirm: false,
        onBack: {},
        onConfirm: {},
        onSelectReason: { _ in },
        onUpdateCustomReason: { _ in }
    )
}

#Preview("iPhone") {
    OrderReasonPageView(
        pageTitle: "Void Order",
        sectionTitle: "Void Reason",
        placeholder: "Custom Void Reason About This Order",
        presetReasons: ["Order Mistake", "Out Of Stock", "Restaurant Closing"],
        selectedReason: "Order Mistake",
        displayedInputText: "Order Mistake",
        canConfirm: true,
        onBack: {},
        onConfirm: {},
        onSelectReason: { _ in },
        onUpdateCustomReason: { _ in }
    )
}
