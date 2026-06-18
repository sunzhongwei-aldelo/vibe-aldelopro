import SwiftUI

struct LimitedAuthView: View {
    @ObservedObject var viewModel: OrderCreationViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 0) {
            // Header
            header

            Divider()

            // Content
            HStack(alignment: .top, spacing: Spacing.lg) {
                // Left: Amount input + quick amounts
                amountSection

                // Right: Numpad
                numpadSection
            }
            .padding(Spacing.lg)

            Divider()

            // Bottom buttons
            bottomButtons
        }
        .background(Color.white)
        .cornerRadius(AppRadius.Tablet.lg)
        .padding(.horizontal, Spacing.xxxxl)
        .padding(.vertical, Spacing.xxxl)
    }

    // MARK: - Header

    private var header: some View {
        HStack {
            Text("Limited Auth")
                .font(AppFont.tabletH2Medium)
                .foregroundColor(AppColors.textPrimary)
            Spacer()
            Button(action: { dismiss() }) {
                Image(systemName: "xmark")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(AppColors.textSecondary)
            }
        }
        .padding(.horizontal, Spacing.lg)
        .padding(.vertical, Spacing.md)
    }

    // MARK: - Amount Section

    private var amountSection: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text("Amount")
                .font(AppFont.tabletBody3Regular)
                .foregroundColor(AppColors.textSecondary)

            // Amount Input
            HStack {
                Text("$")
                    .font(AppFont.tabletH2Medium)
                    .foregroundColor(AppColors.textPrimary)
                Text(viewModel.authAmount)
                    .font(AppFont.tabletH2Medium)
                    .foregroundColor(AppColors.textPrimary)
                Spacer()
            }
            .padding(.horizontal, Spacing.md)
            .frame(height: 48)
            .background(Color.white)
            .overlay(
                RoundedRectangle(cornerRadius: AppRadius.Tablet.sm)
                    .stroke(AppColors.primaryNormal, lineWidth: 1.5)
            )

            // Quick Amount Chips
            HStack(spacing: Spacing.sm) {
                ForEach(viewModel.quickAmounts, id: \.self) { amount in
                    Button(action: { viewModel.selectQuickAmount(amount) }) {
                        Text("$\(NSDecimalNumber(decimal: amount).intValue).00")
                            .font(AppFont.tabletCaption1Regular)
                            .foregroundColor(AppColors.textSecondary)
                            .padding(.horizontal, Spacing.sm)
                            .padding(.vertical, Spacing.xxs)
                            .background(AppColors.pageBg)
                            .cornerRadius(AppRadius.Tablet.xs)
                    }
                }
            }
        }
        .frame(maxWidth: 240)
    }

    // MARK: - Numpad

    private var numpadSection: some View {
        let columns = Array(repeating: GridItem(.flexible(), spacing: Spacing.sm), count: 3)

        return LazyVGrid(columns: columns, spacing: Spacing.sm) {
            ForEach(1...9, id: \.self) { digit in
                numpadButton(String(digit))
            }
            // Bottom row: backspace, 0, Clear
            Button(action: { viewModel.numpadBackspace() }) {
                Image(systemName: "delete.left")
                    .font(.system(size: 20))
                    .foregroundColor(AppColors.textPrimary)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(AppColors.pageBg)
                    .cornerRadius(AppRadius.Tablet.sm)
            }

            numpadButton("0")

            Button(action: { viewModel.numpadClear() }) {
                Text("Clear")
                    .font(AppFont.tabletBody2Regular)
                    .foregroundColor(AppColors.textPrimary)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(AppColors.pageBg)
                    .cornerRadius(AppRadius.Tablet.sm)
            }
        }
        .frame(maxWidth: 280)
    }

    private func numpadButton(_ digit: String) -> some View {
        Button(action: { viewModel.numpadDigit(digit) }) {
            Text(digit)
                .font(AppFont.tabletDisplay6Medium)
                .foregroundColor(AppColors.textPrimary)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(AppColors.pageBg)
                .cornerRadius(AppRadius.Tablet.sm)
        }
    }

    // MARK: - Bottom Buttons

    private var bottomButtons: some View {
        HStack(spacing: Spacing.md) {
            Button(action: {
                dismiss()
                viewModel.onCashBar()
            }) {
                Text("Cancel")
                    .font(AppFont.tabletButton4Medium)
                    .foregroundColor(AppColors.textPrimary)
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
                    .background(Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: AppRadius.Tablet.sm)
                            .stroke(AppColors.line, lineWidth: 1)
                    )
            }

            Button(action: {
                dismiss()
                viewModel.onCashBar()
            }) {
                Text("Cash Bar")
                    .font(AppFont.tabletButton4Medium)
                    .foregroundColor(AppColors.textPrimary)
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
                    .background(Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: AppRadius.Tablet.sm)
                            .stroke(AppColors.line, lineWidth: 1)
                    )
            }

            Button(action: {
                dismiss()
                viewModel.onAuthContinue()
            }) {
                Text("Continue")
                    .font(AppFont.tabletButton4Medium)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
                    .background(AppColors.buttonPrimaryBg)
                    .cornerRadius(AppRadius.Tablet.sm)
            }
        }
        .padding(.horizontal, Spacing.lg)
        .padding(.vertical, Spacing.md)
    }
}

// MARK: - Preview

#Preview {
    LimitedAuthView(viewModel: OrderCreationViewModel(orderType: .bar))
}
