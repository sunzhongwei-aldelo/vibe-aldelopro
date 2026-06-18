//
//  OrderReasonChip.swift
//  AldeloPro
//
//  Created by Sen on 2026/06/03.
//

import SwiftUI

// MARK: - OrderReasonChip

/// 订单操作原因选择器 — 胶囊形 Chip 按钮
///
/// 用于 Deny Order / Void Order 页面的预设原因选项。
/// 支持 iPad（regular）和 iPhone（compact）两种尺寸模式：
/// - iPad: 字号 24pt，高度 59pt
/// - iPhone: 字号 18pt，高度 44pt
///
/// 状态样式：
/// - 未选中: 白色背景 + 灰色描边 + 黑色文字
/// - 选中: 主题蓝 8% 背景 + 主题蓝 2px 描边 + 主题蓝文字
struct OrderReasonChip: View {

    /// 显示文本
    let title: String

    /// 是否处于选中状态
    let isSelected: Bool

    /// 是否使用紧凑布局（iPhone 竖屏）
    let isCompact: Bool

    /// 点击回调
    let action: () -> Void

    init(
        title: String,
        isSelected: Bool,
        isCompact: Bool = false,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.isSelected = isSelected
        self.isCompact = isCompact
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(isCompact ? AppFont.mobileH2Medium : AppFont.tabletH3Medium)
                .foregroundColor(
                    isSelected ? AppColors.primaryNormal : AppColors.textPrimary
                )
                .padding(.horizontal, isCompact ? Spacing.md : Spacing.lg)
                .frame(height: isCompact ? 44 : 59)
                .background(
                    isSelected
                        ? AppColors.primaryNormal.opacity(0.08)
                        : AppColors.white100
                )
                .clipShape(Capsule())
                .overlay(
                    Capsule()
                        .stroke(
                            isSelected ? AppColors.primaryNormal : AppColors.line,
                            lineWidth: isSelected ? 2 : 1
                        )
                )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preview

#Preview("Tablet - Unselected") {
    OrderReasonChip(title: "Order Mistake", isSelected: false, action: {})
        .padding()
        .background(AppColors.pageBg)
}

#Preview("Tablet - Selected") {
    OrderReasonChip(title: "Order Mistake", isSelected: true, action: {})
        .padding()
        .background(AppColors.pageBg)
}

#Preview("Compact") {
    OrderReasonChip(title: "Order Mistake", isSelected: false, isCompact: true, action: {})
        .padding()
        .background(AppColors.pageBg)
}
