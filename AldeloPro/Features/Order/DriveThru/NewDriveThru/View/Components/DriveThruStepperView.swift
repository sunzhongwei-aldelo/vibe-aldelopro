//
//  DriveThruStepperView.swift
//  AldeloProject
//
//  Created by Sen on 2026/06/11.
//

import SwiftUI

/// "Guests Count"（就餐人数）行，带一体化拼接的 [ − ] [ 数值 ] [ + ] 步进器。
/// 纯展示组件：只对外发射意图，不持有任何业务状态。
/// 每次成功加减时触发一次轻量触感反馈（属于 UI 关注点，可在 View 层处理）。
struct DriveThruStepperView: View {

    @Environment(\.horizontalSizeClass) private var hSizeClass

    let title: String
    let value: Int
    let canStepDown: Bool
    let canStepUp: Bool
    let onDecrement: () -> Void
    let onIncrement: () -> Void

    private var isPad: Bool { hSizeClass == .regular }
    private var controlHeight: CGFloat { isPad ? 64 : 48 }
    private var valueWidth: CGFloat { isPad ? 240 : 120 }
    private var corner: CGFloat { isPad ? AppRadius.Tablet.md : AppRadius.Mobile.md }

    var body: some View {
        HStack(spacing: isPad ? Spacing.md : Spacing.sm) {
            Text(title)
                .font(isPad ? AppFont.tabletH3Medium : AppFont.mobileH3Medium)
                .lineSpacing(isPad ? AppLineHeight.tabletH3Medium : AppLineHeight.mobileH3Medium)
                .foregroundStyle(AppColors.textPrimary)

            Spacer(minLength: Spacing.md)

            stepperCluster
        }
    }

    private var stepperCluster: some View {
        HStack(spacing: isPad ? Spacing.sm : Spacing.xs) {
            stepButton(symbol: "minus", enabled: canStepDown) {
                fireHaptic()
                onDecrement()
            }

            // 中央数值区：极淡灰白底（pageBg），等宽数字防止抖动。
            Text("\(value)")
                .font(isPad ? AppFont.tabletBody1Regular : AppFont.mobileBody1Regular)
                .lineSpacing(isPad ? AppLineHeight.tabletBody1Regular : AppLineHeight.mobileBody1Regular)
                .foregroundStyle(AppColors.textPrimary)
                .monospacedDigit()
                .frame(width: valueWidth, height: controlHeight)
                .background(
                    RoundedRectangle(cornerRadius: corner, style: .continuous)
                        .fill(AppColors.pageBg)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: corner, style: .continuous)
                        .stroke(AppColors.line, lineWidth: 1)
                )

            stepButton(symbol: "plus", enabled: canStepUp) {
                fireHaptic()
                onIncrement()
            }
        }
    }

    /// 单个加 / 减按钮块（白底卡片 + 细灰边）。
    private func stepButton(symbol: String, enabled: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: symbol)
                .font(.system(size: isPad ? 22 : 17, weight: .medium))
                .foregroundStyle(enabled ? AppColors.textPrimary : AppColors.textSecondary.opacity(0.4))
                .frame(width: controlHeight, height: controlHeight)
                .background(
                    RoundedRectangle(cornerRadius: corner, style: .continuous)
                        .fill(AppColors.card)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: corner, style: .continuous)
                        .stroke(AppColors.line, lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
        .disabled(!enabled)
    }

    /// 触发系统级轻量触感反馈。
    private func fireHaptic() {
        #if os(iOS)
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
        #endif
    }
}

// MARK: - Previews

#Preview("iPad 横屏") {
    DriveThruStepperView(
        title: "Guests Count",
        value: 1,
        canStepDown: false,
        canStepUp: true,
        onDecrement: {},
        onIncrement: {}
    )
    .padding()
    .background(AppColors.pageBg)
    .environment(\.horizontalSizeClass, .regular)
}

#Preview("iPhone 竖屏") {
    DriveThruStepperView(
        title: "Guests Count",
        value: 3,
        canStepDown: true,
        canStepUp: true,
        onDecrement: {},
        onIncrement: {}
    )
    .padding()
    .background(AppColors.pageBg)
    .environment(\.horizontalSizeClass, .compact)
}
