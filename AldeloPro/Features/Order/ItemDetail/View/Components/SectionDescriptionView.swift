//
//  SectionDescriptionView.swift
//  AldeloPro
//
//  Created by Sen on 2026/06/10.
//

import SwiftUI

// MARK: - 商品描述段落组件

/// 展示 "Product Description" 标题 + 多行描述正文
/// 文本自适应撑开高度，次级灰色正文配合行高 Token
struct SectionDescriptionView: View {
    /// 商品描述正文内容
    let description: String
    /// 是否为 iPad 环境
    let isPad: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: isPad ? Spacing.sm : Spacing.xs) {
            // 段落标题
            Text("Product Description")
                .font(isPad ? AppFont.tabletH3Medium : AppFont.mobileH3Medium)
                .foregroundStyle(AppColors.textPrimary)

            // 描述正文（次级灰色，多行自适应）
            Text(description)
                .font(isPad ? AppFont.tabletBody1Regular : AppFont.mobileBody1Regular)
                .lineSpacing(isPad ? AppLineHeight.tabletBody1Regular - 21 : AppLineHeight.mobileBody1Regular - 10.5)
                .foregroundStyle(AppColors.textSecondary)
        }
        .padding(.horizontal, isPad ? Spacing.lg : Spacing.md)
    }
}
