//
//  TaxSummaryView.swift
//  AldeloPro
//

import SwiftUI

struct TaxSummaryView: View {
    let data: TaxSummaryData
    @State private var currentPage: Int

    init(data: TaxSummaryData) {
        self.data = data
        self._currentPage = State(initialValue: data.currentPage)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Title
            Text(data.title)
                .font(AppFont.tabletH4Medium)
                .foregroundColor(AppColors.textPrimary)
                .padding(.bottom, Spacing.md)
                .padding(.horizontal, Spacing.md)

            // Banner
            HStack {
                Text(data.bannerLabel)
                    .font(AppFont.tabletH4Medium)
                    .foregroundColor(AppColors.textSecondary)
                Text(data.bannerAmount)
                    .font(AppFont.tabletH4Medium)
                    .foregroundColor(AppColors.primaryNormal)
                Spacer()
            }
            .padding(.horizontal, Spacing.md)
            .padding(.vertical, Spacing.sm)
            .background(AppColors.primaryLight)
            .cornerRadius(AppRadius.Tablet.sm)
            .padding(.horizontal, Spacing.md)
            .padding(.bottom, Spacing.md)

            // Table Header
            HStack(spacing: 0) {
                Text("Tax Name")
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text("Taxable Sub Total")
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text("Non Taxable")
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text("Tax Exempt")
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text("Non-Inclusive Taxes Collected")
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .font(AppFont.tabletH6Medium)
            .foregroundColor(AppColors.textPrimary.opacity(0.85))
            .padding(.horizontal, Spacing.lg)
            .padding(.vertical, Spacing.sm)
            .background(AppColors.pageBg)

            // Table Rows
            ForEach(data.rows) { row in
                HStack(spacing: 0) {
                    Text(row.taxName)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Text(row.taxableSubTotal)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Text(row.nonTaxable)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Text(row.taxExempt)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Text(row.nonInclusiveTaxesCollected)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .font(AppFont.tabletBody5Regular)
                .foregroundColor(AppColors.textPrimary)
                .padding(.horizontal, Spacing.lg)
                .padding(.vertical, Spacing.sm)

                Divider()
                    .padding(.horizontal, Spacing.md)
            }

            // Pagination
            HStack {
                Text("Total ")
                    .font(AppFont.tabletBody5Regular)
                    .foregroundColor(AppColors.textSecondary)
                + Text("\(data.totalCount)")
                    .font(AppFont.tabletBody5Regular)
                    .foregroundColor(AppColors.textPrimary)

                Spacer()

                Text("Page ")
                    .font(AppFont.tabletBody5Regular)
                    .foregroundColor(AppColors.textSecondary)
                + Text("\(currentPage)")
                    .font(AppFont.tabletH6Medium)
                    .foregroundColor(AppColors.textPrimary)
                + Text(" Of \(data.totalPages)")
                    .font(AppFont.tabletBody5Regular)
                    .foregroundColor(AppColors.textSecondary)

                HStack(spacing: Spacing.sm) {
                    Button {
                        if currentPage > 1 { currentPage -= 1 }
                    } label: {
                        Image(systemName: "chevron.left")
                            .foregroundColor(AppColors.textPrimary)
                            .frame(width: 44, height: 44)
                            .overlay(
                                RoundedRectangle(cornerRadius: AppRadius.Tablet.md)
                                    .stroke(AppColors.line, lineWidth: 1)
                            )
                    }
                    Button {
                        if currentPage < data.totalPages { currentPage += 1 }
                    } label: {
                        Image(systemName: "chevron.right")
                            .foregroundColor(AppColors.textPrimary)
                            .frame(width: 44, height: 44)
                            .overlay(
                                RoundedRectangle(cornerRadius: AppRadius.Tablet.md)
                                    .stroke(AppColors.line, lineWidth: 1)
                            )
                    }
                }
            }
            .padding(.horizontal, Spacing.md)
            .padding(.top, Spacing.md)
        }
        .padding(.vertical, Spacing.md)
        .background(AppColors.card)
        .cornerRadius(AppRadius.Tablet.lg)
    }
}

#Preview {
    TaxSummaryView(data: .mock)
        .padding()
        .background(AppColors.pageBg)
}
