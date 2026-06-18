//
//  AldeloDashboardHeaderView.swift
//  AldeloPro
//
//  Created by Sen on 2026/06/12.
//

import SwiftUI

// MARK: - AldeloDashboardHeaderView（形态 A：工作台主干栏）
//
// 对应全局工作台 / 订单中心 / 桌台管理顶栏。结构：
//   leading  = ☰ 菜单 + 店名
//   center   = AldeloHeaderAICommandFieldView（idle/listening/listeningDark/typing 四态）
//   trailing = 可配置：标准簇（WebOrder? + 铃铛 + 头像 + ⇄）或单主按钮（New Order）
//
// 宽度支持 .fill（桌台全宽 1428）与 .inset(leading:)（订单中心右列 1080）。
// iPhone 竖屏：两行——行1 = ☰店名…铃铛头像；行2 = AI 搜索全宽（最易发现）。

public struct AldeloDashboardHeaderView: View {

    @Environment(\.horizontalSizeClass) private var hSizeClass

    /// trailing 区两种形态。
    public enum TrailingMode {
        /// 标准信息簇：WebOrder（nil 则不显示）+ 铃铛 + 头像 + 切换。
        case cluster(webOrderCount: Int?, hasNotification: Bool, serverName: String, clockInTime: String)
        /// 单一主按钮 + 可选 Server 文案。
        /// title 为 nil 时渲染纯图标方形按钮（设计图 New Order 形态）；非 nil 时为图标+文字胶囊按钮。
        case primaryButton(title: String?, icon: String, serverName: String?, action: () -> Void)
    }

    private let storeName: String
    private let aiState: AICommandState
    private let width: AldeloHeaderWidth
    private let trailingMode: TrailingMode
    private let onMenuTap: (() -> Void)?
    private let onCommandTap: (() -> Void)?
    private let onNotificationTap: (() -> Void)?
    private let onSwitchTap: (() -> Void)?
    /// 头像旁是否显示姓名 + 打卡明细（默认 true = 显示，匹配设计图）。
    private let showsUserDetails: Bool

    public init(
        storeName: String,
        aiState: AICommandState = .idle,
        width: AldeloHeaderWidth = .fill,
        trailingMode: TrailingMode,
        showsUserDetails: Bool = true,
        onMenuTap: (() -> Void)? = nil,
        onCommandTap: (() -> Void)? = nil,
        onNotificationTap: (() -> Void)? = nil,
        onSwitchTap: (() -> Void)? = nil
    ) {
        self.storeName = storeName
        self.aiState = aiState
        self.width = width
        self.trailingMode = trailingMode
        self.showsUserDetails = showsUserDetails
        self.onMenuTap = onMenuTap
        self.onCommandTap = onCommandTap
        self.onNotificationTap = onNotificationTap
        self.onSwitchTap = onSwitchTap
    }

    private var isCompact: Bool { hSizeClass == .compact }

    public var body: some View {
        AldeloHeaderBarShellView(height: .dashboard, width: width) {
            AldeloHeaderLayoutView(isTwoRowOnCompact: true, centerWidthRatio: 391.0 / 1440.0) {
                leadingCluster
            } center: {
                AldeloHeaderAICommandFieldView(state: aiState, onTap: onCommandTap)
            } trailing: {
                trailingContent
            }
        }
    }

    // MARK: leading

    @ViewBuilder
    private var leadingCluster: some View {
        // 汉堡 ☰ 作为全局导航开关，在 cluster 与 primaryButton 两种形态下都常驻；
        // 仅当店名非空时才追加店名文本，避免空字符串占位。
        HStack(spacing: Spacing.sm) {
            Button { onMenuTap?() } label: {
                Image(systemName: "line.3.horizontal")
                    .font(isCompact ? AppFont.mobileH2Medium : AppFont.tabletH2Medium)
                    .foregroundColor(AppColors.textPrimary)
            }
            .buttonStyle(.plain)

            if !storeName.isEmpty {
                Text(storeName)
                    .font(isCompact ? AppFont.mobileH2Medium : AppFont.tabletH3Medium)
                    .foregroundColor(AppColors.textPrimary)
                    .lineLimit(2)
            }
        }
    }

    // MARK: trailing

    @ViewBuilder
    private var trailingContent: some View {
        switch trailingMode {
        case let .cluster(webOrderCount, hasNotification, serverName, clockInTime):
            HStack(spacing: Spacing.md) {
                if let count = webOrderCount, count > 0 {
                    AldeloHeaderWebOrderChipView(count: count)
                }
                notificationBell(hasDot: hasNotification)
                AldeloHeaderUserAvatarClusterView(serverName: serverName, clockInTime: clockInTime, showsDetails: showsUserDetails)
                Button { onSwitchTap?() } label: {
                    Image(systemName: "arrow.left.arrow.right")
                        .font(isCompact ? AppFont.mobileH3Medium : AppFont.tabletH4Medium)
                        .foregroundColor(AppColors.textPrimary)
                }
                .buttonStyle(.plain)
            }
        case let .primaryButton(title, icon, serverName, action):
            HStack(spacing: Spacing.md) {
                if let server = serverName, !isCompact {
                    Text("Server: \(server)")
                        .font(AppFont.tabletBody3Regular)
                        .foregroundColor(AppColors.textSecondary)
                }
                Button(action: action) {
                    primaryButtonLabel(title: title, icon: icon)
                }
                .buttonStyle(.plain)
            }
        }
    }

