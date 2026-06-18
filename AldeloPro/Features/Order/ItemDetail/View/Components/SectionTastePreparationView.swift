//
//  SectionTastePreparationView.swift
//  AldeloPro
//
//  Created by Sen on 2026/06/10.
//

import SwiftUI

// MARK: - 口味与备餐定制段落组件

/// 展示 "Taste & Preparation" 标题 + 项目符号列表
/// 每行以实心圆点 "•" 开头，垂直左边缘对齐
struct SectionTastePreparationView: View {
    /// 定制化规格属性列表（如口味、温度、甜度等）
    let items: [String]
    /// 是否为 iPad 环境
    let isPad: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: isPad ? Spacing.sm : Spacing.xs) {
            // 段落标题
            Text("Taste & Preparation")
                .font(isPad ? AppFont.tabletH3Medium : AppFont.mobileH3Medium)
                .foregroundStyle(AppColors.textPrimary)

            // 项目符号列表
            VStack(alignment: .leading, spacing: isPad ? Spacing.xs : Spacing.xxs) {
                ForEach(Array(items.enumerated()), id: \.offset) { _, item in
                    bulletRow(text: item)
                }
            }
        }
        .padding(.horizontal, isPad ? Spacing.lg : Spacing.md)
    }

    // MARK: - 单行项目符号

    /// 实心圆点 + 规格文本的水平排列行
    private func bulletRow(text: String) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: isPad ? Spacing.sm : Spacing.xs) {
            // 实心黑色圆点符号
            Text("\u{2022}")
                .font(isPad ? AppFont.tabletBody1Regular : AppFont.mobileBody1Regular)
                .foregroundStyle(AppColors.textPrimary)

            // 规格描述文本
            Text(text)
                .font(isPad ? AppFont.tabletBody1Regular : AppFont.mobileBody1Regular)
                .lineSpacing(isPad ? AppLineHeight.tabletBody1Regular - 21 : AppLineHeight.mobileBody1Regular - 10.5)
                .foregroundStyle(AppColors.textSecondary)
        }
    }
}
