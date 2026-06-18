import SwiftUI

// MARK: - Discount Activities View

struct DiscountActivitiesView: View {
    let data: DiscountActivitiesData
    var onViewMoreTapped: (() -> Void)?

    @State private var expandedSections: Set<String> = []

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            headerRow
            sectionList
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

    // MARK: - Section List

    private var sectionList: some View {
        VStack(spacing: Spacing.sm) {
            ForEach(data.sections) { section in
                discountSectionCard(section)
            }
        }
        .padding(.horizontal, Spacing.md)
    }

    private func discountSectionCard(_ section: DiscountSection) -> some View {
        let isExpanded = expandedSections.contains(section.id)

        return VStack(alignment: .leading, spacing: 0) {
            // Section header
            Button {
                withAnimation {
                    if isExpanded {
                        expandedSections.remove(section.id)
                    } else {
                        expandedSections.insert(section.id)
                    }
                }
            } label: {
                HStack {
                    Text(section.name)
                        .font(AppFont.tabletBody3Regular)
                        .foregroundColor(AppColors.textPrimary)

                    HStack(spacing: Spacing.xs) {
                        Text("Discount Count")
                            .font(AppFont.tabletBody5Regular)
                            .foregroundColor(AppColors.textSecondary)
                        Text("\(section.discountCount)")
                            .font(AppFont.tabletBody5Regular)
                            .foregroundColor(AppColors.textPrimary)
                    }
                    .padding(.leading, Spacing.lg)

                    HStack(spacing: Spacing.xs) {
                        Text("Discounts Total")
                            .font(AppFont.tabletBody5Regular)
                            .foregroundColor(AppColors.textSecondary)
                        Text(section.discountsTotalFormatted)
                            .font(AppFont.tabletBody5Regular)
                            .foregroundColor(AppColors.textPrimary)
                    }
                    .padding(.leading, Spacing.lg)

                    Spacer()

                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(AppColors.textSecondary)
                }
                .padding(Spacing.md)
            }

            // Expanded table
            if isExpanded {
                VStack(spacing: 0) {
                    // Table header
                    HStack(spacing: 0) {
                        Text("Order#")
                            .font(AppFont.tabletBody5Regular)
                            .foregroundColor(AppColors.textPrimary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.leading, Spacing.xs)
                        Text("Discount Amount")
                            .font(AppFont.tabletBody5Regular)
                            .foregroundColor(AppColors.textPrimary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.leading, Spacing.xs)
                    }
                    .frame(height: 42)
                    .background(AppColors.pageBgDeep)
                    .padding(.horizontal, Spacing.md)

                    // Table rows
                    ForEach(section.orders) { order in
                        HStack(spacing: 0) {
                            Text(order.orderNumber)
                                .font(AppFont.tabletBody5Regular)
                                .foregroundColor(AppColors.primaryNormal)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.leading, Spacing.xs)
                            Text(order.discountAmountFormatted)
                                .font(AppFont.tabletBody5Regular)
                                .foregroundColor(AppColors.textPrimary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.leading, Spacing.xs)
                        }
                        .frame(height: 42)
                        .padding(.horizontal, Spacing.md)
                        .overlay(alignment: .bottom) {
                            Divider().foregroundColor(AppColors.line)
                                .padding(.horizontal, Spacing.md)
                        }
                    }
                }
                .padding(.bottom, Spacing.sm)
            }
        }
        .overlay(
            RoundedRectangle(cornerRadius: AppRadius.Tablet.sm)
                .stroke(AppColors.line, lineWidth: 1)
        )
    }

    // MARK: - Summary Footer

    private var summaryFooter: some View {
        HStack {
            Spacer()
            Text("Total Discounts")
                .font(AppFont.tabletBody3Regular)
                .foregroundColor(AppColors.textSecondary)
            Text(data.totalFormatted)
                .font(AppFont.tabletBody3Regular)
                .foregroundColor(AppColors.primaryNormal)
                .padding(.leading, Spacing.md)
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
        DiscountActivitiesView(data: .mock)
            .padding(Spacing.md)
    }
    .background(AppColors.pageBg)
}
