//
//  RefundAmountPinPad.swift
//  AldeloPro
//
//  Created by Sen on 2026/06/09.
//

import SwiftUI

// MARK: - RefundAmountPinPad

/// Right-side Step 2: Amount display + numpad grid with vertical "Refund" action button
/// The Refund button spans the FULL height of all 4 keypad rows (per design spec)
struct RefundAmountPinPad: View {

    // MARK: - Parameters

    let formattedAmount: String
    let formattedMaxRefundable: String
    let canSubmit: Bool
    var showAmountCard: Bool = false
    let onDigit: (Int) -> Void
    let onDoubleZero: () -> Void
    let onDelete: () -> Void
    let onClear: () -> Void
    let onRefund: () -> Void

    @Environment(\.horizontalSizeClass) private var hSizeClass

    private var isCompact: Bool { hSizeClass == .compact }
    private var buttonHeight: CGFloat { isCompact ? 52 : 86}
    private var gridSpacing: CGFloat { isCompact ? Spacing.xs : Spacing.sm }

    // MARK: - Body

    var body: some View {
        VStack(spacing: isCompact ? Spacing.sm : Spacing.md) {
            if showAmountCard {
                amountDisplayCard
                maxRefundableLabel
            }
            keypadWithRefundButton
        }
    }

    // MARK: - Amount Display Card

