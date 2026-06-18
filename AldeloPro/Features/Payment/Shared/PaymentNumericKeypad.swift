//
//  PaymentNumericKeypad.swift
//  AldeloPro
//
//  Created by Sen on 2026/06/03.
//

import SwiftUI

// MARK: - PaymentNumericKeypad

/// 支付模块通用数字键盘组件
///
/// 3x4 网格布局：数字 1-9 + 退格 + 0 + Clear。
/// 用于 Gratuity、Adjust Tip 等需要数字输入的弹窗场景。
///
/// 自适应尺寸：
/// - iPad（isTablet=true）: 按钮 150x122pt，字号 64pt
/// - iPhone（isTablet=false）: 按钮 80x64pt，字号 20pt
struct PaymentNumericKeypad: View {

    /// 是否为平板布局
    let isTablet: Bool

    /// 用户按下数字键（"0"-"9"）
    let onDigit: (String) -> Void

    /// 用户按下退格键
    let onDelete: () -> Void

    /// 用户按下 Clear 键
    let onClear: () -> Void

    // MARK: - 尺寸计算

    private var buttonWidth: CGFloat { isTablet ? 150 : 80 }
    private var buttonHeight: CGFloat { isTablet ? 122 : 64 }
    private var gridSpacing: CGFloat { Spacing.lg }

    // MARK: - Body

    var body: some View {
        VStack(spacing: gridSpacing) {
            // 数字 1-9（3行 x 3列）
            ForEach(0..<3, id: \.self) { row in
                HStack(spacing: gridSpacing) {
                    ForEach(1...3, id: \.self) { col in
                        let digit = String(row * 3 + col)
                        digitButton(digit)
                    }
                }
            }
            // 最后一行：退格 + 0 + Clear
            HStack(spacing: gridSpacing) {
                actionButton(icon: "delete.left", action: onDelete)
                digitButton("0")
                actionButton(text: "Clear", action: onClear)
            }
        }
    }

    // MARK: - 数字按钮

    private func digitButton(_ digit: String) -> some View {
        Button(action: { onDigit(digit) }) {
            Text(digit)
                .font(isTablet ? AppFont.tabletDisplay1Regular : AppFont.mobileDisplay1Medium)
                .foregroundColor(AppColors.textPrimary)
                .frame(width: buttonWidth, height: buttonHeight)
                .background(AppColors.card)
                .overlay(
                    RoundedRectangle(cornerRadius: AppRadius.Tablet.lg)
                        .stroke(AppColors.line, lineWidth: 1.4)
                )
                .clipShape(RoundedRectangle(cornerRadius: AppRadius.Tablet.lg))
        }
    }

    // MARK: - 功能按钮（退格/Clear）

    private func actionButton(
        icon: String? = nil,
        text: String? = nil,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Group {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(AppFont.tabletH2Medium)
                } else if let text = text {
                    Text(text)
                        .font(isTablet ? AppFont.tabletDisplay4Semibold : AppFont.mobileDisplay1Medium)
                }
            }
            .foregroundColor(AppColors.textPrimary)
            .frame(width: buttonWidth, height: buttonHeight)
            .background(AppColors.card)
            .clipShape(RoundedRectangle(cornerRadius: AppRadius.Tablet.lg))
        }
    }
}
