import SwiftUI

struct LimitedAuthGridView: View {
    @ObservedObject var viewModel: OrderCreationViewModel
    @Environment(\.dismiss) private var dismiss

    private let columns = Array(repeating: GridItem(.flexible(), spacing: Spacing.md), count: 3)

    var body: some View {
        VStack(spacing: 0) {
            // Header
            header

            Divider()

            // Amount Grid
            amountGrid

            Divider()

            // Bottom Buttons
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

    // MARK: - Amount Grid

    private var amountGrid: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text("Amount")
                .font(AppFont.tabletBody3Regular)
                .foregroundColor(AppColors.textSecondary)

            LazyVGrid(columns: columns, spacing: Spacing.md) {
                ForEach(viewModel.presetAmounts) { preset in
                    amountCard(preset)
                }
            }
        }
        .padding(Spacing.lg)
    }

    private func amountCard(_ preset: PresetAmount) -> some View {
        let isSelected = viewModel.selectedPresetAmount == preset.value

        return Button(action: { viewModel.selectPresetAmount(preset.value) }) {
            Text("$\(NSDecimalNumber(decimal: preset.value).intValue)")
                .font(AppFont.tabletDisplay5Semibold)
                .foregroundColor(AppColors.textPrimary)
                .frame(maxWidth: .infinity)
                .frame(height: 100)
                .background(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: AppRadius.Tablet.md)
                        .stroke(
                            isSelected ? AppColors.primaryNormal : AppColors.line,
                            lineWidth: isSelected ? 2 : 1
                        )
                )
                .cornerRadius(AppRadius.Tablet.md)
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
        }
        .padding(.horizontal, Spacing.lg)
        .padding(.vertical, Spacing.md)
    }
}

// MARK: - Preview

#Preview {
    LimitedAuthGridView(viewModel: OrderCreationViewModel(orderType: .bar))
}
