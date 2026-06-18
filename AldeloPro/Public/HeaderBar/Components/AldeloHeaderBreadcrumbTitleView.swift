//
//  AldeloHeaderBreadcrumbTitleView.swift
//  AldeloPro
//
//  Created by Sen on 2026/06/12.
//

import SwiftUI

// MARK: - AldeloHeaderBreadcrumbTitleView
//
// 【作用】
// C 族「配置 / 弹窗栏」(`AldeloModalHeaderView`) 左侧的标题原子：
// 可选 leading 图标 + 可选面包屑前缀 + 当前标题。
//
// 【三种形态】
//   • 纯标题：           "Add Employee" / "Cashier"
//   • 带 leading 图标：  ↻ "Repeat" / 🛒 "Cashier" / ⏱ "Custom Prep Time"
//   • 面包屑：           "Add Item /"（灰色二级）+ "Select Option Group"（主标题一级）
//
// 【设计要点】
// - 面包屑前缀 `pathPrefix` 渲染为灰色 + 尾随斜杠，仅 iPad（Regular）显示；
//   iPhone（Compact）下自动隐藏前缀，只留当前标题，避免过长截断。
// - leading 图标用 SF Symbol 名传入，与标题同字号。
// - 标题 `lineLimit(1)`，超长截断。
//
// 【使用案例】
// ```swift
// // 1) 纯标题
// AldeloHeaderBreadcrumbTitleView(title: "Add Employee")
//
// // 2) 带 leading 图标
// AldeloHeaderBreadcrumbTitleView(leadingIcon: "cart", title: "Cashier")
// AldeloHeaderBreadcrumbTitleView(leadingIcon: "arrow.triangle.2.circlepath", title: "Repeat")
//
// // 3) 面包屑（前缀灰 + 斜杠，仅 iPad 显示前缀）
// AldeloHeaderBreadcrumbTitleView(pathPrefix: "Add Item", title: "Select Option Group")
// ```

struct AldeloHeaderBreadcrumbTitleView: View {

    @Environment(\.horizontalSizeClass) private var hSizeClass

    /// 可选 leading SF Symbol 名（如 "arrow.triangle.2.circlepath"）。
    var leadingIcon: String? = nil
    /// 可选面包屑前缀（如 "Add Item"），渲染为灰色 + 斜杠，仅 iPad 显示。
    var pathPrefix: String? = nil
    /// 当前页标题（如 "Select Option Group"）。
    let title: String
    /// 可选标题后缀次要文本（如餐品价格 "$12.00"），灰色弱化显示在标题右侧。
    var trailingText: String? = nil

    private var isCompact: Bool { hSizeClass == .compact }

    private var titleFont: Font {
        isCompact ? AppFont.mobileH1Medium : AppFont.tabletH1Medium
    }

    private var prefixFont: Font {
        isCompact ? AppFont.mobileH2Medium : AppFont.tabletH2Medium
    }

    var body: some View {
        HStack(spacing: Spacing.xs) {
            // leading 图标（可选）
            if let icon = leadingIcon {
                Image(systemName: icon)
                    .font(titleFont)
                    .foregroundColor(AppColors.textPrimary)
            }

            // 面包屑前缀仅在 iPad 显示（iPhone 竖屏省略，防截断）。
            if let prefix = pathPrefix, !isCompact {
                Text("\(prefix) /")
                    .font(prefixFont)
                    .foregroundColor(AppColors.textSecondary)
            }

            // 当前标题
            Text(title)
                .font(titleFont)
                .foregroundColor(AppColors.textPrimary)
                .lineLimit(1)

            // 标题后缀次要文本（如价格），灰色弱化
            if let trailingText {
                Text(trailingText)
                    .font(isCompact ? AppFont.mobileH3Medium : AppFont.tabletH4Medium)
                    .foregroundColor(AppColors.textSecondary)
                    .opacity(0.7)
            }
        }
    }
}
