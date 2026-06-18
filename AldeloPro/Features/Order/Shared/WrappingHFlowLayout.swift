//
//  WrappingHFlowLayout.swift
//  AldeloPro
//
//  Created by Sen on 2026/06/03.
//

import SwiftUI

// MARK: - WrappingHFlowLayout

/// 水平自动换行布局容器
///
/// 子视图从左到右依次排列，当当前行剩余宽度不够容纳下一个子视图时，
/// 自动换到下一行。主要用于 Deny Order / Void Order 页面的原因 Chip 列表。
///
/// 行为特点：
/// - 短文本 Chip（如 "Order Mistake"）可以并排显示
/// - 长文本 Chip（如 "Customer No Longer Wanted"）自动独占一行
/// - iPhone 竖屏时自然适配，无需手动指定列数
///
/// 使用示例：
/// ```swift
/// WrappingHFlowLayout(spacing: Spacing.md) {
///     ForEach(reasons, id: \.self) { reason in
///         OrderReasonChip(title: reason, ...)
///     }
/// }
/// ```
struct WrappingHFlowLayout: Layout {

    /// 子视图之间的水平和垂直间距
    let spacing: CGFloat

    init(spacing: CGFloat = 8) {
        self.spacing = spacing
    }

    func sizeThatFits(
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout ()
    ) -> CGSize {
        computeLayout(proposal: proposal, subviews: subviews).size
    }

    func placeSubviews(
        in bounds: CGRect,
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout ()
    ) {
        let result = computeLayout(proposal: proposal, subviews: subviews)
        for (index, position) in result.positions.enumerated() {
            subviews[index].place(
                at: CGPoint(
                    x: bounds.minX + position.x,
                    y: bounds.minY + position.y
                ),
                proposal: ProposedViewSize(result.sizes[index])
            )
        }
    }

    // MARK: - 布局计算

    private struct LayoutResult {
        let size: CGSize
        let positions: [CGPoint]
        let sizes: [CGSize]
    }

    /// 计算所有子视图的位置，核心换行逻辑
    private func computeLayout(
        proposal: ProposedViewSize,
        subviews: Subviews
    ) -> LayoutResult {
        let maxWidth = proposal.width ?? .infinity
        var positions: [CGPoint] = []
        var sizes: [CGSize] = []
        var currentX: CGFloat = 0
        var currentY: CGFloat = 0
        var rowHeight: CGFloat = 0
        var totalWidth: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            sizes.append(size)

            // 当前行放不下 → 换行
            if currentX + size.width > maxWidth, currentX > 0 {
                currentX = 0
                currentY += rowHeight + spacing
                rowHeight = 0
            }

            positions.append(CGPoint(x: currentX, y: currentY))
            rowHeight = max(rowHeight, size.height)
            currentX += size.width + spacing
            totalWidth = max(totalWidth, currentX - spacing)
        }

        let totalHeight = currentY + rowHeight
        return LayoutResult(
            size: CGSize(width: totalWidth, height: totalHeight),
            positions: positions,
            sizes: sizes
        )
    }
}
