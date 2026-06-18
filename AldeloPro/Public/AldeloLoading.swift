//
//  AldeloLoading.swift
//  AldeloPro
//
//  Created by Sen on 2026/06/05.
//

import SwiftUI

// MARK: - AldeloLoading

/// 通用全屏加载遮罩
/// 覆盖半透明背景，中央显示旋转动画 + 动态文本
/// 用法：.overlay { if isLoading { AldeloLoading(text: "Sync Data") } }
struct AldeloLoading: View {
    let text: String

    var body: some View {
        ZStack {
            // 遮罩背景
            AppColors.black20
                .ignoresSafeArea()

            // HUD 卡片
            VStack(spacing: Spacing.lg) {
                ProgressView()
                    .progressViewStyle(.circular)
                    .scaleEffect(1.5)
                    .tint(AppColors.theme)

                Text(text)
                    .font(AppFont.tabletH3Medium)
                    .foregroundColor(AppColors.textPrimary)
            }
            .padding(Spacing.xl)
            .frame(minWidth: 200)
            .background(
                RoundedRectangle(cornerRadius: AppRadius.Tablet.lg)
                    .fill(AppColors.card)
                    .shadow(color: AppColors.black20, radius: 16, y: 4)
            )
        }
    }
}

// MARK: - Preview

#Preview("Loading") {
    AldeloLoading(text: "Sync Data")
}
