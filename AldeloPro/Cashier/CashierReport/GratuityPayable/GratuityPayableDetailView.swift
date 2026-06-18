//
//  GratuityPayableDetailView.swift
//  AldeloPro
//

import SwiftUI

// MARK: - Gratuity Payable Records Detail (full page)

/// Full-page detail for Gratuity Payable Records. Mirrors
/// `GratuityPayableRecordsDetail.svg`: title → centered summary panel
/// (Gratuity / Less Fees / Net Payable totals) → adaptive 4-column table →
/// "Loading More" footer.
///
/// Layout is fully adaptive — no fixed view width/height. Column widths are
/// proportional to the available width and the table grows with its rows.
/// All displayed values come from `GratuityPayableData`; nothing is hardcoded
/// in the UI.
struct GratuityPayableDetailView: View {
    let data: GratuityPayableData

    /// Convenience initializer so the view can be pushed without a data source
    /// during integration; defaults to the records-detail mock.
    init(data: GratuityPayableData = .recordsDetailMock) {
        self.data = data
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            titleRow
            ScrollView {
                VStack(alignment: .leading, spacing: Spacing.lg) {
                    GratuityPayableSummaryPanel(summary: data.summary)
                    GratuityPayableRecordsTable(rows: data.rows)
                    loadingMoreRow
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

    // MARK: - Title

    private var titleRow: some View {
        Text(data.title)
            .font(AppFont.tabletH3Medium)
            .foregroundColor(AppColors.textPrimary)
            .padding(.horizontal, Spacing.lg)
            .padding(.vertical, Spacing.md)
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Loading More footer

    private var loadingMoreRow: some View {
        HStack(spacing: Spacing.sm) {
            ProgressView()
                .controlSize(.small)
            Text("Loading More")
                .font(AppFont.tabletBody3Regular)
                .foregroundColor(AppColors.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .padding(.vertical, Spacing.md)
    }
}

// MARK: - Summary Panel

/// Centered summary block matching the SVG: a light-blue rounded panel with
/// three label/value rows. Net Payable Total is emphasized in blue.
private struct GratuityPayableSummaryPanel: View {
    let summary: GratuityPayableSummary

    var body: some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: Spacing.sm) {
                summaryLine("Gratuity Total", summary.gratuityTotalFormatted)
                summaryLine("Less Fees Total", summary.lessFeesTotalFormatted)
                summaryLine(
                    "Net Payable Total",
                    summary.netPayableTotalFormatted,
                    valueColor: AppColors.primaryNormal
                )
            }
            // Center the label/value group horizontally within the panel.
            .frame(maxWidth: .infinity, alignment: .center)
        }
        .padding(.vertical, Spacing.lg)
        .padding(.horizontal, Spacing.lg)
        .frame(maxWidth: .infinity)
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
                .frame(width: 180, alignment: .trailing)
            Text(value)
                .font(AppFont.tabletBody3Regular)
                .foregroundColor(valueColor)
                .frame(minWidth: 120, alignment: .leading)
                .padding(.leading, Spacing.xl)
        }
    }
}

// MARK: - Records Table

/// Adaptive 4-column table. Column widths are proportional to the available
/// width (ratios derived from the SVG), so it fills any iPad size without
/// hardcoded absolute widths. Rows grow with the data.
private struct GratuityPayableRecordsTable: View {
    let rows: [GratuityPayableRow]

    /// Column width ratios from the SVG (Employee 400 / Gratuity 261 /
    /// Less Fees 261 / Net Payable 261, total ~1184).
    private static let columnRatios: [CGFloat] = [0.338, 0.221, 0.221, 0.220]
    private static let headers = ["Employee", "Gratuity", "Less Fees", "Net Payable"]

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

    private func dataRow(_ row: GratuityPayableRow, widths: [CGFloat]) -> some View {
        HStack(spacing: 0) {
            cell(row.employee, width: widths[0])
            cell(row.gratuityFormatted, width: widths[1])
            cell(row.lessFeesFormatted, width: widths[2])
            cell(row.netPayableFormatted, width: widths[3])
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
    GratuityPayableDetailView(data: .recordsDetailMock)
}
