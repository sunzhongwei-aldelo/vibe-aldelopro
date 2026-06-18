//
//  VehicleColorSelectorView.swift
//  AldeloProject
//
//  Created by Sen on 2026/06/11.
//

import SwiftUI

/// 一排实体车身色彩圆点。
/// 白色 / 浅色圆点会额外套上一圈极细 `line` 描边，使其在浅色页面背景下边界清晰、
/// 永不发生"视觉融化"。选中圆点获得一圈带内间隙的品牌蓝光环。
/// iPad 维持单行平铺；iPhone 自动折行为弹性网格。
struct VehicleColorSelectorView: View {

    @Environment(\.horizontalSizeClass) private var hSizeClass

    let colors: [VehicleColorOption]
    let selectedID: String?
    let onSelect: (String) -> Void

    private var isPad: Bool { hSizeClass == .regular }
    private var dotSize: CGFloat { isPad ? 44 : 36 }
    private var spacing: CGFloat { Spacing.md }

    private var gridColumns: [GridItem] {
        [GridItem(.adaptive(minimum: dotSize, maximum: dotSize), spacing: spacing, alignment: .leading)]
    }

    var body: some View {
        if isPad {
            HStack(spacing: spacing) {
                ForEach(colors) { option in
                    dot(for: option)
                }
            }
        } else {
            LazyVGrid(columns: gridColumns, alignment: .leading, spacing: spacing) {
                ForEach(colors) { option in
                    dot(for: option)
                }
            }
        }
    }

    /// 单个色彩圆点，含白色防御描边与选中光环逻辑。
    private func dot(for option: VehicleColorOption) -> some View {
        let isSelected = option.id == selectedID
        return Button {
            onSelect(option.id)
        } label: {
            Circle()
                .fill(Color(hex: option.hex))
                .frame(width: dotSize, height: dotSize)
                // 浅色防御：白 / 银等浅色圆点补一圈细描边。
                .overlay {
                    if option.needsLightStrokeDefense {
                        Circle().stroke(AppColors.line, lineWidth: 1)
                    }
                }
                // 选中光环：留出内间隙，使其读作"光晕"而非"边框"。
                .overlay {
                    if isSelected {
                        Circle()
                            .stroke(AppColors.theme, lineWidth: 2)
                            .padding(-4)
                    }
                }
                .contentShape(Circle())
        }
        .buttonStyle(.plain)
        .padding(4) // 预留光环空间，确保相邻圆点永不裁剪它
        .animation(.easeInOut(duration: 0.18), value: isSelected)
    }
}

// MARK: - Previews

#Preview("iPad 横屏 - 白色选中") {
    VehicleColorSelectorView(
        colors: VehicleColorOption.presets,
        selectedID: "white",
        onSelect: { _ in }
    )
    .padding()
    .background(AppColors.pageBg)
    .environment(\.horizontalSizeClass, .regular)
}

#Preview("iPhone 竖屏 - 自动折行") {
    VehicleColorSelectorView(
        colors: VehicleColorOption.presets,
        selectedID: "blue",
        onSelect: { _ in }
    )
    .padding()
    .background(AppColors.pageBg)
    .environment(\.horizontalSizeClass, .compact)
}
