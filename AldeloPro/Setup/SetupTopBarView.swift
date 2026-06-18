//
//  SetupTopBarView.swift
//  AldeloPro
//
//  Created by wanghui on 2026/06/04.
//

import SwiftUI

// MARK: - 设置流程顶部栏（App Mode / AI Mode 切换 + 进度条）

struct SetupTopBarView: View {
    // MARK: - Environment
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    // MARK: - Properties
    var progress: Double = 0.35
    @State private var isAIMode: Bool = false

    private var isCompact: Bool { horizontalSizeClass == .compact }

    // MARK: - Body
    var body: some View {
        HStack(spacing: Spacing.xs) {
            Text(isAIMode ? "AI Mode" : "App Mode")
                .font(isCompact ? AppFont.mobileH3Medium : AppFont.tabletH3Medium)
                .foregroundColor(AppColors.textPrimary)
                .fixedSize()

            modeSwitchBadge

            Spacer()

            progressBar
        }
        .padding(.vertical, isCompact ? Spacing.sm : Spacing.md)
        .padding(.horizontal, isCompact ? Spacing.md : Spacing.lg)
        .background(AppColors.glass)
    }

    // MARK: - 模式切换徽章
    private var modeSwitchBadge: some View {
        Button {
            isAIMode.toggle()
        } label: {
            HStack(spacing: Spacing.xxs) {
                Image("switch")
                    .font(.system(size: isCompact ? 10 : 12, weight: .medium))
                if isCompact == false {
                    Text(isAIMode ? "AI Mode" : "App Mode")
                        .font(AppFont.tabletCaption1Regular)
                }
            }
            .foregroundColor(AppColors.primaryNormal)
            .padding(.horizontal, Spacing.sm)
            .padding(.vertical, Spacing.xxs)
            .overlay(
                RoundedRectangle(cornerRadius: AppRadius.Tablet.xl)
                    .stroke(AppColors.primaryNormal, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - 进度条
    private var progressBar: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: AppRadius.Tablet.xs)
                    .fill(AppColors.progressTrack)
                    .frame(height: isCompact ? 6 : 8)

                RoundedRectangle(cornerRadius: AppRadius.Tablet.xs)
                    .fill(AppColors.primaryNormal)
                    .frame(width: geo.size.width * progress, height: isCompact ? 6 : 8)
            }
            .frame(maxHeight: .infinity, alignment: .center)
        }
        .frame(maxWidth: isCompact ? 140 : 390)
        .frame(height: isCompact ? 6 : 8)
    }
}

// MARK: - Preview

#Preview {
    SetupTopBarView(progress: 0.35)
}
