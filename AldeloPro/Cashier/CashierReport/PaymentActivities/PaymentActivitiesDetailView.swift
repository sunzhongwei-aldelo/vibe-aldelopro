//
//  PaymentActivitiesDetailView.swift
//  AldeloPro
//

import SwiftUI

// MARK: - Payment Activities Detail (full page)

/// Full-page detail for Payment Activities. Mirrors `PaymentActivitiesDetail.svg`:
/// title → summary panel → 6-column table → footer (total count + pagination).
/// Layout is fully adaptive — no fixed view width/height; column widths are
/// proportional to the available width and the table grows with its content.
struct PaymentActivitiesDetailView: View {
    let data: PaymentActivitiesData

    /// Rows shown per page. The table is paged locally over `data.rows`.
    private let rowsPerPage = 10

    /// 1-based index of the page currently displayed.
    @State private var currentPage = 1

    /// Total number of pages, derived from the actual row count.
    private var totalPages: Int {
        max(1, Int(ceil(Double(data.rows.count) / Double(rowsPerPage))))
    }

    /// Rows belonging to the current page.
    private var visibleRows: [PaymentActivityRow] {
        let start = (currentPage - 1) * rowsPerPage
        guard start < data.rows.count else { return [] }
        let end = min(start + rowsPerPage, data.rows.count)
        return Array(data.rows[start..<end])
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            titleRow
            ScrollView {
                VStack(alignment: .leading, spacing: Spacing.lg) {
                    PaymentActivitiesSummaryPanel(summary: data.summary)
                    PaymentActivitiesTable(rows: visibleRows)
                }
                .padding(.horizontal, Spacing.lg)
                .padding(.bottom, Spacing.lg)
            }
            footerRow
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(AppColors.card)
        .navigationBarHidden(true)
        .background(SwipeBackGestureEnabler())
    }

    // MARK: - Title

    private var titleRow: some View {
        Text(data.title)
            .font(AppFont.tabletH3Medium)
            .foregroundColor(AppColors.textPrimary)
            .padding(.horizontal, Spacing.lg)
            .padding(.vertical, Spacing.md)
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Footer (total count + pagination)

    private var footerRow: some View {
        HStack(spacing: 0) {
            // Total count, left aligned
            HStack(spacing: Spacing.xs) {
                Text("Total")
                    .foregroundColor(AppColors.textSecondary)
                Text("\(data.rows.count)")
                    .foregroundColor(AppColors.textPrimary)
            }
            .font(AppFont.tabletBody5Regular)

            Spacer()

            // Pagination, right aligned
            HStack(spacing: Spacing.xs) {
                Text("Page")
                    .foregroundColor(AppColors.textSecondary)
                Text("\(currentPage)")
                    .foregroundColor(AppColors.textPrimary)
                Text("Of \(totalPages)")
                    .foregroundColor(AppColors.textSecondary)
                pagerButton(systemName: "chevron.left", enabled: currentPage > 1) {
                    goToPage(currentPage - 1)
                }
                .padding(.leading, Spacing.sm)
                pagerButton(systemName: "chevron.right", enabled: currentPage < totalPages) {
                    goToPage(currentPage + 1)
                }
            }
            .font(AppFont.tabletBody5Regular)
        }
        .padding(.horizontal, Spacing.lg)
        .padding(.vertical, Spacing.md)
    }

    private func goToPage(_ page: Int) {
        currentPage = min(max(page, 1), totalPages)
    }

    private func pagerButton(
        systemName: String,
        enabled: Bool,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: 16, weight: .regular))
                .foregroundColor(AppColors.textPrimary)
                .frame(width: 44, height: 44)
                .overlay(
                    RoundedRectangle(cornerRadius: AppRadius.Tablet.md)
                        .stroke(AppColors.line, lineWidth: 1)
                )
        }
        .disabled(!enabled)
        .opacity(enabled ? 1 : 0.4)
    }
}

// MARK: - Summary Panel

/// Right-aligned summary block matching the SVG: three label/value groups
/// separated by hairline dividers, with Net Payments emphasized in blue.
private struct PaymentActivitiesSummaryPanel: View {
    let summary: PaymentActivitiesSummary

