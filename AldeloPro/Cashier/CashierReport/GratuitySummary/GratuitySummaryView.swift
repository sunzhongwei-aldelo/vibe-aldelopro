import SwiftUI

// MARK: - Gratuity Summary View

struct GratuitySummaryView: View {
    let data: GratuitySummaryData
    var onViewMoreTapped: (() -> Void)?

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            headerRow
            contentRow
        }
        .padding(.vertical, Spacing.md)
        .background(AppColors.card)
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.Tablet.lg))
    }

    // MARK: - Header

    private var headerRow: some View {
        HStack {
            Text("Gratuity Summary")
                .font(AppFont.tabletH4Medium)
                .foregroundColor(AppColors.textPrimary)
            Spacer()
            Button {
                onViewMoreTapped?()
            } label: {
                Text("View More")
                    .font(AppFont.tabletBody4Regular)
                    .foregroundColor(AppColors.primaryNormal)
            }
        }
        .padding(.horizontal, Spacing.md)
        .padding(.bottom, Spacing.lg)
    }

    // MARK: - Content

    private var contentRow: some View {
        HStack(alignment: .top, spacing: 0) {
            chartSection
            summaryPanel
        }
        .padding(.horizontal, Spacing.md)
    }

    // MARK: - Chart (reuses RevenueSectionWithDivider pattern)

    private var chartSection: some View {
        GratuityBarChart(
            items: data.chartItems,
            maxAmount: data.chartItems.map { abs($0.amount) }.max() ?? 1.0
        )
        .frame(maxWidth: .infinity)
    }

    // MARK: - Summary Panel (right side)

    private var summaryPanel: some View {
        VStack(spacing: 0) {
            // Top group: Tips Added / Order Gratuity / Tip Fee / Bank Surcharge
            HStack(spacing: 0) {
                Spacer()
                VStack(alignment: .trailing, spacing: Spacing.xs) {
                    Text("Tips Added")
                        .font(AppFont.tabletBody5Regular)
                        .foregroundColor(AppColors.textSecondary)
                    Text("Order Gratuity")
                        .font(AppFont.tabletBody5Regular)
                        .foregroundColor(AppColors.textSecondary)
                    Text("Tip Fee")
                        .font(AppFont.tabletBody5Regular)
                        .foregroundColor(AppColors.textSecondary)
                    Text("Bank Surcharge")
                        .font(AppFont.tabletBody5Regular)
                        .foregroundColor(AppColors.textSecondary)
                }
                VStack(alignment: .leading, spacing: Spacing.xs) {
                    Text(data.summary.tipsAddedFormatted)
                        .font(AppFont.tabletBody5Regular)
                        .foregroundColor(AppColors.textPrimary)
                    Text(data.summary.orderGratuityFormatted)
                        .font(AppFont.tabletBody5Regular)
                        .foregroundColor(AppColors.textPrimary)
                    Text(data.summary.tipFeeFormatted)
                        .font(AppFont.tabletBody5Regular)
                        .foregroundColor(AppColors.textPrimary)
                    Text(data.summary.bankSurchargeFormatted)
                        .font(AppFont.tabletBody5Regular)
                        .foregroundColor(AppColors.textPrimary)
                }
                .padding(.leading, Spacing.md)
            }
            .padding(.top, Spacing.md)

            // Divider
            Divider()
                .foregroundColor(AppColors.line)
                .padding(.vertical, Spacing.sm)

            // Bottom group: Gratuity Payable / Gratuity Paid
            HStack(spacing: 0) {
                Spacer()
                VStack(alignment: .trailing, spacing: Spacing.xs) {
                    Text("Gratuity Payable")
                        .font(AppFont.tabletBody5Regular)
                        .foregroundColor(AppColors.textSecondary)
                    Text("Gratuity Paid")
                        .font(AppFont.tabletBody5Regular)
                        .foregroundColor(AppColors.textSecondary)
                }
                VStack(alignment: .leading, spacing: Spacing.xs) {
                    Text(data.summary.gratuityPayableFormatted)
                        .font(AppFont.tabletBody5Regular)
                        .foregroundColor(AppColors.textPrimary)
                    Text(data.summary.gratuityPaidFormatted)
                        .font(AppFont.tabletBody5Regular)
                        .foregroundColor(AppColors.textPrimary)
                }
                .padding(.leading, Spacing.md)
            }

            Spacer().frame(height: Spacing.md)

            // Gratuity Balance (total)
            HStack(spacing: 0) {
                Spacer()
                Text("Gratuity Balance")
                    .font(AppFont.tabletBody3Regular)
                    .foregroundColor(AppColors.textSecondary)
                Text(data.summary.gratuityBalanceFormatted)
                    .font(AppFont.tabletBody3Regular)
                    .foregroundColor(AppColors.primaryNormal)
                    .padding(.leading, Spacing.md)
            }
        }
        .padding(.horizontal, Spacing.md)
        .padding(.bottom, Spacing.md)
        .background(AppColors.primaryLight)
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.Tablet.xs))
        .frame(width: 280)
    }
}

// MARK: - Bar Chart (same pattern as RevenueSectionWithDivider)

private struct GratuityBarChart: View {
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
                // Top tick of center divider
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

            if index < items.count - 1 {
                height += rowHeight + Spacing.md
            } else {
                height += rowHeight
            }
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

    // MARK: - Left Half

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

    // MARK: - Right Half

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

    // MARK: - Bar

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
    ZStack {
        AppColors.pageBg
        GratuitySummaryView(data: .mock)
            .frame(width: 700)
    }
}
