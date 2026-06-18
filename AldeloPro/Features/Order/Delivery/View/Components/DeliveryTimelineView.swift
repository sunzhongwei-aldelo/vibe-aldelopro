//
//  DeliveryTimelineView.swift
//  AldeloPro
//
//  Created by Sen on 2026/06/05.
//

import SwiftUI

// MARK: - 配送时间线视图


/// 配送进度时间线组件
/// 以纵向节点列表形式展示订单各阶段状态（已接单/备餐中/配送中/已送达）
struct DeliveryTimelineView: View {
    let nodes: [DeliveryTimelineNode]
    let truckProgress: Double

    private let nodeSize: CGFloat = 12
    private let truckSize: CGFloat = 20
    private let lineHeight: CGFloat = 2

    var body: some View {
        ZStack(alignment: .top) {
            // Layer 1: Line + truck (positioned at circle center Y)
            lineLayer
                .padding(.top, nodeSize / 2 - lineHeight / 2)

            // Layer 2: Node columns (circles + labels)
            nodeColumnsRow
        }
    }

    // MARK: - Node Columns (defines full width)

    private var nodeColumnsRow: some View {
        HStack(alignment: .top, spacing: 0) {
            nodeColumn(index: 0, alignment: .leading)
            Spacer(minLength: 0)
            nodeColumn(index: 1, alignment: .center)
            Spacer(minLength: 0)
            nodeColumn(index: 2, alignment: .trailing)
        }
    }

    private func nodeColumn(index: Int, alignment: HorizontalAlignment) -> some View {
        let node = nodes[index]
        return VStack(alignment: .center, spacing: Spacing.xxs) {
            nodeCircle(for: node, index: index)
            Text(node.label)
                .font(AppFont.tabletCaption1Regular)
                .foregroundStyle(AppColors.textSecondary)
            if node.isActive, let timestamp = node.timestamp {
                Text(formatTime(timestamp))
                    .font(AppFont.tabletCaption1Regular)
                    .foregroundStyle(AppColors.textSecondary)
            } else {
                Text(" ")
                    .font(AppFont.tabletCaption1Regular)
                    .foregroundStyle(.clear)
            }
        }
    }

    // MARK: - Node Circle

    @ViewBuilder
    private func nodeCircle(for node: DeliveryTimelineNode, index: Int) -> some View {
        // If truck is at this node (arrived state, last node), show truck instead
        if truckProgress >= 1.0 && index == nodes.count - 1 {
            Image(systemName: "truck.box.fill")
                .font(.system(size: truckSize))
                .foregroundStyle(AppColors.theme)
                .frame(width: nodeSize, height: nodeSize)
        } else if node.isActive {
            Circle()
                .fill(AppColors.theme)
                .frame(width: nodeSize, height: nodeSize)
        } else {
            Circle()
                .stroke(AppColors.theme, lineWidth: 2)
                .frame(width: nodeSize, height: nodeSize)
        }
    }

    // MARK: - Line Layer (horizontal track + truck)

    private var lineLayer: some View {
        GeometryReader { geo in
            let totalWidth = geo.size.width
            // Estimate circle center positions based on label widths
            let leftLabelWidth: CGFloat = 60
            let rightLabelWidth: CGFloat = 50
            let leftCircleX = leftLabelWidth / 2
            let rightCircleX = totalWidth - rightLabelWidth / 2
            let trackStart = leftCircleX
            let trackEnd = rightCircleX
            let trackWidth = trackEnd - trackStart

            // Truck position on track
            let truckX = trackStart + trackWidth * truckProgress

            // Solid line (traveled portion)
            Path { path in
                path.move(to: CGPoint(x: trackStart, y: lineHeight / 2))
                path.addLine(to: CGPoint(x: min(truckX, trackEnd), y: lineHeight / 2))
            }
            .stroke(AppColors.theme, lineWidth: lineHeight)

            // Dashed line (remaining portion)
            if truckProgress < 1.0 {
                Path { path in
                    path.move(to: CGPoint(x: truckX, y: lineHeight / 2))
                    path.addLine(to: CGPoint(x: trackEnd, y: lineHeight / 2))
                }
                .stroke(AppColors.theme, style: StrokeStyle(lineWidth: lineHeight, dash: [4, 4]))
            }

            // Truck icon (if not at final node)
            if truckProgress < 1.0 {
                Image(systemName: "truck.box.fill")
                    .font(.system(size: truckSize))
                    .foregroundStyle(AppColors.theme)
                    .position(x: truckX, y: lineHeight / 2)
            }
        }
        .frame(height: lineHeight)
    }

    // MARK: - Helpers

    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: date)
    }
}

