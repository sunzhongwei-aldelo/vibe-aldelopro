import SwiftUI

// MARK: - Main View

struct SettledRevenueSummaryView: View {
    let data: SettledRevenueSummaryData
    var onViewMore: (() -> Void)?

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            headerView
            upperSectionView
            totalCardView(
                label: data.upperSection.totalLabel,
                amount: data.upperSection.formattedTotal
            )
            lowerSectionView
            totalCardView(
                label: data.lowerSection.totalLabel,
                amount: data.lowerSection.formattedTotal
            )
            Spacer()
        }
        .padding(.vertical, Spacing.md)
        .frame(maxHeight: .infinity)
        .background(AppColors.card)
        .cornerRadius(AppRadius.Tablet.lg)
    }
}

// MARK: - Subviews

private extension SettledRevenueSummaryView {

    var headerView: some View {
        HStack {
            Text("Settled Revenue Summary")
                .font(AppFont.tabletH4Medium)
                .foregroundColor(AppColors.textPrimary)
            Spacer()
            Button(action: { onViewMore?() }) {
                Text("View More")
                    .font(AppFont.tabletBody4Regular)
                    .foregroundColor(AppColors.primaryNormal)
            }
        }
        .padding(.horizontal, Spacing.md)
        .padding(.bottom, Spacing.lg)
    }

    var upperSectionView: some View {
        RevenueSectionWithDivider(
            items: data.upperSection.items,
            maxAmount: maxAbsAmount(in: data.upperSection)
        )
        .padding(.horizontal, Spacing.md)
        //.padding(.bottom, Spacing.lg)
    }

    var lowerSectionView: some View {
        RevenueSectionWithDivider(
            items: data.lowerSection.items,
            maxAmount: maxAbsAmount(in: data.lowerSection)
        )
        .padding(.horizontal, Spacing.md)
        //.padding(.bottom, Spacing.lg)
    }

    func totalCardView(label: String, amount: String) -> some View {
        VStack(spacing: Spacing.xs) {
            Text(label)
                .font(AppFont.tabletH6Medium)
                .foregroundColor(AppColors.white100)
            Text(amount)
                .font(AppFont.tabletH4Medium)
                .foregroundColor(AppColors.white100)
        }
        .frame(width: 200, height: 70)
        .background(AppColors.primaryNormal.opacity(0.8))
        .cornerRadius(AppRadius.Tablet.sm)
        .frame(maxWidth: .infinity)
        //.padding(.bottom, Spacing.lg)
    }

    func maxAbsAmount(in section: RevenueSummarySection) -> Double {
        section.items.map { abs($0.amount) }.max() ?? 1.0
    }
}

// MARK: - Section with Center Divider

private struct RevenueSectionWithDivider: View {
    let items: [RevenueLineItem]
    let maxAmount: Double

    /// Estimated width reserved for amount text (e.g. "$41,370.00" or "($263.49)")
    private let amountTextWidth: CGFloat = 90
    /// Spacing between bar and text
    private let barTextSpacing: CGFloat = Spacing.xxs
    /// Minimum bar width for smallest values (ensures visibility)
    private let minBarWidth: CGFloat = 4
    /// Single line row height
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
        .frame(height: calculateSectionHeight())
    }

    private func calculateSectionHeight() -> CGFloat {
        var height: CGFloat = 0
        for (index, item) in items.enumerated() {
            let isMultiLine = item.label.contains("\n")
            let rowHeight: CGFloat = isMultiLine ? singleLineHeight * 2 : singleLineHeight
            height += rowHeight

            if item.subtitle != nil {
                height += 14 + Spacing.xxs
            }

            if index < items.count - 1 {
                height += Spacing.md
            }
        }
        return height
    }

    @ViewBuilder
    private func rowView(for item: RevenueLineItem, availableBarWidth: CGFloat) -> some View {
        HStack(alignment: .top, spacing: 8) {
            // Left half: right-aligned to divider
            leftHalf(for: item, availableBarWidth: availableBarWidth)

            // Center divider
            Rectangle()
                .fill(AppColors.black20)
                .frame(width: 0.5)
                .frame(maxHeight: .infinity)

            // Right half: left-aligned from divider
            rightHalf(for: item, availableBarWidth: availableBarWidth)
        }
    }

    // MARK: - Left Half (right-aligned to divider)

    @ViewBuilder
    private func leftHalf(for item: RevenueLineItem, availableBarWidth: CGFloat) -> some View {
        if item.isNegative {
            // Negative: [amount] [red bar →|]
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
            // Positive: label + subtitle, right-aligned
            VStack(alignment: .trailing, spacing: Spacing.xxs) {
                Text(item.label)
                    .font(AppFont.tabletBody5Regular)
                    .foregroundColor(AppColors.textSecondary)
                    .multilineTextAlignment(.trailing)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity, alignment: .trailing)

                if let subtitle = item.subtitle {
                    Text(subtitle)
                        .font(AppFont.tabletCaption1Regular)
                        .foregroundColor(AppColors.textMuted)
                }
            }
            .padding(.trailing, Spacing.xs)
        }
    }

    // MARK: - Right Half (left-aligned from divider)

    @ViewBuilder
    private func rightHalf(for item: RevenueLineItem, availableBarWidth: CGFloat) -> some View {
        if item.isNegative {
            // Negative: [|label]
            Text(item.label)
                .font(AppFont.tabletBody5Regular)
                .foregroundColor(AppColors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)
                .frame(height: singleLineHeight)
                .padding(.leading, Spacing.xs)
        } else {
            // Positive: [|green bar] [amount]
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

    // MARK: - Bar (dynamic width based on data ratio and available space)

    private func barView(for item: RevenueLineItem, availableBarWidth: CGFloat) -> some View {
        let ratio = abs(item.amount) / maxAmount
        let clampedBarMax = max(minBarWidth, availableBarWidth)
        let barWidth = max(minBarWidth, clampedBarMax * CGFloat(ratio))
        let color: Color = item.isNegative ? AppColors.errorNormal : AppColors.successNormal.opacity(0.8)

        return RoundedRectangle(cornerRadius: 2)
            .fill(color)
            .frame(width: barWidth, height: singleLineHeight)
    }
}

// MARK: - Preview

#Preview {
    ZStack {
        AppColors.pageBg
        SettledRevenueSummaryView(data: .mock)
            .frame(width: 606)
    }
    

}
