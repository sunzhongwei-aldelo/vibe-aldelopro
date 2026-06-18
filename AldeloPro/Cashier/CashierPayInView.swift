import SwiftUI

struct CashierPayInView: View {
    @State private var amountText: String = "0.00"

    var body: some View {
        HStack(spacing: Spacing.md) {
            Spacer()
            // Left: Amount + Numpad + Pay In button
            numpadSection
            
            Spacer()
            // Right: Pay In Records
            recordsSection
        }
    }

    // MARK: - Numpad Section
    private var numpadSection: some View {
        VStack(spacing: Spacing.md) {
            // Amount field
            amountField

            // Numpad + Pay In button
            HStack(alignment: .top, spacing: Spacing.md) {
                NumpadWithAction(amountText: $amountText, actionTitle: "Pay In")
            }
        }
        .frame(maxWidth: 494, maxHeight: 494)
    }

    // MARK: - Amount Field
    private var amountField: some View {
        HStack {
            Text("Amount")
                .font(AppFont.tabletH3Medium)
                .foregroundColor(AppColors.textSecondary)
            Spacer()
            Text("$\(amountText)")
                .font(AppFont.tabletH1Medium)
                .foregroundColor(AppColors.textPrimary)
        }
        .padding(.horizontal, Spacing.md)
        .frame(height: 74)
        .background(
            RoundedRectangle(cornerRadius: AppRadius.Tablet.sm)
                .fill(AppColors.inputBg)
        )
    }

    // MARK: - Numpad Grid
    private var numpadGrid: some View {
        VStack(spacing: Spacing.md) {
            // Row 1: 1, 2, 3
            HStack(spacing: Spacing.md) {
                numpadButton("1")
                numpadButton("2")
                numpadButton("3")
            }
            // Row 2: 4, 5, 6
            HStack(spacing: Spacing.md) {
                numpadButton("4")
                numpadButton("5")
                numpadButton("6")
            }
            // Row 3: 7, 8, 9
            HStack(spacing: Spacing.md) {
                numpadButton("7")
                numpadButton("8")
                numpadButton("9")
            }
            // Row 4: 0, 00
            HStack(spacing: Spacing.md) {
                numpadButton("0")
                numpadButton("00", widthMultiplier: 2.15)
            }
        }
    }

    // MARK: - Numpad Button
    private func numpadButton(_ title: String, widthMultiplier: CGFloat = 1) -> some View {
        Button(action: { handleNumpadInput(title) }) {
            Text(title)
                .font(AppFont.tabletDisplay1Medium)
                .foregroundColor(AppColors.textPrimary)
                .frame(maxWidth: .infinity)
                .frame(height: 108)
                .background(
                    RoundedRectangle(cornerRadius: 15)
                        .fill(AppColors.white100)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(AppColors.line, lineWidth: 1.4)
                )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Right Column (Backspace, Clear, Pay In)
    private var payInButton: some View {
        VStack(spacing: Spacing.md) {
            // Backspace
            Button(action: { handleBackspace() }) {
                Image(systemName: "delete.left")
                    .font(.system(size: 28, weight: .medium))
                    .foregroundColor(AppColors.textPrimary)
                    .frame(maxWidth: .infinity)
                    .frame(height: 108)
                    .background(
                        RoundedRectangle(cornerRadius: 15)
                            .fill(AppColors.white100)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(AppColors.line, lineWidth: 1.4)
                    )
            }
            .buttonStyle(.plain)

            // Clear
            Button(action: { handleClear() }) {
                Text("Clear")
                    .font(AppFont.tabletButton1Semibold)
                    .foregroundColor(AppColors.textPrimary)
                    .frame(maxWidth: .infinity)
                    .frame(height: 108)
                    .background(
                        RoundedRectangle(cornerRadius: 15)
                            .fill(AppColors.white100)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(AppColors.line, lineWidth: 1.4)
                    )
            }
            .buttonStyle(.plain)

            // Pay In
            Button(action: { handlePayIn() }) {
                Text("Pay In")
                    .font(AppFont.tabletH1Medium)
                    .foregroundColor(AppColors.white100)
                    .frame(maxWidth: .infinity)
                    .frame(height: 234)
                    .background(
                        RoundedRectangle(cornerRadius: AppRadius.Tablet.lg)
                            .fill(AppColors.buttonPrimaryBg)
                    )
            }
            .buttonStyle(.plain)
        }
        .frame(width: 133)
    }

    // MARK: - Records Section
    private var recordsSection: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text("Pay In Records")
                .font(AppFont.tabletH3Medium)
                .foregroundColor(AppColors.textPrimary)

            // Sample record
            payInRecordRow(
                paidBy: "Zhang San",
                date: "2025-09-09  07:58 PM",
                amount: "+$10.00"
            )

            Spacer()
        }
        .padding(Spacing.md)
        .frame(maxWidth: 374)
        .background(
            RoundedRectangle(cornerRadius: AppRadius.Tablet.lg)
                .fill(AppColors.white100.opacity(0.5))
        )
    }

    // MARK: - Record Row
    private func payInRecordRow(paidBy: String, date: String, amount: String) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: Spacing.xs) {
                HStack(spacing: Spacing.xs) {
                    Text("Paid In By")
                        .font(AppFont.tabletH4Medium)
                        .foregroundColor(AppColors.textSecondary)
                    Text(paidBy)
                        .font(AppFont.tabletH4Medium)
                        .foregroundColor(AppColors.textPrimary)
                }
                Text(date)
                    .font(AppFont.tabletCaption1Regular)
                    .foregroundColor(AppColors.textSecondary)
            }
            Spacer()
            Text(amount)
                .font(AppFont.tabletH3Medium)
                .foregroundColor(AppColors.primaryNormal)
        }
        .padding(Spacing.md)
        .background(
            RoundedRectangle(cornerRadius: AppRadius.Tablet.sm)
                .fill(AppColors.white100)
        )
    }

    // MARK: - Actions
    private func handleNumpadInput(_ value: String) {
        if amountText == "0.00" {
            amountText = value
        } else {
            amountText += value
        }
    }

    private func handleBackspace() {
        if !amountText.isEmpty {
            amountText.removeLast()
        }
        if amountText.isEmpty {
            amountText = "0.00"
        }
    }

    private func handleClear() {
        amountText = "0.00"
    }

    private func handlePayIn() {
        // TODO: Implement pay in logic
    }
}

#Preview {
    CashierPayInView()
        .padding()
        .background(AppColors.pageBg)
}
