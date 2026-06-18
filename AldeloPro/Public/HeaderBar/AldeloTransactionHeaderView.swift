//
//  AldeloTransactionHeaderView.swift
//  AldeloPro
//
//  Created by Sen on 2026/06/12.
//

import SwiftUI

// MARK: - AldeloTransactionHeaderView（形态 B：交易开单栏）
//
// 对应 Dine In / Take Out / Delivery / Drive Thru 开单顶栏。结构：
//   leading  = AldeloHeaderOrderChannelBadgeView（渠道色块 + 名 + 订单号 + 可选桌台）
//   center   = 可选 AI 指令搜索条（aiState 非 nil 时显示，如 Refund 主容器）
//   trailing = Server 文案（仅 iPad）+ AldeloHeaderActionButtonsView（Back + Continue）
//
// iPhone 竖屏：单行——渠道块+#015 … Back/Continue（长订单号/桌台/Server 自动隐藏）。
//
// 【AI 中心槽】部分交易页（如 Refund 主容器）在订单信息与按钮之间有一条 AI 语音搜索条。
// 传入 aiState 即在 center 渲染 AldeloHeaderAICommandFieldView；默认 nil = 无 AI 条。

public struct AldeloTransactionHeaderView: View {

    @Environment(\.horizontalSizeClass) private var hSizeClass

    private let channelTitle: String
    private let channelColor: Color
    private let channelIcon: String
    private let longOrderNo: String
    private let orderNumber: String
    private let tableNumber: String?
    private let serverName: String
    private let actions: [AldeloHeaderAction]
    private let aiState: AICommandState?
    private let onCommandTap: (() -> Void)?

    public init(
        channelTitle: String,
        channelColor: Color,
        channelIcon: String = "bag.fill",
        longOrderNo: String,
        orderNumber: String,
        tableNumber: String? = nil,
        serverName: String,
        actions: [AldeloHeaderAction],
        aiState: AICommandState? = nil,
        onCommandTap: (() -> Void)? = nil
    ) {
        self.channelTitle = channelTitle
        self.channelColor = channelColor
        self.channelIcon = channelIcon
        self.longOrderNo = longOrderNo
        self.orderNumber = orderNumber
        self.tableNumber = tableNumber
        self.serverName = serverName
        self.actions = actions
        self.aiState = aiState
        self.onCommandTap = onCommandTap
    }

    private var isCompact: Bool { hSizeClass == .compact }

    public var body: some View {
        AldeloHeaderBarShellView(height: .standard) {
            AldeloHeaderLayoutView {
                AldeloHeaderOrderChannelBadgeView(
                    channelTitle: channelTitle,
                    channelColor: channelColor,
                    channelIcon: channelIcon,
                    longOrderNo: longOrderNo,
                    orderNumber: orderNumber,
                    tableNumber: tableNumber
                )
            } center: {
                if let aiState {
                    AldeloHeaderAICommandFieldView(state: aiState, onTap: onCommandTap)
                } else {
                    EmptyView()
                }
            } trailing: {
                HStack(spacing: Spacing.lg) {
                    if !isCompact && !serverName.isEmpty {
                        Text("Server: \(serverName)")
                            .font(AppFont.tabletBody2Regular)
                            .foregroundColor(AppColors.textSecondary)
                    }
                    AldeloHeaderActionButtonsView(actions: actions)
                }
            }
        }
    }
}

// MARK: - 渠道便捷构造

public extension AldeloTransactionHeaderView {
    /// Dine In（堂食，橙）。
    static func dineIn(longOrderNo: String, orderNumber: String, tableNumber: String?, serverName: String, onBack: @escaping () -> Void, onContinue: @escaping () -> Void) -> AldeloTransactionHeaderView {
        AldeloTransactionHeaderView(
            channelTitle: "Dine In", channelColor: AppColors.orderTypeDineIn, channelIcon: "fork.knife",
            longOrderNo: longOrderNo, orderNumber: orderNumber, tableNumber: tableNumber, serverName: serverName,
            actions: [.back(onBack), .primary("Continue", action: onContinue)]
        )
    }

    /// Take Out（外带，蓝）。
    static func takeOut(longOrderNo: String, orderNumber: String, serverName: String, onBack: @escaping () -> Void, onContinue: @escaping () -> Void) -> AldeloTransactionHeaderView {
        AldeloTransactionHeaderView(
            channelTitle: "Take Out", channelColor: AppColors.orderTypeTakeOut, channelIcon: "bag.fill",
            longOrderNo: longOrderNo, orderNumber: orderNumber, serverName: serverName,
            actions: [.back(onBack), .primary("Continue", action: onContinue)]
        )
    }

    /// Delivery（外送，黄）。
    static func delivery(longOrderNo: String, orderNumber: String, serverName: String, onBack: @escaping () -> Void, onContinue: @escaping () -> Void) -> AldeloTransactionHeaderView {
        AldeloTransactionHeaderView(
            channelTitle: "Delivery", channelColor: AppColors.orderTypeDelivery, channelIcon: "bicycle",
            longOrderNo: longOrderNo, orderNumber: orderNumber, serverName: serverName,
            actions: [.back(onBack), .primary("Continue", action: onContinue)]
        )
    }

    /// Drive Thru（得来速，红）。
    static func driveThru(longOrderNo: String, orderNumber: String, serverName: String, onBack: @escaping () -> Void, onContinue: @escaping () -> Void) -> AldeloTransactionHeaderView {
        AldeloTransactionHeaderView(
            channelTitle: "Drive Thru", channelColor: AppColors.orderTypeDriveThru, channelIcon: "car.fill",
            longOrderNo: longOrderNo, orderNumber: orderNumber, serverName: serverName,
            actions: [.back(onBack), .primary("Continue", action: onContinue)]
        )
    }
}

// MARK: - Previews

#Preview("iPad Dine In") {
    VStack(spacing: 0) {
        AldeloTransactionHeaderView.dineIn(longOrderNo: "1200002", orderNumber: "#015", tableNumber: "01", serverName: "Zhang San", onBack: {}, onContinue: {})
        Spacer()
    }
    .environment(\.horizontalSizeClass, .regular)
}

#Preview("iPad Take Out") {
    VStack(spacing: 0) {
        AldeloTransactionHeaderView.takeOut(longOrderNo: "1200002", orderNumber: "#016", serverName: "Zhang San", onBack: {}, onContinue: {})
        Spacer()
    }
    .environment(\.horizontalSizeClass, .regular)
}

#Preview("iPad Drive Thru - Dark") {
    VStack(spacing: 0) {
        AldeloTransactionHeaderView.driveThru(longOrderNo: "1200002", orderNumber: "#016", serverName: "Zhang San", onBack: {}, onContinue: {})
        Spacer()
    }
    .environment(\.horizontalSizeClass, .regular)
    .environment(\.colorScheme, .dark)
}

#Preview("iPhone Dine In - 单行") {
    VStack(spacing: 0) {
        AldeloTransactionHeaderView.dineIn(longOrderNo: "1200002", orderNumber: "#015", tableNumber: "01", serverName: "Zhang San", onBack: {}, onContinue: {})
        Spacer()
    }
    .environment(\.horizontalSizeClass, .compact)
}
