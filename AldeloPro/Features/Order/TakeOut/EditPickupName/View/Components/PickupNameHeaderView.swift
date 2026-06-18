//
//  PickupNameHeaderView.swift
//  AldeloProject
//
//  Created by Sen on 2026/06/10.
//

import SwiftUI

/// 弹窗顶部导航头栏：左对齐大标题 "Edit Pickup Name" + 右对齐关闭叉号，
/// 二者处于同一条水平中心轴线上（HStack）。
/// 仅为子组件 —— 绝不以 `MainView` 结尾命名。
struct PickupNameHeaderView: View {

    @Environment(\.horizontalSizeClass) private var hSizeClass

    let title: String
    let onClose: () -> Void

    private var isPad: Bool { hSizeClass == .regular }

    var body: some View {
        HStack(alignment: .center, spacing: Spacing.md) {
            Text(title)
                .font(isPad ? AppFont.tabletH1Medium : AppFont.mobileH1Medium)
                .lineSpacing(isPad ? AppLineHeight.tabletH1Medium : AppLineHeight.mobileH1Medium)
                .foregroundStyle(AppColors.textPrimary)

            Spacer(minLength: 0)

            closeButton
        }
    }

    /// 无底色、纯黑色的轻量化关闭叉号按钮，提供即时 dismiss 触点。
    private var closeButton: some View {
        Button(action: onClose) {
            Image(systemName: "xmark")
                .font(.system(size: isPad ? 22 : 18, weight: .medium))
                .foregroundStyle(AppColors.textPrimary)
                .frame(width: isPad ? 32 : 28, height: isPad ? 32 : 28)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Previews

#Preview("iPad 横屏") {
    PickupNameHeaderView(title: "Edit Pickup Name", onClose: {})
        .padding()
        .background(AppColors.card)
        .environment(\.horizontalSizeClass, .regular)
}

#Preview("iPhone 竖屏") {
    PickupNameHeaderView(title: "Edit Pickup Name", onClose: {})
        .padding()
        .background(AppColors.card)
        .environment(\.horizontalSizeClass, .compact)
}
