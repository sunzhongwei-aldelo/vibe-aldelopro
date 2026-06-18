//
//  VehicleTypeSelectorView.swift
//  AldeloProject
//
//  Created by Sen on 2026/06/11.
//

import SwiftUI

/// 车型剪影卡片的横向点选矩阵。
/// 选中态卡片：1.5pt 品牌蓝外边框 + 淡蓝半透明染色底 + 蓝色图标。
/// 未选中态卡片：素白 `card` 底 + 极淡 `line` 细灰边。
/// iPad 用一行弹性平铺；iPhone 降级为横向滚动卡片流。
struct VehicleTypeSelectorView: View {

    @Environment(\.horizontalSizeClass) private var hSizeClass

    let title: String
    let vehicles: [VehicleType]
    let selectedID: String?
    let onSelect: (String) -> Void

    private var isPad: Bool { hSizeClass == .regular }
    private var cardSize: CGFloat { isPad ? 92 : 72 }
    private var corner: CGFloat { isPad ? AppRadius.Tablet.md : AppRadius.Mobile.md }
    private var spacing: CGFloat { Spacing.md }

    var body: some View {
        VStack(alignment: .leading, spacing: isPad ? Spacing.md : Spacing.sm) {
            Text(title)
                .font(isPad ? AppFont.tabletH3Medium : AppFont.mobileH3Medium)
                .lineSpacing(isPad ? AppLineHeight.tabletH3Medium : AppLineHeight.mobileH3Medium)
                .foregroundStyle(AppColors.textPrimary)

            if isPad {
                HStack(spacing: spacing) {
                    ForEach(vehicles) { vehicle in
                        card(for: vehicle)
                    }
                }
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: spacing) {
                        ForEach(vehicles) { vehicle in
                            card(for: vehicle)
                        }
                    }
                }
            }
        }
    }

    /// 单张车型卡片，根据选中态切换描边粗细、底色填充与图标着色。
    private func card(for vehicle: VehicleType) -> some View {
        let isSelected = vehicle.id == selectedID
        return Button {
            onSelect(vehicle.id)
        } label: {
            Image(systemName: vehicle.iconName)
                .font(.system(size: isPad ? 34 : 26, weight: .regular))
                .foregroundStyle(isSelected ? AppColors.theme : AppColors.textSecondary)
                .frame(width: cardSize, height: cardSize)
                .background(
                    RoundedRectangle(cornerRadius: corner, style: .continuous)
                        .fill(isSelected ? AppColors.optionSelectedFill : AppColors.card)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: corner, style: .continuous)
                        .stroke(
                            isSelected ? AppColors.optionSelectedStroke : AppColors.line,
                            lineWidth: isSelected ? 1.5 : 1
                        )
                )
        }
        .buttonStyle(.plain)
        .animation(.easeInOut(duration: 0.18), value: isSelected)
    }
}

// MARK: - Previews

#Preview("iPad 横屏 - 选中第一项") {
    VehicleTypeSelectorView(
        title: "Vehicle",
        vehicles: VehicleType.presets,
        selectedID: VehicleType.presets.first?.id,
        onSelect: { _ in }
    )
    .padding()
    .background(AppColors.pageBg)
    .environment(\.horizontalSizeClass, .regular)
}

#Preview("iPhone 竖屏 - 横向滑动") {
    VehicleTypeSelectorView(
        title: "Vehicle",
        vehicles: VehicleType.presets,
        selectedID: "suv",
        onSelect: { _ in }
    )
    .padding()
    .background(AppColors.pageBg)
    .environment(\.horizontalSizeClass, .compact)
}
