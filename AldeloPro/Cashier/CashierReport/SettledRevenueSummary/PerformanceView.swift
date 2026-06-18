//
//  PerformanceView.swift
//  AldeloPro
//

import SwiftUI

struct PerformanceView: View {
    let data: PerformanceData
    @State private var selectedTab: PerformanceTab
    @State private var currentPage: Int
    @State private var barAreaWidth: CGFloat = 200

    init(data: PerformanceData) {
        self.data = data
        self._selectedTab = State(initialValue: data.selectedTab)
        self._currentPage = State(initialValue: data.currentPage)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            headerSection
            tabBarSection
            tableHeaderSection
            tableRowsSection
            paginationSection
        }
        .padding(.vertical, Spacing.md)
        .background(AppColors.card)
        .cornerRadius(AppRadius.Tablet.lg)
    }

    // MARK: - Header

    private var headerSection: some View {
        Text(data.title)
            .font(AppFont.tabletH4Medium)
            .foregroundColor(AppColors.textPrimary)
            .padding(.bottom, Spacing.md)
            .padding(.horizontal, Spacing.md)
    }

    // MARK: - Tab Bar

    private var tabBarSection: some View {
        HStack(spacing: 0) {
            ForEach(PerformanceTab.allCases, id: \.self) { tab in
                Button {
                    selectedTab = tab
                } label: {
                    Text(tab.rawValue)
                        .font(AppFont.tabletH6Medium)
                        .foregroundColor(selectedTab == tab ? AppColors.primaryNormal : AppColors.textTertiary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, Spacing.sm)
                        .background(selectedTab == tab ? AppColors.primaryLight : Color.clear)
                        .cornerRadius(AppRadius.Tablet.sm)
                }
            }
        }
        .padding(Spacing.xxs)
        .overlay(
            RoundedRectangle(cornerRadius: AppRadius.Tablet.sm)
                .stroke(AppColors.textSecondary, lineWidth: 1)
        )
        .padding(.horizontal, Spacing.md)
        .padding(.bottom, Spacing.md)
    }

    // MARK: - Table Header

    private var tableHeaderSection: some View {
        HStack(spacing: 0) {
            Text("Category")
                .frame(alignment: .leading)
            
            Text("Category Total")
                .frame(alignment: .leading)
                .padding(.leading, Spacing.xxl)
            Text("Line Discounts | Category Sales")
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, Spacing.xxl)
        }
        .font(AppFont.tabletH6Medium)
        .foregroundColor(AppColors.textPrimary)
        .padding(.horizontal, Spacing.lg)
        .padding(.vertical, Spacing.sm)
        .background(AppColors.pageBg)
    }

    // MARK: - Table Rows

    private var tableRowsSection: some View {
        ForEach(data.rows) { row in
            VStack(spacing: 0) {
                HStack(spacing: 0) {
                    rankAndNameCell(row: row)
                    totalCell(row: row)
                    barCell(row: row)
                }
                .padding(.horizontal, Spacing.lg)
                .padding(.vertical, Spacing.sm)

                Divider()
                    .padding(.horizontal, Spacing.md)
            }
        }
    }

    private func rankAndNameCell(row: PerformanceRow) -> some View {
        HStack(spacing: Spacing.sm) {
            Text("\(row.rank)")
                .font(AppFont.tabletCaption1Regular)
                .foregroundColor(AppColors.primaryNormal)
                .frame(width: 20, height: 20)
                .background(AppColors.primaryLight)
                .cornerRadius(2)
            Text(row.categoryName)
                .font(AppFont.tabletBody5Regular)
                .foregroundColor(AppColors.textPrimary)
        }
        .frame(width: 120, alignment: .leading)
    }

    private func totalCell(row: PerformanceRow) -> some View {
        Text(row.categoryTotal)
            .font(AppFont.tabletBody5Regular)
            .foregroundColor(AppColors.textPrimary)
            .frame(width: 100, alignment: .leading)
    }

    private func barCell(row: PerformanceRow) -> some View {
        HStack(spacing: Spacing.xs) {
            Text(row.lineDiscounts)
                .font(AppFont.tabletH6Medium)
                .foregroundColor(AppColors.textPrimary)

            RoundedRectangle(cornerRadius: 2)
                .fill(AppColors.errorNormal)
                .frame(
                    width: row.discountBarWidth(maxAmount: data.maxBarAmount, availableWidth: barAreaWidth * 0.3),
                    height: 20
                )
                .opacity(row.lineDiscountsAmount > 0 ? 1 : 0)

            Divider()
                .frame(height: 28)

            RoundedRectangle(cornerRadius: AppRadius.Tablet.sm)
                .fill(AppColors.primaryNormal.opacity(0.8))
                .frame(
                    width: row.salesBarWidth(maxAmount: data.maxBarAmount, availableWidth: barAreaWidth * 0.5),
                    height: 20
                )
                .opacity(row.categorySalesAmount > 0 ? 1 : 0)

            Text(row.categorySales)
                .font(AppFont.tabletH6Medium)
                .foregroundColor(AppColors.textPrimary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            GeometryReader { geo in
                Color.clear.onAppear { barAreaWidth = geo.size.width }
            }
        )
    }

    // MARK: - Pagination

    private var paginationSection: some View {
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
}

#Preview {
    PerformanceView(data: .mock)
        .frame(width: 514, height: 300)
        .padding()
        .background(AppColors.pageBg)
}