    var body: some View {
        VStack(alignment: .trailing, spacing: 0) {
            group {
                summaryLine("Order Payment", summary.orderPaymentFormatted)
                summaryLine("Order Refunds", summary.orderRefundsFormatted)
                summaryLine("Tip", summary.tipFormatted)
            }
            divider
            group {
                summaryLine("Total Order Payment", summary.totalOrderPaymentFormatted)
                summaryLine("Refunds", summary.refundsFormatted)
            }
            divider
            group {
                summaryLine(
                    "Net Payments",
                    summary.netPaymentsFormatted,
                    valueColor: AppColors.primaryNormal,
                    font: AppFont.tabletBody3Regular
                )
            }
        }
        .frame(maxWidth: .infinity, alignment: .trailing)
        .padding(.vertical, Spacing.lg)
        .padding(.horizontal, Spacing.lg)
        .background(AppColors.pageBg)
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.Tablet.xs))
    }

    private func group<Content: View>(@ViewBuilder _ content: () -> Content) -> some View {
        VStack(alignment: .trailing, spacing: Spacing.sm) {
            content()
        }
    }

    private var divider: some View {
        Rectangle()
            .fill(AppColors.line)
            .frame(height: 0.5)
            .padding(.vertical, Spacing.md)
    }

    private func summaryLine(
        _ label: String,
        _ value: String,
        valueColor: Color = AppColors.textPrimary,
        font: Font = AppFont.tabletBody3Regular
    ) -> some View {
        HStack(spacing: 0) {
            Text(label)
                .font(font)
                .foregroundColor(AppColors.textSecondary)
                .frame(maxWidth: .infinity, alignment: .trailing)
            Text(value)
                .font(font)
                .foregroundColor(valueColor)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, Spacing.lg)
        }
    }
}

// MARK: - Table

/// Adaptive 6-column table. Column widths are proportional to the available
/// width (ratios derived from the SVG), so it fills any iPad size without
/// hardcoded absolute widths. Rows grow with the data.
private struct PaymentActivitiesTable: View {
    let rows: [PaymentActivityRow]

    /// Column width ratios from SVG (Time 215 / Order# 140 / Tender 430 /
    /// Payment 133 / Tip 133 / Total 133, total 1184).
    private static let columnRatios: [CGFloat] = [0.182, 0.118, 0.363, 0.112, 0.112, 0.113]
    private static let headers = ["Time", "Order#", "Tender", "Payment", "Tip Amount", "Total"]

    var body: some View {
        GeometryReader { geometry in
            let widths = Self.columnRatios.map { $0 * geometry.size.width }
            VStack(spacing: 0) {
                headerRow(widths: widths)
                ForEach(rows) { row in
                    dataRow(row, widths: widths)
                }
            }
        }
        // Header + rows each 56pt tall (matches SVG cell height).
        .frame(height: CGFloat(rows.count + 1) * 56)
        .overlay(
            RoundedRectangle(cornerRadius: AppRadius.Tablet.xs)
                .stroke(AppColors.line, lineWidth: 0.5)
        )
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.Tablet.xs))
    }

    private func headerRow(widths: [CGFloat]) -> some View {
        HStack(spacing: 0) {
            ForEach(Array(Self.headers.enumerated()), id: \.offset) { index, title in
                Text(title)
                    .font(AppFont.tabletBody5Regular)
                    .foregroundColor(AppColors.textPrimary)
                    .frame(width: widths[index], alignment: .leading)
                    .padding(.leading, Spacing.sm)
            }
        }
        .frame(height: 56)
        .background(AppColors.buttonSecondaryBg)
    }

    private func dataRow(_ row: PaymentActivityRow, widths: [CGFloat]) -> some View {
        HStack(spacing: 0) {
            cell(row.time, width: widths[0])
            cell(row.orderNumber, width: widths[1])
            tenderCell(title: row.tenderTitle, subtitle: row.tenderSubtitle, width: widths[2])
            cell(row.paymentFormatted, width: widths[3])
            cell(row.tipAmountFormatted, width: widths[4])
            cell(row.totalFormatted, width: widths[5])
        }
        .frame(height: 56)
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(AppColors.line.opacity(0.5))
                .frame(height: 0.5)
        }
    }

    private func cell(_ text: String, width: CGFloat) -> some View {
        Text(text)
            .font(AppFont.tabletBody5Regular)
            .foregroundColor(AppColors.textPrimary)
            .lineLimit(1)
            .frame(width: width, alignment: .leading)
            .padding(.leading, Spacing.sm)
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
        .padding(.leading, Spacing.sm)
    }
}

// MARK: - Preview

#Preview {
    PaymentActivitiesDetailView(data: .mock)
}
