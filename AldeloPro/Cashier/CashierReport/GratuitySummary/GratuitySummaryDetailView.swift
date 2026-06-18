//
//  GratuitySummaryDetailView.swift
//  AldeloPro
//

import SwiftUI

// MARK: - Gratuity Summary Overview Detail (full page)

/// Full-page detail for Gratuity Summary. Mirrors `GratuitySummaryDetail.svg`:
/// title → light-blue summary panel (Tips Added / Order Gratuity / tip fee /
/// Bank Surcharge, divider, Gratuity Payable / Gratuity Paid / Gratuity Balance)
/// → a centered breakdown bar chart of the contributing tenders.
///
/// Layout is fully adaptive — no fixed view width/height. The summary panel and
/// chart fill the available width; the chart height is derived from its items.
/// All values come from `GratuitySummaryData`.
struct GratuitySummaryDetailView: View {
    let data: GratuitySummaryData

    init(data: GratuitySummaryData = .overviewDetailMock) {
        self.data = data
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            titleRow
            ScrollView {
                VStack(alignment: .leading, spacing: Spacing.lg) {
                    GratuityOverviewSummaryPanel(summary: data.summary)
                    chartSection
                }
                .padding(.horizontal, Spacing.lg)
                .padding(.bottom, Spacing.lg)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(AppColors.card)
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.Tablet.sm))
        .navigationBarHidden(true)
        .background(SwipeBackGestureEnabler())
    }

    private var titleRow: some View {
        Text(data.detailTitle)
            .font(AppFont.tabletH3Medium)
            .foregroundColor(AppColors.textPrimary)
            .padding(.horizontal, Spacing.lg)
            .padding(.vertical, Spacing.md)
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Chart

    private var chartSection: some View {
        GratuityOverviewBarChart(
            items: data.chartItems,
            maxAmount: data.chartItems.map { abs($0.amount) }.max() ?? 1.0
        )
        .frame(maxWidth: .infinity)
        .padding(.top, Spacing.md)
    }
}

// MARK: - Summary Panel

/// Centered light-blue panel listing the seven gratuity figures, with a hairline
/// divider between the inputs and the payable/paid/balance group. Balance is
/// emphasized in blue.
private struct GratuityOverviewSummaryPanel: View {
    let summary: GratuitySummarySummary

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            line("Tips Added", summary.tipsAddedFormatted)
            line("Order Gratuity", summary.orderGratuityFormatted)
            line("tip fee", summary.tipFeeFormatted)
            line("Bank Surcharge", summary.bankSurchargeFormatted)

            Rectangle()
                .fill(AppColors.line)
                .frame(height: 0.5)
                .padding(.vertical, Spacing.sm)

            line("Gratuity Payable", summary.gratuityPayableFormatted)
            line("Gratuity Paid", summary.gratuityPaidFormatted)
            line(
                "Gratuity Balance",
                summary.gratuityBalanceFormatted,
                valueColor: AppColors.primaryNormal
            )
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .padding(.vertical, Spacing.lg)
        .padding(.horizontal, Spacing.lg)
        .background(AppColors.primaryLight)
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.Tablet.xs))
    }

    private func line(
        _ label: String,
        _ value: String,
        valueColor: Color = AppColors.textPrimary
    ) -> some View {
        HStack(spacing: 0) {
            Text(label)
                .font(AppFont.tabletBody3Regular)
                .foregroundColor(AppColors.textSecondary)
                .frame(width: 220, alignment: .trailing)
            Text(value)
                .font(AppFont.tabletBody3Regular)
                .foregroundColor(valueColor)
                .frame(minWidth: 120, alignment: .leading)
                .padding(.leading, Spacing.xl)
        }
    }
}

// MARK: - Bar Chart

/// Centered, two-sided breakdown chart: positive tenders grow rightward from the
/// center divider; negative adjustments grow leftward. Mirrors the chart in the
/// existing `GratuitySummaryView`, sized to fill the detail page width.
private struct GratuityOverviewBarChart: View {
    let items: [RevenueLineItem]
    let maxAmount: Double

