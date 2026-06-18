//
//  OrderSettingsNumpadView.swift
//  AldeloPro
//
//  Created by Sen on 2026/06/10.
//

import SwiftUI

// MARK: - 定制版 3x4 POS 数字键盘

/// 右侧常驻的 3 列 4 行数字网格键盘
/// 键位布局：
/// | 1 | 2 | 3 |
/// | 4 | 5 | 6 |
/// | 7 | 8 | 9 |
/// | ⌫ | 0 | Clear |
struct OrderSettingsNumpadView: View {
    let isPad: Bool
    /// 数字键点击回调
    let onDigit: (String) -> Void
    /// 退格键回调
    let onBackspace: () -> Void
    /// 清空键回调
    let onClear: () -> Void

    /// 3 列等宽网格
    private let columns = Array(
        repeating: GridItem(.flexible(), spacing: Spacing.sm),
        count: 3
    )

    var body: some View {
        LazyVGrid(columns: columns, spacing: Spacing.sm) {
            // Row 1-3: 数字 1-9
            ForEach(["1", "2", "3", "4", "5", "6", "7", "8", "9"], id: \.self) { digit in
                digitButton(digit)
            }
            // Row 4: ⌫ | 0 | Clear
            backspaceButton
            digitButton("0")
            clearButton
        }
    }

    // MARK: - 数字按键

    private func digitButton(_ digit: String) -> some View {
        Button(action: { onDigit(digit) }) {
            Text(digit)
                .font(isPad ? AppFont.tabletH1Medium : AppFont.mobileH1Medium)
                .foregroundStyle(AppColors.textPrimary)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .aspectRatio(1.4, contentMode: .fit)
                .background(AppColors.card)
                .clipShape(RoundedRectangle(cornerRadius: isPad ? AppRadius.Tablet.md : AppRadius.Mobile.md))
                .overlay(
                    RoundedRectangle(cornerRadius: isPad ? AppRadius.Tablet.md : AppRadius.Mobile.md)
                        .stroke(AppColors.line, lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
    }

    // MARK: - 退格按键 ⌫

    private var backspaceButton: some View {
        Button(action: onBackspace) {
            Image(systemName: "delete.backward")
                .font(isPad ? AppFont.tabletH2Medium : AppFont.mobileH2Medium)
                .foregroundStyle(AppColors.textPrimary)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .aspectRatio(1.4, contentMode: .fit)
        }
        .buttonStyle(.plain)
    }

    // MARK: - 清空按键

    private var clearButton: some View {
        Button(action: onClear) {
            Text("Clear")
                .font(isPad ? AppFont.tabletH3Medium : AppFont.mobileH3Medium)
                .foregroundStyle(AppColors.textPrimary)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .aspectRatio(1.4, contentMode: .fit)
        }
        .buttonStyle(.plain)
    }
}
