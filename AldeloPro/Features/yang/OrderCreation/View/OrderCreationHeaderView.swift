import SwiftUI

struct OrderCreationHeaderView: View {
    @ObservedObject var viewModel: OrderCreationViewModel

    var body: some View {
        HStack(spacing: Spacing.md) {
            // Order Type Badge
            orderTypeBadge

            // Order Number + Table
            orderInfo

            Spacer()

            // Server
            HStack(spacing: Spacing.xs) {
                Text("Server:")
                    .font(AppFont.tabletBody3Regular)
                    .foregroundColor(AppColors.textSecondary)
                Text(viewModel.serverName)
                    .font(AppFont.tabletH4Medium)
                    .foregroundColor(AppColors.textPrimary)
            }

            // Back Button
            Button(action: { viewModel.onBack() }) {
                Text("Back")
                    .font(AppFont.tabletButton4Medium)
                    .foregroundColor(AppColors.textPrimary)
                    .frame(width: 80, height: 36)
                    .background(Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: AppRadius.Tablet.sm)
                            .stroke(AppColors.line, lineWidth: 1)
                    )
            }

            // Continue Button
            Button(action: { viewModel.onContinue() }) {
                Text("Continue")
                    .font(AppFont.tabletButton4Medium)
                    .foregroundColor(.white)
                    .frame(width: 100, height: 36)
                    .background(AppColors.buttonPrimaryBg)
                    .cornerRadius(AppRadius.Tablet.sm)
            }
        }
        .padding(.horizontal, Spacing.md)
        .padding(.vertical, Spacing.sm)
        .background(Color.white)
    }

    // MARK: - Order Type Badge

    private var orderTypeBadge: some View {
        Button(action: { viewModel.cycleOrderType() }) {
            HStack(spacing: Spacing.xs) {
                Image(systemName: viewModel.orderType.iconName)
                    .font(.system(size: 16))
                    .foregroundColor(.white)
                    .frame(width: 32, height: 32)
                    .background(viewModel.orderType.badgeColor)
                    .cornerRadius(AppRadius.Tablet.xs)

                VStack(alignment: .leading, spacing: 0) {
                    Text(viewModel.orderType.rawValue)
                        .font(AppFont.tabletH5Medium)
                        .foregroundColor(AppColors.textPrimary)
                    Text("1200002")
                        .font(AppFont.tabletCaption2Regular)
                        .foregroundColor(AppColors.textTertiary)
                }
            }
        }
    }

    // MARK: - Order Info

    private var orderInfo: some View {
        HStack(spacing: Spacing.xs) {
            Text(viewModel.orderNumber)
                .font(AppFont.tabletH3Medium)
                .foregroundColor(AppColors.textPrimary)

            if viewModel.orderType.requiresTable {
                HStack(spacing: 2) {
                    Image(systemName: "fork.knife")
                        .font(.system(size: 12))
                        .foregroundColor(AppColors.textSecondary)
                    Text(viewModel.tableNumber)
                        .font(AppFont.tabletH4Medium)
                        .foregroundColor(AppColors.textPrimary)
                }
            }
        }
    }
}

// MARK: - Preview

#Preview {
    OrderCreationHeaderView(
        viewModel: OrderCreationViewModel(orderType: .dineIn)
    )
}
