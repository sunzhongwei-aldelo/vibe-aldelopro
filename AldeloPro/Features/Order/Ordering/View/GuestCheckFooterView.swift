//
//  GuestCheckFooterView.swift
//  AldeloExpressPro
//
//  Created by LiZong on 2026/06/08.
//

import SwiftUI

// MARK: - 客单底部汇总栏


/// 已点菜品列表底部的金额汇总与提交区域
/// 展示小计、税费、总价，以及提交/结算按钮
struct GuestCheckFooterView: View {
    var onSubmit: () -> Void = {}
    var onPrint: () -> Void = {}
    var onPay: () -> Void = {}

    var body: some View {
        GeometryReader { geo in
            let totalSpacing = Spacing.sm * 2
            let available = geo.size.width - totalSpacing
            let smallWidth = available / 4        // ~1 part each
            let largeWidth = available / 2        // ~2 parts

            HStack(spacing: Spacing.sm) {
                strokeButton(title: "Submit", action: onSubmit)
                    .frame(width: smallWidth)
                strokeButton(title: "Print", action: onPrint)
                    .frame(width: smallWidth)
                primaryButton(title: "Pay", action: onPay)
                    .frame(width: largeWidth)
            }
        }
        .frame(height: 63)
        .padding(.horizontal, Spacing.md)
        .padding(.vertical, Spacing.sm)
    }

    private func strokeButton(title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(AppFont.tabletH3Medium)
                .foregroundColor(AppColors.textPrimary)
                .frame(maxWidth: .infinity)
                .frame(height: 63)
                .background(AppColors.card)
                .clipShape(RoundedRectangle(cornerRadius: AppRadius.Tablet.lg))
                .overlay(
                    RoundedRectangle(cornerRadius: AppRadius.Tablet.lg)
                        .stroke(AppColors.line, lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
    }

    private func primaryButton(title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(AppFont.tabletH3Medium)
                .foregroundColor(AppColors.buttonPrimaryText)
                .frame(maxWidth: .infinity)
                .frame(height: 63)
                .background(AppColors.buttonPrimaryBg)
                .clipShape(RoundedRectangle(cornerRadius: AppRadius.Tablet.lg))
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preview

#Preview("Guest Check Footer") {
    GuestCheckFooterView()
        .frame(width: 500)
        .background(AppColors.card)
}

