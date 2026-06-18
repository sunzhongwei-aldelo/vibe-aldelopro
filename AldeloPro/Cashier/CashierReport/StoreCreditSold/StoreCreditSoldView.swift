import SwiftUI

// MARK: - Store Credit Sold View

struct StoreCreditSoldView: View {
    let data: StoreCreditSoldData
    var onViewMoreTapped: (() -> Void)?

    /// Column ratios from SVG: 280/301.333/301.337/301.33 ≈ total 1184
    private static let columnRatios: [CGFloat] = [0.236, 0.254, 0.255, 0.255]

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
            headerCell("Store Credit", width: widths[0])
            headerCell("Count", width: widths[1])
            headerCell("Face Value", width: widths[2])
            headerCell("Paid Amount", width: widths[3])
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

    private func tableDataRow(_ row: StoreCreditRow, widths: [CGFloat]) -> some View {
        HStack(spacing: 0) {
            Text(row.storeCredit)
                .font(AppFont.tabletBody5Regular)
                .foregroundColor(AppColors.textPrimary)
                .frame(width: widths[0], alignment: .leading)
                .padding(.leading, Spacing.xs)
            Text("\(row.count)")
                .font(AppFont.tabletBody5Regular)
                .foregroundColor(AppColors.textPrimary)
                .frame(width: widths[1], alignment: .leading)
                .padding(.leading, Spacing.xs)
            Text(row.faceValueFormatted)
                .font(AppFont.tabletBody5Regular)
                .foregroundColor(AppColors.textPrimary)
                .frame(width: widths[2], alignment: .leading)
                .padding(.leading, Spacing.xs)
            Text(row.paidAmountFormatted)
                .font(AppFont.tabletBody5Regular)
                .foregroundColor(AppColors.textPrimary)
                .frame(width: widths[3], alignment: .leading)
                .padding(.leading, Spacing.xs)
        }
        .frame(height: 42)
        .overlay(alignment: .bottom) {
            Divider().foregroundColor(AppColors.line)
        }
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
        StoreCreditSoldView(data: .mock)
            .padding(Spacing.md)
    }
    .background(AppColors.pageBg)
}
