import SwiftUI

// MARK: - Main View

struct ReportCashCountView: View {
    let data: CashCountData
    var onViewMore: (() -> Void)?

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            headerView
            summaryCardView
            denominationListView
        }
        .padding(.vertical, Spacing.md)
        .background(AppColors.card)
        .cornerRadius(AppRadius.Tablet.lg)
    }
}

// MARK: - Subviews

private extension ReportCashCountView {

    var headerView: some View {
        HStack {
            Text("Cash Count")
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
        .padding(.bottom, Spacing.md)
    }

    var summaryCardView: some View {
        HStack(spacing: Spacing.lg) {
            // Left labels — right-aligned
            VStack(alignment: .trailing, spacing: Spacing.xs) {
                Text("Start Amount")
                    .font(AppFont.tabletH6Medium)
                    .foregroundColor(AppColors.textSecondary)
                Text("Actual Cash Total")
                    .font(AppFont.tabletH6Medium)
                    .foregroundColor(AppColors.textSecondary)
                Text("Cash Owed")
                    .font(AppFont.tabletH6Medium)
                    .foregroundColor(AppColors.textSecondary)
            }

            // Right values — left-aligned
            VStack(alignment: .leading, spacing: Spacing.xs) {
                Text(data.summary.formattedStartAmount)
                    .font(AppFont.tabletH6Medium)
                    .foregroundColor(AppColors.textPrimary)
                Text(data.summary.formattedActualCashTotal)
                    .font(AppFont.tabletH6Medium)
                    .foregroundColor(AppColors.textPrimary)
                Text(data.summary.formattedCashOwed)
                    .font(AppFont.tabletH6Medium)
                    .foregroundColor(AppColors.primaryNormal)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, Spacing.md)
        .background(AppColors.primaryLight)
        .cornerRadius(AppRadius.Tablet.sm)
        .padding(.horizontal, Spacing.md)
        .padding(.bottom, Spacing.lg)
    }

    var denominationListView: some View {
        GeometryReader { geo in
            let labelWidth: CGFloat = 50
            let dividerWidth: CGFloat = 0.5
            let amountTextWidth: CGFloat = 80
            let spacing: CGFloat = Spacing.xs
            let horizontalPadding: CGFloat = Spacing.md * 2
            let availableBarWidth = geo.size.width - horizontalPadding - labelWidth - dividerWidth - amountTextWidth - spacing * 2

            HStack(alignment: .top, spacing: 0) {
                // Left: denomination labels, right-aligned to divider
                VStack(spacing: Spacing.sm) {
                    ForEach(data.denominations) { item in
                        Text(item.denomination)
                            .font(AppFont.tabletBody5Regular)
                            .foregroundColor(AppColors.textSecondary)
                            .frame(width: labelWidth, height: 18, alignment: .trailing)
                    }
                }
                .padding(.trailing, Spacing.xs)

                // Center divider
                Rectangle()
                    .fill(AppColors.black20)
                    .frame(width: dividerWidth)
                    .frame(height: CGFloat(data.denominations.count) * 18 + CGFloat(data.denominations.count - 1) * Spacing.sm)

                // Right: bars + amounts, left-aligned from divider
                VStack(spacing: Spacing.sm) {
                    ForEach(Array(data.denominations.enumerated()), id: \.element.id) { index, item in
                        denominationBarRow(
                            item: item,
                            index: index,
                            totalCount: data.denominations.count,
                            availableBarWidth: availableBarWidth
                        )
                    }
                }
            }
            .padding(.horizontal, Spacing.md)
        }
        .frame(height: CGFloat(data.denominations.count) * 18 + CGFloat(data.denominations.count - 1) * Spacing.sm)
    }

    func denominationBarRow(
        item: CashDenominationItem,
        index: Int,
        totalCount: Int,
        availableBarWidth: CGFloat
    ) -> some View {
        let ratio = item.totalAmount / data.maxAmount
        let minBarWidth: CGFloat = 4
        let barWidth = max(minBarWidth, availableBarWidth * CGFloat(ratio))
        // Opacity gradient: from 0.35 (top) to 0.80 (bottom)
        let opacity = 0.35 + (0.45 * Double(index) / Double(max(1, totalCount - 1)))

        return HStack(spacing: Spacing.xs) {
            // Bar with count label inside
            ZStack(alignment: .center) {
                RoundedRectangle(cornerRadius: 2)
                    .fill(AppColors.primaryNormal.opacity(opacity))
                    .frame(width: barWidth, height: 18)

                if barWidth > 24 {
                    Text(item.countLabel)
                        .font(AppFont.tabletCaption1Regular)
                        .foregroundColor(AppColors.white100)
                }
            }
            .frame(width: barWidth, height: 18)

            // Amount
            Text(item.formattedTotal)
                .font(AppFont.tabletH6Medium)
                .foregroundColor(AppColors.textPrimary)
                .lineLimit(1)

            Spacer(minLength: 0)
        }
        .frame(height: 18)
    }
}

// MARK: - Preview

#Preview {
    ReportCashCountView(data: .mock)
        .frame(width: 606)
        .padding(Spacing.md)
        .background(AppColors.pageBg)
}
