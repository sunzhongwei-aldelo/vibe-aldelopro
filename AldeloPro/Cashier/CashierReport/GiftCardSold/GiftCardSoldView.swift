import SwiftUI

// MARK: - Gift Card Sold View

struct GiftCardSoldView: View {
    let data: GiftCardSoldData
    var onViewMoreTapped: (() -> Void)?

    /// Column ratios from SVG: 280/140/191/191/191/191 ≈ total 1184
    private static let columnRatios: [CGFloat] = [0.236, 0.118, 0.161, 0.161, 0.161, 0.163]

    private func columnWidths(for totalWidth: CGFloat) -> [CGFloat] {
        Self.columnRatios.map { $0 * totalWidth }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            headerRow
            tableSection
            summaryFooter
        }
        .background(AppColors.card)
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.Tablet.lg))
    }

    // MARK: - Header

    private var headerRow: some View {
        HStack {
            Text(data.title)
                .font(AppFont.tabletH4Medium)
                .foregroundColor(AppColors.textPrimary)
            Spacer()
            Button { onViewMoreTapped?() } label: {
                Text("View More")
                    .font(AppFont.tabletH5Regular)
                    .foregroundColor(AppColors.primaryNormal)
            }
        }
        .padding(.horizontal, Spacing.md)
        .padding(.top, Spacing.md)
        .padding(.bottom, Spacing.sm)
    }

    // MARK: - Table

    private var tableSection: some View {
        GeometryReader { geometry in
            let widths = columnWidths(for: geometry.size.width)
            VStack(spacing: 0) {
                tableHeaderRow(widths: widths)
                ForEach(data.rows) { row in
                    tableDataRow(row, widths: widths)
                }
            }
        }
        .frame(height: CGFloat(data.rows.count + 1) * 42)
        .padding(.horizontal, Spacing.md)
    }

    private func tableHeaderRow(widths: [CGFloat]) -> some View {
        HStack(spacing: 0) {
            headerCell("Gift Card", width: widths[0])
            headerCell("Card Type", width: widths[1])
            headerCell("Customer", width: widths[2])
            headerCell("Count", width: widths[3])
            headerCell("Face Value", width: widths[4])
            headerCell("Paid Amount", width: widths[5])
        }
        .frame(height: 42)
        .background(AppColors.pageBgDeep)
    }

    private func headerCell(_ title: String, width: CGFloat) -> some View {
        Text(title)
            .font(AppFont.tabletBody5Regular)
            .foregroundColor(AppColors.textPrimary)
            .frame(width: width, alignment: .leading)
            .padding(.leading, Spacing.xs)
    }

    private func tableDataRow(_ row: GiftCardRow, widths: [CGFloat]) -> some View {
        HStack(spacing: 0) {
            Text(row.giftCard)
                .font(AppFont.tabletBody5Regular)
                .foregroundColor(AppColors.textPrimary)
                .frame(width: widths[0], alignment: .leading)
                .padding(.leading, Spacing.xs)

            // Card Type badge
            cardTypeBadge(row.cardType)
                .frame(width: widths[1], alignment: .leading)
                .padding(.leading, Spacing.xs)

            Text(row.customer)
                .font(AppFont.tabletBody5Regular)
                .foregroundColor(AppColors.textPrimary)
                .frame(width: widths[2], alignment: .leading)
                .padding(.leading, Spacing.xs)

            Text("\(row.count)")
                .font(AppFont.tabletBody5Regular)
                .foregroundColor(AppColors.textPrimary)
                .frame(width: widths[3], alignment: .leading)
                .padding(.leading, Spacing.xs)

            Text(row.faceValueFormatted)
                .font(AppFont.tabletBody5Regular)
                .foregroundColor(AppColors.textPrimary)
                .frame(width: widths[4], alignment: .leading)
                .padding(.leading, Spacing.xs)

            Text(row.paidAmountFormatted)
                .font(AppFont.tabletBody5Regular)
                .foregroundColor(AppColors.textPrimary)
                .frame(width: widths[5], alignment: .leading)
                .padding(.leading, Spacing.xs)
        }
        .frame(height: 42)
        .overlay(alignment: .bottom) {
            Divider().foregroundColor(AppColors.line)
        }
    }

    private func cardTypeBadge(_ type: GiftCardType) -> some View {
        Text(type.displayText)
            .font(AppFont.tabletCaption1Regular)
            .foregroundColor(type.badgeColor)
            .padding(.horizontal, Spacing.xs)
            .padding(.vertical, Spacing.xxs)
            .background(type.badgeColor.opacity(0.08))
            .clipShape(RoundedRectangle(cornerRadius: AppRadius.Tablet.xs))
    }

    // MARK: - Summary

    private var summaryFooter: some View {
        VStack(spacing: Spacing.xs) {
            HStack {
                Spacer()
                Text("Face Value Total")
                    .font(AppFont.tabletBody5Regular)
                    .foregroundColor(AppColors.textSecondary)
                Text(data.faceValueTotalFormatted)
                    .font(AppFont.tabletBody5Regular)
                    .foregroundColor(AppColors.textPrimary)
                    .padding(.leading, Spacing.md)
            }
            HStack {
                Spacer()
                Text("Paid Amount Total")
                    .font(AppFont.tabletBody3Regular)
                    .foregroundColor(AppColors.textSecondary)
                Text(data.paidAmountTotalFormatted)
                    .font(AppFont.tabletBody3Regular)
                    .foregroundColor(AppColors.primaryNormal)
                    .padding(.leading, Spacing.md)
            }
        }
        .padding(Spacing.md)
        .background(AppColors.primaryLight)
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.Tablet.xs))
        .padding(Spacing.md)
    }
}

// MARK: - Preview

#Preview {
    ScrollView {
        GiftCardSoldView(data: .mock)
            .padding(Spacing.md)
    }
    .background(AppColors.pageBg)
}
