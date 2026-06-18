//
//  StoreCreditSoldDetailView.swift
//  AldeloPro
//

import SwiftUI

// MARK: - Store Credit Sold Records Detail (full page)

/// Full-page detail for Store Credit Sold. Mirrors `StoreCreditSoldDetail.svg`:
/// title → centered summary panel (Face Value / Paid Amount totals) →
/// adaptive 3-column table → "Loading More" footer.
///
/// Layout is fully adaptive — no fixed view width/height. Column widths are
/// proportional to the available width (ratios from the SVG) and the table
/// grows with its rows. All values come from `StoreCreditSoldData`.
struct StoreCreditSoldDetailView: View {
    let data: StoreCreditSoldData

    init(data: StoreCreditSoldData = .recordsDetailMock) {
        self.data = data
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            titleRow
            ScrollView {
                VStack(alignment: .leading, spacing: Spacing.lg) {
                    StoreCreditSummaryPanel(
                        faceValueTotal: data.faceValueTotalFormatted,
                        paidAmountTotal: data.paidAmountTotalFormatted
                    )
                    StoreCreditTable(rows: data.rows)
                    LoadingMoreRow()
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
        Text(data.title)
            .font(AppFont.tabletH3Medium)
            .foregroundColor(AppColors.textPrimary)
            .padding(.horizontal, Spacing.lg)
            .padding(.vertical, Spacing.md)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Summary Panel

/// Centered light-blue panel: Face Value Total + Paid Amount Total (emphasized).
private struct StoreCreditSummaryPanel: View {
    let faceValueTotal: String
    let paidAmountTotal: String

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            summaryLine("Face value Total", faceValueTotal)
            summaryLine("Paid Amount Total", paidAmountTotal, valueColor: AppColors.primaryNormal)
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .padding(.vertical, Spacing.lg)
        .padding(.horizontal, Spacing.lg)
        .background(AppColors.primaryLight)
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.Tablet.xs))
    }

    private func summaryLine(
        _ label: String,
        _ value: String,
        valueColor: Color = AppColors.textPrimary
    ) -> some View {
        HStack(spacing: 0) {
            Text(label)
                .font(AppFont.tabletBody3Regular)
                .foregroundColor(AppColors.textSecondary)
                .frame(width: 200, alignment: .trailing)
            Text(value)
                .font(AppFont.tabletBody3Regular)
                .foregroundColor(valueColor)
                .frame(minWidth: 140, alignment: .leading)
                .padding(.leading, Spacing.xl)
        }
    }
}

// MARK: - Table

/// Adaptive 3-column table (Store Credit / Count / Paid Amount). Column widths
/// are proportional to the available width (ratios from the SVG).
private struct StoreCreditTable: View {
    let rows: [StoreCreditRow]

    /// Ratios from SVG (Store Credit 280 / Count 452 / Paid Amount 452, total 1184).
    private static let columnRatios: [CGFloat] = [0.236, 0.382, 0.382]
    private static let headers = ["Store Credit", "Count", "Paid Amount"]

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

    private func dataRow(_ row: StoreCreditRow, widths: [CGFloat]) -> some View {
        HStack(spacing: 0) {
            cell(row.storeCredit, width: widths[0])
            cell("\(row.count)", width: widths[1])
            cell(row.paidAmountFormatted, width: widths[2])
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
}

// MARK: - Preview

#Preview {
    StoreCreditSoldDetailView(data: .recordsDetailMock)
}
