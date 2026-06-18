//
//  OrderStatusBadge.swift
//  AldeloPro
//
//  Created by wanghui on 2026/06/08.
//

import SwiftUI

struct OrderStatusBadge: View {
    let status: OrderStatus

    private var bgColor: Color {
        switch status {
        case .open: return AppColors.primaryLight
        case .settled: return AppColors.successLight
        case .voided: return Color(hex: "#595959").opacity(0.08)
        }
    }

    private var strokeColor: Color {
        switch status {
        case .open: return AppColors.primaryNormal
        case .settled: return AppColors.successNormal
        case .voided: return Color(hex: "#6B7785")
        }
    }

    private var textColor: Color {
        switch status {
        case .open: return AppColors.primaryNormal
        case .settled: return AppColors.successNormal
        case .voided: return Color(hex: "#595959")
        }
    }

    var body: some View {
        Text(status.rawValue)
            .font(AppFont.tabletBody5Regular)
            .foregroundColor(textColor)
            .padding(.horizontal, Spacing.xs)
            .padding(.vertical, Spacing.xxs)
            .background(
                UnevenRoundedRectangle(
                    topLeadingRadius: 0,
                    bottomLeadingRadius: AppRadius.Tablet.sm,
                    bottomTrailingRadius: 0,
                    topTrailingRadius: AppRadius.Tablet.sm
                )
                .fill(bgColor)
            )
            .overlay(
                UnevenRoundedRectangle(
                    topLeadingRadius: 0,
                    bottomLeadingRadius: AppRadius.Tablet.sm,
                    bottomTrailingRadius: 0,
                    topTrailingRadius: AppRadius.Tablet.sm
                )
                .stroke(strokeColor, lineWidth: 1)
            )
    }
}

#Preview {
    HStack(spacing: Spacing.md) {
        OrderStatusBadge(status: .open)
        OrderStatusBadge(status: .settled)
        OrderStatusBadge(status: .voided)
    }
    .padding()
}
