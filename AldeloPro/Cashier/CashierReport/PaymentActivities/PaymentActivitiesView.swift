import SwiftUI

// MARK: - Payment Activities View

struct PaymentActivitiesView: View {
    let data: PaymentActivitiesData
    var onViewMoreTapped: (() -> Void)?

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            headerRow
            tableSection
            summarySection
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
            Button {
                onViewMoreTapped?()
            } label: {
                Text("View More")
                    .font(AppFont.tabletH5Regular)
                    .foregroundColor(AppColors.primaryNormal)
            }
        }
        .padding(.horizontal, Spacing.md)
        .padding(.top, Spacing.md)
        .padding(.bottom, Spacing.sm)
    }

    // MARK: - Column Proportions

    /// Column width ratios derived from SVG design (total 1184px)
    private static let columnRatios: [CGFloat] = [0.18, 0.10, 0.32, 0.13, 0.13, 0.14]

    private func columnWidths(for totalWidth: CGFloat) -> [CGFloat] {
        Self.columnRatios.map { $0 * totalWidth }
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
            headerCell("Time", width: widths[0])
            headerCell("Order#", width: widths[1])
            headerCell("Tender", width: widths[2])
            headerCell("Payment", width: widths[3])
            headerCell("Tip Amount", width: widths[4])
            headerCell("Total", width: widths[5])
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

    private func tableDataRow(_ row: PaymentActivityRow, widths: [CGFloat]) -> some View {
        HStack(spacing: 0) {
            dataCell(row.time, width: widths[0])
            dataCell(row.orderNumber, width: widths[1])
            tenderCell(title: row.tenderTitle, subtitle: row.tenderSubtitle, width: widths[2])
            dataCell(row.paymentFormatted, width: widths[3])
            dataCell(row.tipAmountFormatted, width: widths[4])
            dataCell(row.totalFormatted, width: widths[5])
        }
        .frame(height: 42)
        .overlay(alignment: .bottom) {
            Divider().foregroundColor(AppColors.line)
        }
    }

    private func dataCell(_ text: String, width: CGFloat) -> some View {
        Text(text)
            .font(AppFont.tabletBody5Regular)
            .foregroundColor(AppColors.textPrimary)
            .frame(width: width, alignment: .leading)
            .padding(.leading, Spacing.xs)
    }

    private func tenderCell(title: String, subtitle: String?, width: CGFloat) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(AppFont.tabletBody5Regular)
                .foregroundColor(AppColors.textPrimary)
                .lineLimit(1)
            if let subtitle = subtitle {
                Text(subtitle)
                    .font(AppFont.tabletBody5Regular)
                    .foregroundColor(AppColors.textSecondary)
                    .lineLimit(1)
            }
        }
        .frame(width: width, alignment: .leading)
        .padding(.leading, Spacing.xs)
    }

    // MARK: - Summary

    private var summarySection: some View {
        VStack(spacing: 0) {
            // Top group: Order Payment / Order Refunds / Tip
            HStack(spacing: 0) {
                Spacer()
                VStack(alignment: .trailing, spacing: Spacing.xs) {
                    Text("Order Payment")
                        .font(AppFont.tabletBody5Regular)
                        .foregroundColor(AppColors.textSecondary)
                    Text("Order Refunds")
                        .font(AppFont.tabletBody5Regular)
                        .foregroundColor(AppColors.textSecondary)
                    Text("Tip")
                        .font(AppFont.tabletBody5Regular)
                        .foregroundColor(AppColors.textSecondary)
                }
                VStack(alignment: .leading, spacing: Spacing.xs) {
                    Text(data.summary.orderPaymentFormatted)
                        .font(AppFont.tabletBody5Regular)
                        .foregroundColor(AppColors.textPrimary)
                    Text(data.summary.orderRefundsFormatted)
                        .font(AppFont.tabletBody5Regular)
                        .foregroundColor(AppColors.textPrimary)
                    Text(data.summary.tipFormatted)
                        .font(AppFont.tabletBody5Regular)
                        .foregroundColor(AppColors.textPrimary)
                }
                .padding(.leading, Spacing.md)
            }
            .padding(.top, Spacing.md)

            // Divider
            summaryDivider

            // Middle group: Total Order Payment / Refunds
            HStack(spacing: 0) {
                Spacer()
                VStack(alignment: .trailing, spacing: Spacing.xs) {
                    Text("Total Order Payment")
                        .font(AppFont.tabletBody5Regular)
                        .foregroundColor(AppColors.textSecondary)
                    Text("Refunds")
                        .font(AppFont.tabletBody5Regular)
                        .foregroundColor(AppColors.textSecondary)
                }
                VStack(alignment: .leading, spacing: Spacing.xs) {
                    Text(data.summary.totalOrderPaymentFormatted)
                        .font(AppFont.tabletBody5Regular)
                        .foregroundColor(AppColors.textPrimary)
                    Text(data.summary.refundsFormatted)
                        .font(AppFont.tabletBody5Regular)
                        .foregroundColor(AppColors.textPrimary)
                }
                .padding(.leading, Spacing.md)
            }

            // Divider
            summaryDivider

            // Net Payments
            HStack(spacing: 0) {
                Spacer()
                Text("Net Payments")
                    .font(AppFont.tabletBody3Regular)
                    .foregroundColor(AppColors.textSecondary)
                Text(data.summary.netPaymentsFormatted)
                    .font(AppFont.tabletBody3Regular)
                    .foregroundColor(AppColors.primaryNormal)
                    .padding(.leading, Spacing.md)
            }
            .padding(.bottom, Spacing.md)
        }
        .padding(.horizontal, Spacing.md)
        .padding(.top, Spacing.md)
        .background(AppColors.primaryLight)
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.Tablet.xs))
        .padding(Spacing.md)
    }

    private var summaryDivider: some View {
        Divider()
            .foregroundColor(AppColors.line)
            .padding(.vertical, Spacing.sm)
            .padding(.leading, 200)
    }
}

// MARK: - Preview

#Preview {
    ScrollView {
        PaymentActivitiesView(data: .mock)
            .padding(Spacing.md)
    }
    .background(AppColors.pageBg)
}
