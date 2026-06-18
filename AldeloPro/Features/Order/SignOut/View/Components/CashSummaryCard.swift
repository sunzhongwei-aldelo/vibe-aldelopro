//
//  CashSummaryCard.swift
//  AldeloPro
//
//  Created by Sen on 2026/06/05.
//

import SwiftUI

// MARK: - 现金汇总卡片


// MARK: - CashSummaryCard

/// 现金盘点页面的汇总信息卡片
/// 展示预期金额、实际金额、差异值等关键数据
struct CashSummaryCard: View {
    let expectedFormatted: String
    let actualFormatted: String
    let matchStatus: CashMatchStatus

    private var isMatch: Bool {
        matchStatus == .match
    }

    var body: some View {
        VStack(spacing: 0) {
            // Match banner
            if isMatch {
                Text("Cash Totals Match")
                    .font(AppFont.tabletH5Medium)
                    .foregroundColor(AppColors.theme)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, Spacing.sm)
                    .background(AppColors.theme.opacity(0.08))
            }

            // Data rows - centered Grid layout
            dataGrid
                .frame(maxWidth: .infinity)
                .padding(.horizontal, Spacing.xl)
                .padding(.vertical, Spacing.lg)
        }
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: AppRadius.Tablet.lg)
                .fill(AppColors.card)
        )
        .overlay(
            RoundedRectangle(cornerRadius: AppRadius.Tablet.lg)
                .stroke(isMatch ? AppColors.theme : Color.clear, lineWidth: 1.5)
        )
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.Tablet.lg))
        .animation(.easeInOut(duration: 0.25), value: matchStatus)
    }

    // MARK: - Data Grid

    private var dataGrid: some View {
        Grid(horizontalSpacing: Spacing.lg, verticalSpacing: Spacing.md) {
            GridRow {
                Text("Expected Cash + Start Amount")
                    .font(AppFont.tabletBody2Regular)
                    .foregroundColor(AppColors.textSecondary)
                    .gridColumnAlignment(.trailing)

                Text(expectedFormatted)
                    .font(AppFont.tabletH3Medium)
                    .foregroundColor(AppColors.textPrimary)
                    .gridColumnAlignment(.leading)
            }

            GridRow {
                Text("Actual Cash Total")
                    .font(AppFont.tabletBody2Regular)
                    .foregroundColor(AppColors.textSecondary)

                Text(actualFormatted)
                    .font(AppFont.tabletH3Medium)
                    .foregroundColor(AppColors.theme)
            }

            // Short / Over row
            switch matchStatus {
            case .short(let amount):
                GridRow {
                    Text("Short")
                        .font(AppFont.tabletBody2Regular)
                        .foregroundColor(AppColors.errorNormal)

                    Text(formatCurrency(amount))
                        .font(AppFont.tabletH3Medium)
                        .foregroundColor(AppColors.errorNormal)
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
            case .over(let amount):
                GridRow {
                    Text("Over")
                        .font(AppFont.tabletBody2Regular)
                        .foregroundColor(AppColors.successNormal)

                    Text(formatCurrency(amount))
                        .font(AppFont.tabletH3Medium)
                        .foregroundColor(AppColors.successNormal)
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
            case .idle, .match:
                EmptyView()
            }
        }
    }

    private func formatCurrency(_ value: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "en_US")
        formatter.currencySymbol = "$"
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        return formatter.string(from: value as NSDecimalNumber) ?? "$0.00"
    }
}

