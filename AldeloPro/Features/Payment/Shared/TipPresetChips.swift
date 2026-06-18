//
//  TipPresetChips.swift
//  AldeloPro
//
//  Created by Sen on 2026/06/03.
//

import SwiftUI

// MARK: - TipPresetChips

/// 小费快捷选择按钮组 — 横向排列的胶囊形快捷选项
///
/// 用于 Gratuity、Adjust Tip 页面，显示如 "$5.00"、"$10.00"、"10%"、"20%" 等
/// 预设值供用户一键选择。
struct TipPresetChips: View {

    /// 每个 Chip 显示的文字（如 ["$5.00", "$10.00", "$20.00"]）
    let titles: [String]

    /// 是否为平板布局
    let isTablet: Bool

    /// 选中某个 Chip 时的回调（返回对应的 title 文字）
    let onSelect: (String) -> Void

    var body: some View {
        HStack(spacing: Spacing.xs) {
            ForEach(titles, id: \.self) { title in
                Button(action: { onSelect(title) }) {
                    Text(title)
                        .font(isTablet ? AppFont.tabletH4Medium : AppFont.mobileButton3Medium)
                        .foregroundColor(AppColors.textPrimary)
                        .padding(.horizontal, Spacing.md)
                        .frame(height: isTablet ? 43 : 36)
                        .background(AppColors.white100)
                        .overlay(
                            Capsule()
                                .stroke(AppColors.line, lineWidth: 1)
                        )
                        .clipShape(Capsule())
                }
            }
        }
    }
}