    private let amountTextWidth: CGFloat = 80
    private let barTextSpacing: CGFloat = Spacing.xxs
    private let minBarWidth: CGFloat = 4
    private let singleLineHeight: CGFloat = 18

    var body: some View {
        GeometryReader { geo in
            let halfWidth = (geo.size.width - 0.5) / 2
            let availableBarWidth = halfWidth - amountTextWidth - barTextSpacing - Spacing.xs

            VStack(spacing: 0) {
                HStack(alignment: .top, spacing: 8) {
                    Spacer()
                    Rectangle()
                        .fill(AppColors.black20)
                        .frame(width: 0.5)
                        .frame(height: 12)
                    Spacer()
                }

                ForEach(items) { item in
                    rowView(for: item, availableBarWidth: availableBarWidth)
                }
            }
        }
        .frame(height: calculateHeight())
    }

    private func calculateHeight() -> CGFloat {
        var height: CGFloat = 0
        for (index, item) in items.enumerated() {
            let isMultiLine = item.label.contains("\n")
            let rowHeight: CGFloat = isMultiLine ? singleLineHeight * 2 : singleLineHeight
            height += (index < items.count - 1) ? rowHeight + Spacing.md : rowHeight
        }
        return height
    }

    @ViewBuilder
    private func rowView(for item: RevenueLineItem, availableBarWidth: CGFloat) -> some View {
        HStack(alignment: .top, spacing: 8) {
            leftHalf(for: item, availableBarWidth: availableBarWidth)

            Rectangle()
                .fill(AppColors.black20)
                .frame(width: 0.5)
                .frame(maxHeight: .infinity)

            rightHalf(for: item, availableBarWidth: availableBarWidth)
        }
    }

    @ViewBuilder
    private func leftHalf(for item: RevenueLineItem, availableBarWidth: CGFloat) -> some View {
        if item.isNegative {
            HStack(spacing: barTextSpacing) {
                Spacer(minLength: 0)
                Text(item.formattedAmount)
                    .font(AppFont.tabletH6Medium)
                    .foregroundColor(AppColors.textPrimary)
                    .lineLimit(1)
                barView(for: item, availableBarWidth: availableBarWidth)
            }
            .frame(height: singleLineHeight)
        } else {
            VStack(alignment: .trailing, spacing: Spacing.xxs) {
                Text(item.label)
                    .font(AppFont.tabletBody5Regular)
                    .foregroundColor(AppColors.textSecondary)
                    .multilineTextAlignment(.trailing)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }
            .padding(.trailing, Spacing.xs)
        }
    }

    @ViewBuilder
    private func rightHalf(for item: RevenueLineItem, availableBarWidth: CGFloat) -> some View {
        if item.isNegative {
            Text(item.label)
                .font(AppFont.tabletBody5Regular)
                .foregroundColor(AppColors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, Spacing.xs)
        } else {
            HStack(spacing: barTextSpacing) {
                barView(for: item, availableBarWidth: availableBarWidth)
                Text(item.formattedAmount)
                    .font(AppFont.tabletH6Medium)
                    .foregroundColor(AppColors.textPrimary)
                    .lineLimit(1)
                Spacer(minLength: 0)
            }
            .frame(height: singleLineHeight)
        }
    }

    private func barView(for item: RevenueLineItem, availableBarWidth: CGFloat) -> some View {
        let ratio = abs(item.amount) / maxAmount
        let clampedBarMax = max(minBarWidth, availableBarWidth)
        let barWidth = max(minBarWidth, clampedBarMax * CGFloat(ratio))
        let color: Color = item.isNegative
            ? AppColors.errorNormal
            : AppColors.successNormal.opacity(0.8)

        return RoundedRectangle(cornerRadius: 2)
            .fill(color)
            .frame(width: barWidth, height: singleLineHeight)
    }
}

// MARK: - Preview

#Preview {
    GratuitySummaryDetailView(data: .overviewDetailMock)
}
