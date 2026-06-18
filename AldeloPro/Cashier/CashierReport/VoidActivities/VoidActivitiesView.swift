import SwiftUI

// MARK: - Void Activities View

struct VoidActivitiesView: View {
    let data: VoidActivitiesData
    var onViewMoreTapped: (() -> Void)?

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            headerRow
            cardList
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

    // MARK: - Card List

    private var cardList: some View {
        VStack(spacing: Spacing.sm) {
            ForEach(data.items) { item in
                voidCard(item)
            }
        }
        .padding(.horizontal, Spacing.md)
    }

    private func voidCard(_ item: VoidActivityItem) -> some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            // Order number
            Text(item.orderNumber)
                .font(AppFont.tabletBody3Regular)
                .foregroundColor(AppColors.primaryNormal)

            // Row 2: Void Action | Void Item | Item Qty | Sub Total
            HStack(spacing: Spacing.lg) {
                labelValueWithBadge(label: "Void Action", badge: item.voidAction)
                labelValue(label: "Void Item", value: item.voidItemName)
                labelValue(label: "Item Oty", value: "\(item.itemQty)")
                labelValue(label: "Sub Total", value: item.subTotalFormatted)
                Spacer()
            }

            // Row 3: Employee | Manager | Void Reason
            HStack(spacing: Spacing.lg) {
                labelValue(label: "Employee", value: item.employee)
                labelValue(label: "Manager", value: item.manager)
                labelValue(label: "Void Reason", value: item.voidReason)
                Spacer()
            }
        }
        .padding(Spacing.md)
        .overlay(
            RoundedRectangle(cornerRadius: AppRadius.Tablet.lg)
                .stroke(AppColors.line, lineWidth: 1)
        )
    }

    private func labelValue(label: String, value: String) -> some View {
        HStack(spacing: Spacing.xs) {
            Text(label)
                .font(AppFont.tabletBody5Regular)
                .foregroundColor(AppColors.textSecondary)
            Text(value)
                .font(AppFont.tabletBody5Regular)
                .foregroundColor(AppColors.textPrimary)
        }
    }

    private func labelValueWithBadge(label: String, badge: VoidActionType) -> some View {
        HStack(spacing: Spacing.xs) {
            Text(label)
                .font(AppFont.tabletBody5Regular)
                .foregroundColor(AppColors.textSecondary)
            Text(badge.displayText)
                .font(AppFont.tabletBody5Regular)
                .foregroundColor(badge.badgeColor)
                .padding(.horizontal, Spacing.xs)
                .padding(.vertical, Spacing.xxs)
                .background(badge.badgeColor.opacity(0.08))
                .clipShape(RoundedRectangle(cornerRadius: AppRadius.Tablet.xs))
        }
    }

    // MARK: - Summary Footer

    private var summaryFooter: some View {
        HStack {
            Spacer()
            Text("Order & Line Voids Total")
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
        VoidActivitiesView(data: .mock)
            .padding(Spacing.md)
    }
    .background(AppColors.pageBg)
}
