//
//  DiscountActivitiesDetailView.swift
//  AldeloPro
//

import SwiftUI

// MARK: - Discount Activities Records Detail (full page)

/// Full-page detail for Discount Activities. Mirrors `DiscountActivitiesDetail.svg`:
/// title → centered "Total Discounts" summary bar → list of expandable discount
/// section cards, each with a header (name / count / total) and an Order#
/// + Discount Amount table.
///
/// Layout is fully adaptive — no fixed view width/height. Tables use flexible
/// columns and the page grows with its content. All values come from
/// `DiscountActivitiesData`.
struct DiscountActivitiesDetailView: View {
    let data: DiscountActivitiesData

    /// Sections start expanded (matching the SVG, which shows the rows inline).
    @State private var expandedSections: Set<String>

    init(
        data: DiscountActivitiesData = .recordsDetailMock,
        initiallyExpanded: Bool = true
    ) {
        self.data = data
        let ids = initiallyExpanded ? Set(data.sections.map { $0.id }) : []
        _expandedSections = State(initialValue: ids)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            titleRow
            ScrollView {
                VStack(alignment: .leading, spacing: Spacing.lg) {
                    totalSummaryBar
                    ForEach(data.sections) { section in
                        DiscountSectionCard(
                            section: section,
                            isExpanded: expandedSections.contains(section.id),
                            onToggle: { toggle(section.id) }
                        )
                    }
                }
                .padding(.horizontal, Spacing.lg)
                .padding(.bottom, Spacing.lg)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(AppColors.pageBgDeep.ignoresSafeArea())
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.Tablet.sm))
        .navigationBarHidden(true)
        .background(SwipeBackGestureEnabler())
    }

    private func toggle(_ id: String) {
        withAnimation {
            if expandedSections.contains(id) {
                expandedSections.remove(id)
            } else {
                expandedSections.insert(id)
            }
        }
    }

    private var titleRow: some View {
        Text(data.title)
            .font(AppFont.tabletH3Medium)
            .foregroundColor(AppColors.textPrimary)
            .padding(.horizontal, Spacing.lg)
            .padding(.vertical, Spacing.md)
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Total Discounts summary bar

    private var totalSummaryBar: some View {
        HStack(spacing: 0) {
            Text("Total Discounts")
                .font(AppFont.tabletBody3Regular)
                .foregroundColor(AppColors.textSecondary)
            Text(data.totalFormatted)
                .font(AppFont.tabletBody3Regular)
                .foregroundColor(AppColors.primaryNormal)
                .padding(.leading, Spacing.lg)
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .padding(.vertical, Spacing.md)
        .background(AppColors.primaryLight)
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.Tablet.xs))
    }
}

// MARK: - Section Card

private struct DiscountSectionCard: View {
    let section: DiscountSection
    let isExpanded: Bool
    let onToggle: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            header
            if isExpanded {
                orderTable
            }
        }
        .overlay(
            RoundedRectangle(cornerRadius: AppRadius.Tablet.sm)
                .stroke(AppColors.line, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.Tablet.sm))
    }

    private var header: some View {
        Button(action: onToggle) {
            HStack(spacing: 0) {
                Text(section.name)
                    .font(AppFont.tabletBody3Regular)
                    .foregroundColor(AppColors.textPrimary)

                metric("Discount Count", "\(section.discountCount)")
                    .padding(.leading, Spacing.xl)
                metric("Discounts Total", section.discountsTotalFormatted)
                    .padding(.leading, Spacing.xl)

                Spacer()

                Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(AppColors.textSecondary)
            }
            .padding(Spacing.md)
        }
    }

    private func metric(_ label: String, _ value: String) -> some View {
        HStack(spacing: Spacing.xs) {
            Text(label)
                .font(AppFont.tabletBody5Regular)
                .foregroundColor(AppColors.textSecondary)
            Text(value)
                .font(AppFont.tabletBody5Regular)
                .foregroundColor(AppColors.textPrimary)
        }
    }

    // MARK: - Order table (Order# / Discount Amount)

    private var orderTable: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                tableHeaderCell("Order#")
                tableHeaderCell("Discount Amount")
            }
            .frame(height: 56)
            .background(AppColors.buttonSecondaryBg)

            ForEach(section.orders) { order in
                HStack(spacing: 0) {
                    cell(order.orderNumber, color: AppColors.primaryNormal)
                    cell(order.discountAmountFormatted, color: AppColors.textPrimary)
                }
                .frame(height: 56)
                .overlay(alignment: .bottom) {
                    Rectangle()
                        .fill(AppColors.line.opacity(0.5))
                        .frame(height: 0.5)
                }
            }
        }
    }

    private func tableHeaderCell(_ title: String) -> some View {
        Text(title)
            .font(AppFont.tabletBody5Regular)
            .foregroundColor(AppColors.textPrimary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.leading, Spacing.md)
    }

    private func cell(_ text: String, color: Color) -> some View {
        Text(text)
            .font(AppFont.tabletBody5Regular)
            .foregroundColor(color)
            .lineLimit(1)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.leading, Spacing.md)
    }
}

// MARK: - Preview

#Preview {
    DiscountActivitiesDetailView(data: .recordsDetailMock)
}
