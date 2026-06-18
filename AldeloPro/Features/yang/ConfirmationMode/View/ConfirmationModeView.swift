import SwiftUI

struct ConfirmationModeView: View {
    @State private var viewModel = ConfirmationModeViewModel()
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 0) {
            headerBar
            scrollContent
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppColors.pageBg)
        .ignoresSafeArea(edges: .all)
    }

    // MARK: - Header Bar

    private var headerBar: some View {
        HStack(spacing: Spacing.sm) {
            HStack(spacing: Spacing.xs) {
                Image(systemName: "doc.text")
                    .font(.system(size: 22))
                    .foregroundStyle(AppColors.textPrimary)
                Text("Confirmation Mode")
                    .font(AppFont.tabletH1Medium)
                    .foregroundStyle(AppColors.textPrimary)
            }

            Spacer()

            HeaderActionButtons(
                onBack: { dismiss() },
                onConfirm: { viewModel.confirm() }
            )
        }
        .padding(.horizontal, Spacing.lg)
        .padding(.vertical, Spacing.sm)
    }

    // MARK: - Scroll Content

    private var scrollContent: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.lg) {
                orderSettingsSection
                if !viewModel.isOrdersTurnedOff {
                    confirmationMethodSection
                    thirdPartySection
                }
                soundNotificationSection
            }
            .padding(.horizontal, Spacing.xx166)
            .padding(.top, Spacing.md)
            .padding(.bottom, Spacing.xl)
        }
    }

    // MARK: - Order Settings

    private var orderSettingsSection: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            HStack {
                Text("Order Confirmation Settings")
                    .font(AppFont.tabletH3Medium)
                    .foregroundStyle(AppColors.textPrimary)

                Spacer()
            }

            HStack(spacing: Spacing.sm) {
                Text("Turn off new online orders temporarily")
                    .font(AppFont.tabletBody2Regular)
                    .foregroundStyle(AppColors.textSecondary)
                Toggle("", isOn: $viewModel.isOrdersTurnedOff)
                    .labelsHidden()
                    .tint(AppColors.primaryNormal)
            }
        }
    }

    // MARK: - Confirmation Method

    private var confirmationMethodSection: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Divider()
                .foregroundColor(AppColors.line)

            Text("Order Confirmation Method")
                .font(AppFont.tabletBody3Regular)
                .foregroundStyle(AppColors.textSecondary)

            HStack(spacing: 0) {
                ForEach(ConfirmationMethod.allCases, id: \.self) { method in
                    methodTab(method)
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: AppRadius.Tablet.sm))
            .overlay(
                RoundedRectangle(cornerRadius: AppRadius.Tablet.sm)
                    .stroke(AppColors.line, lineWidth: 1)
            )
        }
    }

    private func methodTab(_ method: ConfirmationMethod) -> some View {
        let isSelected = viewModel.confirmationMethod == method
        return Button {
            viewModel.confirmationMethod = method
        } label: {
            Text(method.rawValue)
                .font(AppFont.tabletBody2Regular)
                .frame(width: 200)
                .foregroundStyle(isSelected ? AppColors.primaryNormal : AppColors.textSecondary)
                .padding(.horizontal, Spacing.lg)
                .padding(.vertical, Spacing.sm)
                .background(isSelected ? Color.white : Color.clear)
//                .clipShape(RoundedRectangle(cornerRadius: AppRadius.Tablet.sm))
        }
    }

    // MARK: - Third Party Platforms

    private var thirdPartySection: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text("Enable Third-Party Order Confirmation")
                .font(AppFont.tabletBody3Regular)
                .foregroundStyle(AppColors.textSecondary)

            let columns = [
                GridItem(.flexible(), spacing: Spacing.sm),
                GridItem(.flexible(), spacing: Spacing.sm)
            ]

            LazyVGrid(columns: columns, spacing: Spacing.sm) {
                ForEach(Array(viewModel.platforms.enumerated()), id: \.element.id) { index, platform in
                    platformRow(platform: platform, index: index)
                }
            }
        }
    }

    private func platformRow(platform: ThirdPartyPlatform, index: Int) -> some View {
        HStack(spacing: Spacing.xs) {
            Image(systemName: platform.iconName)
                .font(.system(size: 10))
                .foregroundStyle(.white)
                .frame(width: 20, height: 20)
                .background(Color(hex: platform.iconColor))
                .clipShape(RoundedRectangle(cornerRadius: AppRadius.Tablet.xs))

            Text(platform.name)
                .font(AppFont.tabletBody2Regular)
                .foregroundStyle(AppColors.textPrimary)

            if viewModel.confirmationMethod == .manuallyConfirm && platform.isEnabled {
                Text(platform.timeoutLabel)
                    .font(AppFont.tabletBody3Regular)
                    .foregroundStyle(AppColors.successNormal)
            }

            Spacer()

            Toggle("", isOn: Binding(
                get: { platform.isEnabled },
                set: { _ in viewModel.togglePlatform(at: index) }
            ))
                .labelsHidden()
                .tint(AppColors.primaryNormal)
        }
        .padding(.horizontal, Spacing.md)
        .padding(.vertical, Spacing.sm)
        .background(AppColors.card)
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.Tablet.sm))
    }

    // MARK: - Sound Notification

    private var soundNotificationSection: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text("New Order Sound Notification")
                .font(AppFont.tabletH3Medium)
                .foregroundStyle(AppColors.textPrimary)

            HStack(spacing: Spacing.sm) {
                Text("Turn on new order sound notification")
                    .font(AppFont.tabletBody2Regular)
                    .foregroundStyle(AppColors.textSecondary)
                Toggle("", isOn: $viewModel.isSoundNotificationOn)
                    .labelsHidden()
                    .tint(AppColors.primaryNormal)
            }
        }
    }
}

// MARK: - Preview

#Preview {
    ConfirmationModeView()
}
