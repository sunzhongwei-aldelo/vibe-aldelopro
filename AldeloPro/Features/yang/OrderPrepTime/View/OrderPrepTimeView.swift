import SwiftUI

// MARK: - Order Prep Time View

struct OrderPrepTimeView: View {
    @State private var viewModel = OrderPrepTimeViewModel()
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 0) {
            headerBar
            Divider()

            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    settingsSection
                    platformTabs
                    contentSection
                }
                .padding(.horizontal, Spacing.xx166)
                .padding(.top, 12)
                .padding(.bottom, 20)
            }
        }
        .background(AppColors.pageBg)
    }

    // MARK: - Header Bar

    private var headerBar: some View {
        HStack(spacing: 16) {
            Image(systemName: "clock")
                .font(.system(size: 16))
                .foregroundStyle(AppColors.textPrimary)
            Text("Order Prep Time")
                .font(.system(size: 18, weight: .medium))
                .foregroundStyle(AppColors.textPrimary)

            Spacer()

            HeaderActionButtons(
                onBack: { dismiss() },
                onConfirm: { viewModel.confirm() }
            )
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 14)
        .background(AppColors.pageBg.opacity(0.5))
    }

    // MARK: - Settings Section

    private var settingsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Order Prep Time Settings")
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(AppColors.textPrimary)

            HStack(spacing: 12) {
                Text("Uniform Weekly Prep Time")
                    .font(.system(size: 13))
                    .foregroundStyle(AppColors.textSecondary)
                Toggle("", isOn: $viewModel.isUniformWeekly)
                    .labelsHidden()
                    .tint(AppColors.primaryNormal)
            }

            Divider()

            Text("Daily Order Prep Time for Third-Party Platforms")
                .font(.system(size: 12))
                .foregroundStyle(AppColors.textPrimary)
        }
    }

    // MARK: - Platform Tabs

    private var platformTabs: some View {
        HStack(spacing: 0) {
            ForEach(PrepTimePlatform.allCases) { platform in
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        viewModel.selectedPlatform = platform
                    }
                } label: {
                    Text(platform.rawValue)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(
                            viewModel.selectedPlatform == platform
                                ? AppColors.primaryNormal
                                : AppColors.textTertiary
                        )
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(
                            viewModel.selectedPlatform == platform
                                ? Color.white
                                : Color.clear
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
            }
            Spacer()
        }
        .padding(4)
        .background(AppColors.pageBg)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(AppColors.line, lineWidth: 1)
        )
    }

    // MARK: - Content Section

    @ViewBuilder
    private var contentSection: some View {
        if viewModel.isUniformWeekly {
            PrepTimeDayCard(title: nil) {
                PrepTimeOrderTypeGrid(
                    orderTypes: viewModel.orderTypesForCurrentPlatform,
                    getSelection: { viewModel.uniformTime(orderType: $0) },
                    setSelection: { viewModel.setUniformTime(orderType: $0, option: $1) }
                )
            }
        } else {
            ForEach(PrepTimeDayOfWeek.allCases) { day in
                if viewModel.closedDays.contains(day) {
                    closedDayRow(day: day)
                } else {
                    PrepTimeDayCard(title: day.rawValue) {
                        PrepTimeOrderTypeGrid(
                            orderTypes: viewModel.orderTypesForCurrentPlatform,
                            getSelection: { viewModel.selectedTime(day: day, orderType: $0) },
                            setSelection: { viewModel.setTime(day: day, orderType: $0, option: $1) }
                        )
                    }
                }
            }
        }
    }

    private func closedDayRow(day: PrepTimeDayOfWeek) -> some View {
        HStack(spacing: 12) {
            Text(day.rawValue)
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(AppColors.textPrimary)
            Text("Closed")
                .font(.system(size: 12))
                .foregroundStyle(AppColors.textSecondary)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppColors.pageBg)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(AppColors.line, lineWidth: 1)
        )
    }
}

// MARK: - Preview

#Preview {
    OrderPrepTimeView()
}
