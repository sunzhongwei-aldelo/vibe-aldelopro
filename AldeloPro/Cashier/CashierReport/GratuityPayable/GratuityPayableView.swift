import SwiftUI

// MARK: - Gratuity Payable View

struct GratuityPayableView: View {
    let data: GratuityPayableData
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

    /// Column width ratios from SVG design (Employee: 400, others: 261 each, total ~1184px)
    private static let columnRatios: [CGFloat] = [0.338, 0.220, 0.220, 0.222]

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
            headerCell("Employee", width: widths[0])
            headerCell("Gratuity", width: widths[1])
            headerCell("Less Fees", width: widths[2])
            headerCell("Net Payable", width: widths[3])
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

    private func tableDataRow(_ row: GratuityPayableRow, widths: [CGFloat]) -> some View {
        HStack(spacing: 0) {
            dataCell(row.employee, width: widths[0])
            dataCell(row.gratuityFormatted, width: widths[1])
            dataCell(row.lessFeesFormatted, width: widths[2])
            dataCell(row.netPayableFormatted, width: widths[3])
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

    // MARK: - Summary

    private var summarySection: some View {
        VStack(spacing: 0) {
            // Top group: Gratuity Total / Less Fees Total
            HStack(spacing: 0) {
                Spacer()
                VStack(alignment: .trailing, spacing: Spacing.xs) {
                    Text("Gratuity Total")
                        .font(AppFont.tabletBody5Regular)
                        .foregroundColor(AppColors.textSecondary)
                    Text("Less Fees Total")
                        .font(AppFont.tabletBody5Regular)
                        .foregroundColor(AppColors.textSecondary)
                }
                VStack(alignment: .leading, spacing: Spacing.xs) {
                    Text(data.summary.gratuityTotalFormatted)
                        .font(AppFont.tabletBody5Regular)
                        .foregroundColor(AppColors.textPrimary)
                    Text(data.summary.lessFeesTotalFormatted)
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
                .padding(.leading, 200)

            // Net Payable Total
            HStack(spacing: 0) {
                Spacer()
                Text("Net Payable Total")
                    .font(AppFont.tabletBody3Regular)
                    .foregroundColor(AppColors.textSecondary)
                Text(data.summary.netPayableTotalFormatted)
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
}

// MARK: - Preview

#Preview {
    ScrollView {
        GratuityPayableView(data: .mock)
            .padding(Spacing.md)
    }
    .background(AppColors.pageBg)
}