    private var amountDisplayCard: some View {
        HStack {
            Text("Refund")
                .font(isCompact ? AppFont.mobileBody1Regular : AppFont.tabletBody2Regular)
                .foregroundColor(AppColors.textSecondary)
            Spacer()
            Text(formattedAmount)
                .font(isCompact ? AppFont.mobileH1Medium : AppFont.tabletH1Medium)
                .foregroundColor(AppColors.textPrimary)
        }
        .padding(.horizontal, Spacing.md)
        .frame(height: isCompact ? 52 : 60)
        .background(AppColors.card)
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.Tablet.sm))
        .overlay(
            RoundedRectangle(cornerRadius: AppRadius.Tablet.sm)
                .stroke(AppColors.line, lineWidth: 0.5)
        )
    }

    // MARK: - Max Refundable Label

    private var maxRefundableLabel: some View {
        HStack {
            Spacer()
            Text("Max Refundable: \(formattedMaxRefundable)")
                .font(isCompact ? AppFont.mobileBody2Regular : AppFont.tabletBody4Regular)
                .foregroundColor(AppColors.textSecondary)
        }
    }

    // MARK: - Keypad + Refund Button (side by side)

    private var keypadWithRefundButton: some View {
        GeometryReader { geometry in
            let w = geometry.size.width
            let spacing = gridSpacing
            let colW = (w - spacing * 3) / 4

            HStack(alignment: .top, spacing: spacing) {
                // Left: 3-column numpad grid (4 rows)
                numpadGrid
                // Right: vertical Refund button spanning all 4 rows
                VStack(spacing: spacing) {
                    // C (clear) button at top
                    Button(action: onClear) {
                        Text("C")
                            .font(isCompact ? AppFont.mobileH3Medium : AppFont.tabletH2Medium)
                            .foregroundColor(AppColors.textPrimary)
                            .frame(maxWidth: .infinity)
                            .frame(height: buttonHeight)
                            .background(AppColors.card)
                            .clipShape(RoundedRectangle(cornerRadius: AppRadius.Tablet.md))
                            .overlay(
                                RoundedRectangle(cornerRadius: AppRadius.Tablet.md)
                                    .stroke(AppColors.line.opacity(0.5), lineWidth: 0.5)
                            )
                            .shadow(color: Color.black.opacity(0.02), radius: 2, y: 1)
                    }
                    .buttonStyle(.plain)

                    // Backspace button
                    Button(action: onDelete) {
                        Image(systemName: "delete.backward")
                            .font(.system(size: isCompact ? 20 : 24))
                            .foregroundColor(AppColors.textPrimary)
                            .frame(maxWidth: .infinity)
                            .frame(height: buttonHeight)
                            .background(AppColors.card)
                            .clipShape(RoundedRectangle(cornerRadius: AppRadius.Tablet.md))
                            .overlay(
                                RoundedRectangle(cornerRadius: AppRadius.Tablet.md)
                                    .stroke(AppColors.line.opacity(0.5), lineWidth: 0.5)
                            )
                            .shadow(color: Color.black.opacity(0.02), radius: 2, y: 1)
                    }
                    .buttonStyle(.plain)

                    // Blue Refund button spanning remaining 2 rows
                    Button(action: onRefund) {
                        Text("Refund")
                            .font(isCompact ? AppFont.mobileH3Medium : AppFont.tabletH3Medium)
                            .foregroundColor(AppColors.buttonPrimaryText)
                            .frame(maxWidth: .infinity)
                            .frame(height: buttonHeight * 2 + spacing)
                            .background(
                                RoundedRectangle(cornerRadius: AppRadius.Tablet.md)
                                    .fill(canSubmit ? AppColors.theme : AppColors.theme.opacity(0.35))
                            )
                            .shadow(color: AppColors.theme.opacity(0.15), radius: 4, y: 2)
                    }
                    .buttonStyle(.plain)
                    .disabled(!canSubmit)
                }
                .frame(width: colW)
            }
        }
        .frame(height: buttonHeight * 4 + gridSpacing * 3)
    }

    // MARK: - 3-Column Numpad Grid (4 rows)

    private var numpadGrid: some View {
        Grid(horizontalSpacing: gridSpacing, verticalSpacing: gridSpacing) {
            GridRow {
                digitButton(1)
                digitButton(2)
                digitButton(3)
            }
            GridRow {
                digitButton(4)
                digitButton(5)
                digitButton(6)
            }
            GridRow {
                digitButton(7)
                digitButton(8)
                digitButton(9)
            }
            GridRow {
                digitButton(0)
                doubleZeroButtonWide
                    .gridCellColumns(2)
            }
        }
    }

    // MARK: - Button Builders

    private func digitButton(_ digit: Int) -> some View {
        Button { onDigit(digit) } label: {
            Text("\(digit)")
                .font(isCompact ? AppFont.mobileH2Medium : AppFont.tabletDisplay6Medium)
                .foregroundColor(AppColors.textPrimary)
                .frame(maxWidth: .infinity)
                .frame(height: buttonHeight)
                .background(AppColors.card)
                .clipShape(RoundedRectangle(cornerRadius: AppRadius.Tablet.md))
                .overlay(
                    RoundedRectangle(cornerRadius: AppRadius.Tablet.md)
                        .stroke(AppColors.line.opacity(0.5), lineWidth: 0.5)
                )
                .shadow(color: Color.black.opacity(0.02), radius: 2, y: 1)
        }
        .buttonStyle(.plain)
    }

    private var doubleZeroButton: some View {
        Button(action: onDoubleZero) {
            Text("00")
                .font(isCompact ? AppFont.mobileH2Medium : AppFont.tabletH2Medium)
                .foregroundColor(AppColors.textPrimary)
                .frame(maxWidth: .infinity)
                .frame(height: buttonHeight)
                .background(AppColors.card)
                .clipShape(RoundedRectangle(cornerRadius: AppRadius.Tablet.md))
                .overlay(
                    RoundedRectangle(cornerRadius: AppRadius.Tablet.md)
                        .stroke(AppColors.line.opacity(0.5), lineWidth: 0.5)
                )
                .shadow(color: Color.black.opacity(0.02), radius: 2, y: 1)
        }
        .buttonStyle(.plain)
    }

    /// Wide 00 button spanning 2 grid columns
    private var doubleZeroButtonWide: some View {
        Button(action: onDoubleZero) {
            Text("00")
                .font(isCompact ? AppFont.mobileH2Medium : AppFont.tabletH2Medium)
                .foregroundColor(AppColors.textPrimary)
                .frame(maxWidth: .infinity)
                .frame(height: buttonHeight)
                .background(AppColors.card)
                .clipShape(RoundedRectangle(cornerRadius: AppRadius.Tablet.md))
                .overlay(
                    RoundedRectangle(cornerRadius: AppRadius.Tablet.md)
                        .stroke(AppColors.line.opacity(0.5), lineWidth: 0.5)
                )
                .shadow(color: Color.black.opacity(0.02), radius: 2, y: 1)
        }
        .buttonStyle(.plain)
    }
}
