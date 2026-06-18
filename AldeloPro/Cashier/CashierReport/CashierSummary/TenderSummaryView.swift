//
//  TenderSummaryView.swift
//  AldeloPro
//

import SwiftUI

struct TenderSummaryView: View {
    let data: TenderSummaryData
    @State private var currentPage: Int

    init(data: TenderSummaryData) {
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

            // Summary Cards
            summaryCardsSection
                .padding(.bottom, Spacing.md)

            // Table Header
            HStack(spacing: 0) {
                Text("Tender")
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text("Tender Count")
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text("Payments Total")
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text("Tips Added Total")
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text("Tendered Total")
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .font(AppFont.tabletH6Medium)
            .foregroundColor(AppColors.textPrimary)
            .padding(.horizontal, Spacing.lg)
            .padding(.vertical, Spacing.sm)
            .background(AppColors.pageBg)

            // Table Rows
            ForEach(data.rows) { row in
                HStack(spacing: 0) {
                    Text(row.tender)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Text("\(row.tenderCount)")
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Text(row.paymentsTotal)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Text(row.tipsAddedTotal)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Text(row.tenderedTotal)
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

    private var summaryCardsSection: some View {
        let rows = stride(from: 0, to: data.summaryCards.count, by: 2).map { startIndex in
            Array(data.summaryCards[startIndex..<min(startIndex + 2, data.summaryCards.count)])
        }

        return VStack(spacing: Spacing.sm) {
            ForEach(rows.indices, id: \.self) { rowIndex in
                HStack(spacing: Spacing.sm) {
                    ForEach(rows[rowIndex].indices, id: \.self) { cardIndex in
                        summaryCardView(rows[rowIndex][cardIndex])
                    }
                    if rows[rowIndex].count < 2 {
                        Text("")
                            .frame(maxWidth: .infinity)
                    }
                }
            }
        }
        .padding(.horizontal, Spacing.md)
    }

    private func summaryCardView(_ card: TenderSummaryCard) -> some View {
        HStack(spacing: Spacing.sm) {
            Image(systemName: card.icon)
                .foregroundColor(AppColors.textSecondary)
            Text(card.label)
                .font(AppFont.tabletH4Medium)
                .foregroundColor(AppColors.textSecondary)
            Spacer()
            Text(card.amount)
                .font(AppFont.tabletH4Medium)
                .foregroundColor(AppColors.textPrimary)
        }
        .padding(.horizontal, Spacing.md)
        .padding(.vertical, Spacing.sm)
        .frame(maxWidth: .infinity)
        .background(AppColors.primaryLight)
        .cornerRadius(AppRadius.Tablet.sm)
    }
}

#Preview {
    TenderSummaryView(data: .mock)
        .padding()
        .background(AppColors.pageBg)
}