    @ViewBuilder
    private func primaryButtonLabel(title: String?, icon: String) -> some View {
        let height: CGFloat = isCompact ? 36 : 40
        let radius: CGFloat = isCompact ? AppRadius.Mobile.sm : AppRadius.Tablet.sm
        if let title {
            // 图标 + 文字胶囊形态
            HStack(spacing: Spacing.xs) {
                Image(systemName: icon)
                Text(title)
            }
            .font(isCompact ? AppFont.mobileButton2Medium : AppFont.tabletButton3Medium)
            .foregroundColor(AppColors.white100)
            .padding(.horizontal, Spacing.md)
            .frame(height: height)
            .background(AppColors.theme)
            .clipShape(RoundedRectangle(cornerRadius: radius))
        } else {
            // 纯图标方形按钮形态（设计图 New Order）
            Image(systemName: icon)
                .font(isCompact ? AppFont.mobileH3Medium : AppFont.tabletH3Medium)
                .foregroundColor(AppColors.white100)
                .frame(width: height, height: height)
                .background(AppColors.theme)
                .clipShape(RoundedRectangle(cornerRadius: radius))
        }
    }

    private func notificationBell(hasDot: Bool) -> some View {
        Button { onNotificationTap?() } label: {
            Image(systemName: "bell")
                .font(isCompact ? AppFont.mobileH3Medium : AppFont.tabletH4Medium)
                .foregroundColor(AppColors.textPrimary)
                .overlay(alignment: .topTrailing) {
                    if hasDot {
                        Circle()
                            .fill(AppColors.errorNormal)
                            .frame(width: 6, height: 6)
                            .offset(x: 2, y: -2)
                    }
                }
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Previews

#Preview("iPad 工作台 - idle") {
    VStack(spacing: 0) {
        AldeloDashboardHeaderView(
            storeName: "Super delicious restaurant",
            aiState: .idle,
            trailingMode: .cluster(webOrderCount: 999, hasNotification: true, serverName: "Zhang San", clockInTime: "12:25 PM")
        )
        Spacer()
    }
    .environment(\.horizontalSizeClass, .regular)
}

#Preview("iPad 工作台 - listening") {
    VStack(spacing: 0) {
        AldeloDashboardHeaderView(
            storeName: "Super delicious restaurant",
            aiState: .listening,
            trailingMode: .cluster(webOrderCount: nil, hasNotification: true, serverName: "Zhang San", clockInTime: "12:25 PM")
        )
        Spacer()
    }
    .environment(\.horizontalSizeClass, .regular)
}

#Preview("iPad 工作台 - inset 右列") {
    HStack(spacing: 0) {
        AppColors.card.frame(width: 360)
        VStack(spacing: 0) {
            AldeloDashboardHeaderView(
                storeName: "Super delicious restaurant",
                aiState: .typing,
                width: .inset(leading: 0),
                trailingMode: .cluster(webOrderCount: nil, hasNotification: true, serverName: "Zhang San", clockInTime: "12:25 PM")
            )
            Spacer()
        }
    }
    .environment(\.horizontalSizeClass, .regular)
}

#Preview("iPad 工作台 - New Order 按钮") {
    VStack(spacing: 0) {
        AldeloDashboardHeaderView(
            storeName: "Super delicious restaurant",
            aiState: .idle,
            trailingMode: .primaryButton(title: nil, icon: "plus.app", serverName: nil, action: {})
        )
        Spacer()
    }
    .environment(\.horizontalSizeClass, .regular)
}

#Preview("iPhone 工作台 - 两行") {
    VStack(spacing: 0) {
        AldeloDashboardHeaderView(
            storeName: "Super delicious restaurant",
            aiState: .idle,
            trailingMode: .cluster(webOrderCount: 999, hasNotification: true, serverName: "Zhang San", clockInTime: "12:25 PM")
        )
        Spacer()
    }
    .environment(\.horizontalSizeClass, .compact)
}

#Preview("iPad 工作台 - Dark") {
    VStack(spacing: 0) {
        AldeloDashboardHeaderView(
            storeName: "Super delicious restaurant",
            aiState: .listeningDark,
            trailingMode: .cluster(webOrderCount: 12, hasNotification: true, serverName: "Zhang San", clockInTime: "12:25 PM")
        )
        Spacer()
    }
    .environment(\.horizontalSizeClass, .regular)
    .environment(\.colorScheme, .dark)
}
