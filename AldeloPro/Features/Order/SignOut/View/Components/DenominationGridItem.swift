//
//  DenominationGridItem.swift
//  AldeloPro
//
//  Created by Sen on 2026/06/05.
//

import SwiftUI

// MARK: - DenominationGridItem

/// 单个面额卡片 — 显示面额标签、数量 badge
/// 选中时高亮蓝色边框
struct DenominationGridItem: View {
    let denomination: Denomination
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            ZStack(alignment: .topTrailing) {
                // 面额卡片主体
                VStack(spacing: Spacing.xs) {
                    Text(denomination.label)
                        .font(AppFont.tabletH3Medium)
                        .foregroundColor(AppColors.textPrimary)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 80)
                .background(
                    RoundedRectangle(cornerRadius: AppRadius.Tablet.md)
                        .fill(AppColors.card)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: AppRadius.Tablet.md)
                        .stroke(
                            isSelected ? AppColors.theme : AppColors.line,
                            lineWidth: isSelected ? 2 : 1
                        )
                )

                // 数量 Badge（仅当 count > 0）
                if denomination.count > 0 {
                    countBadge
                }
            }
        }
        .buttonStyle(.plain)
    }

    // MARK: - Count Badge

    private var countBadge: some View {
        Text("x\(denomination.count)")
            .font(AppFont.tabletCaption1Regular)
            .foregroundColor(AppColors.buttonPrimaryText)
            .padding(.horizontal, Spacing.xs)
            .padding(.vertical, 2)
            .background(
                Capsule().fill(AppColors.errorNormal)
            )
            .offset(x: Spacing.xs, y: -Spacing.xs)
    }
}
