//
//  TipInputModeToggle.swift
//  AldeloPro
//
//  Created by Sen on 2026/06/03.
//

import SwiftUI

// MARK: - TipInputModeToggle

/// 小费输入模式切换器 — Amount / Percentage 分段选择
///
/// 用于 Gratuity、Adjust Tip 等页面顶部，切换"按金额"或"按百分比"输入模式。
/// 选中态为白底蓝字，未选中为透明灰字。
struct TipInputModeToggle: View {

    /// 所有可选模式的标签文字（如 ["Amount", "Percentage"]）
    let modes: [String]

    /// 当前选中的模式文字
    let selectedMode: String

    /// 是否为平板布局
    let isTablet: Bool

    /// 选中某个模式时的回调
    let onSelect: (String) -> Void

    var body: some View {
        HStack(spacing: 0) {
            ForEach(modes, id: \.self) { mode in
                Button(action: { onSelect(mode) }) {
                    Text(mode)
                        .font(isTablet ? AppFont.tabletH3Medium : AppFont.mobileButton2Medium)
                        .foregroundColor(
                            selectedMode == mode
                                ? AppColors.primaryNormal
                                : AppColors.black60
                        )
                        .frame(maxWidth: .infinity)
                        .frame(height: isTablet ? 56 : 44)
                        .background(
                            selectedMode == mode
                                ? AppColors.white100
                                : Color.clear
                        )
                        .clipShape(RoundedRectangle(cornerRadius: AppRadius.Tablet.xs))
                }
            }
        }
        .padding(Spacing.xxs)
        .background(AppColors.segmentBg)
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.Tablet.sm))
        .frame(width: isTablet ? 403 : nil)
    }
}
