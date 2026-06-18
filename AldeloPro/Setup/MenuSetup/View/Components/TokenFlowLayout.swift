//
//  TokenFlowLayout.swift
//  AldeloPro
//
//  Created by jiangxia on 2026/06/12.
//

import SwiftUI

/// Token 输入框布局：把前面的标签（chips）水平排列、自动折行，
/// 并让最后一个子视图（输入用 TextField）填满当前行剩余宽度。
/// 用于「标签直接显示在输入框内部」的 token field 效果。
struct TokenFlowLayout: Layout {
    /// 子视图之间的间距
    var spacing: CGFloat
    /// 末尾输入框的最小宽度，低于此值则换行后占满整行
    var minFieldWidth: CGFloat = 60

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        arrange(proposal: proposal, subviews: subviews).size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = arrange(proposal: proposal, subviews: subviews)
        for (index, placed) in result.items.enumerated() {
            subviews[index].place(
                at: CGPoint(x: bounds.minX + placed.origin.x, y: bounds.minY + placed.origin.y),
                proposal: ProposedViewSize(width: placed.size.width, height: placed.size.height)
            )
        }
    }

    // MARK: - Arrangement

    private struct Placed {
        var origin: CGPoint
        var size: CGSize
    }

    private struct Result {
        var items: [Placed]
        var size: CGSize
    }

    /// 计算所有子视图位置：chips 流式折行，末尾输入框填满剩余宽度。
    private func arrange(proposal: ProposedViewSize, subviews: Subviews) -> Result {
        let maxWidth = proposal.width ?? .infinity
        let lastIndex = subviews.count - 1
        var items: [Placed] = []
        var x: CGFloat = 0
        var y: CGFloat = 0
        var rowHeight: CGFloat = 0
        var totalWidth: CGFloat = 0

        for (index, subview) in subviews.enumerated() {
            let size = subview.sizeThatFits(.unspecified)
            let isField = index == lastIndex

            if isField {
                var remaining = maxWidth.isFinite ? maxWidth - x : size.width
                if maxWidth.isFinite, remaining < minFieldWidth, x > 0 {
                    // 当前行放不下输入框 → 换行占满整行
                    x = 0
                    y += rowHeight + spacing
                    rowHeight = 0
                    remaining = maxWidth
                }
                let fieldWidth = maxWidth.isFinite ? max(remaining, minFieldWidth) : size.width
                items.append(Placed(origin: CGPoint(x: x, y: y),
                                    size: CGSize(width: fieldWidth, height: size.height)))
                rowHeight = max(rowHeight, size.height)
                x += fieldWidth
                totalWidth = max(totalWidth, x)
            } else {
                // chip：当前行放不下则换行
                if maxWidth.isFinite, x + size.width > maxWidth, x > 0 {
                    x = 0
                    y += rowHeight + spacing
                    rowHeight = 0
                }
                items.append(Placed(origin: CGPoint(x: x, y: y), size: size))
                rowHeight = max(rowHeight, size.height)
                x += size.width + spacing
                totalWidth = max(totalWidth, x - spacing)
            }
        }

        let totalHeight = y + rowHeight
        let resolvedWidth = maxWidth.isFinite ? maxWidth : totalWidth
        return Result(items: items, size: CGSize(width: resolvedWidth, height: totalHeight))
    }
}
