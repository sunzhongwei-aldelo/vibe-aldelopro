//
//  AldeloAppModeHeaderView.swift
//  AldeloPro
//
//  Created by Sen on 2026/06/12.
//

import SwiftUI

// MARK: - AldeloAppModeHeaderView（形态 D：App Mode 状态栏）
//
// 对应纯色底「App Mode」状态栏。结构：
//   leading  = "App Mode" 标题 + [⇄ AI mode] 描边胶囊
//   trailing = AldeloHeaderAppModeProgressView（蓝色进度线，progress 0...1）
//
// 最矮档（statusBar：iPad 78 / iPhone 56）。iPhone 竖屏单行，进度线可缩短。

public struct AldeloAppModeHeaderView: View {

    @Environment(\.horizontalSizeClass) private var hSizeClass

    private let title: String
    private let modeTitle: String
    private let modeIcon: String
    private let progress: CGFloat
    private let onModeTap: (() -> Void)?

    public init(
        title: String = "App Mode",
        modeTitle: String = "AI mode",
        modeIcon: String = "arrow.left.arrow.right",
        progress: CGFloat = 0.35,
        onModeTap: (() -> Void)? = nil
    ) {
        self.title = title
        self.modeTitle = modeTitle
        self.modeIcon = modeIcon
        self.progress = progress
        self.onModeTap = onModeTap
    }

    private var isCompact: Bool { hSizeClass == .compact }

    public var body: some View {
        AldeloHeaderBarShellView(height: .statusBar) {
            AldeloHeaderLayoutView {
                leadingCluster
            } center: {
                EmptyView()
            } trailing: {
                AldeloHeaderAppModeProgressView(progress: progress)
                    .frame(width: progressWidth)
            }
        }
    }

    private var progressWidth: CGFloat { isCompact ? 120 : 240 }

    private var leadingCluster: some View {
        HStack(spacing: Spacing.sm) {
            Text(title)
                .font(isCompact ? AppFont.mobileH2Medium : AppFont.tabletH2Medium)
                .foregroundColor(AppColors.textPrimary)

            Button { onModeTap?() } label: {
                HStack(spacing: Spacing.xxs) {
                    Image(systemName: modeIcon)
                    Text(modeTitle)
                }
                .font(isCompact ? AppFont.mobileButton3Medium : AppFont.tabletButton4Medium)
                .foregroundColor(AppColors.theme)
                .padding(.horizontal, Spacing.sm)
                .padding(.vertical, Spacing.xxs)
                .overlay(Capsule().stroke(AppColors.theme, lineWidth: 1))
            }
            .buttonStyle(.plain)
        }
    }
}

// MARK: - Previews

#Preview("iPad App Mode - 35%") {
    VStack(spacing: 0) {
        AldeloAppModeHeaderView(progress: 0.35)
        Spacer()
    }
    .environment(\.horizontalSizeClass, .regular)
}

#Preview("iPad App Mode - 100%") {
    VStack(spacing: 0) {
        AldeloAppModeHeaderView(progress: 1.0)
        Spacer()
    }
    .environment(\.horizontalSizeClass, .regular)
}

#Preview("iPad App Mode - Dark") {
    VStack(spacing: 0) {
        AldeloAppModeHeaderView(progress: 0.7)
        Spacer()
    }
    .environment(\.horizontalSizeClass, .regular)
    .environment(\.colorScheme, .dark)
}

#Preview("iPhone App Mode") {
    VStack(spacing: 0) {
        AldeloAppModeHeaderView(progress: 0.5)
        Spacer()
    }
    .environment(\.horizontalSizeClass, .compact)
}
