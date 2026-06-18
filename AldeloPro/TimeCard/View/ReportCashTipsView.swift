//
//  ReportCashTipsView.swift
//  AldeloExpressPro
//
//  Created by jiangxia on 2026/06/08.
//

import SwiftUI

// MARK: - Cash Tip Field Mode

enum CashTipFieldMode {
    case required
    case optional
    case amount

    var labelText: String {
        switch self {
        case .required: return "Required"
        case .optional: return "Optional"
        case .amount: return "Amount"
        }
    }
}

// MARK: - View

struct ReportCashTipsView: View {
    // MARK: - Properties

    let mode: CashTipFieldMode
    let onDone: (Double) -> Void

    @State private var amountString: String = ""

    private let buttonHeight: CGFloat = 88

    private var displayAmount: String {
        guard !amountString.isEmpty else { return "$0.00" }
        let cents = Double(amountString) ?? 0
        let dollars = cents / 100.0
        return String(format: "$%.2f", dollars)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            titleSection
                .padding(.bottom, Spacing.md)
            amountField
                .padding(.bottom, Spacing.md)
            numpadGrid
        }
        .frame(maxWidth: 450, alignment: .leading)
    }

    // MARK: - Title

    private var titleSection: some View {
        Text("Report Cash Tips")
            .font(AppFont.tabletH1Medium)
            .foregroundColor(AppColors.textPrimary)
    }

    // MARK: - Amount Field

    private var amountField: some View {
        HStack {
            Text(mode.labelText)
                .font(AppFont.tabletBody2Regular)
                .foregroundColor(AppColors.textSecondary)
            Spacer()
            Text(displayAmount)
                .font(AppFont.tabletH1Medium)
                .foregroundColor(AppColors.textPrimary)
        }
        .padding(.horizontal, Spacing.sm)
        .frame(height: 74)
        .background(AppColors.inputBg)
        .cornerRadius(AppRadius.Tablet.sm)
    }

    // MARK: - Numpad Grid

    private var numpadGrid: some View {
        VStack(spacing: Spacing.sm) {
            numpadRow(keys: ["1", "2", "3", "backspace"])
            numpadRow(keys: ["4", "5", "6", "clear"])
            bottomSection
        }
    }

    private func numpadRow(keys: [String]) -> some View {
        HStack(spacing: Spacing.sm) {
            ForEach(keys, id: \.self) { key in
                numpadButton(key: key)
            }
        }
    }

    private var bottomSection: some View {
        GeometryReader { geo in
            let gap = Spacing.sm
            let colWidth = (geo.size.width - 3 * gap) / 4
            HStack(alignment: .top, spacing: gap) {
                VStack(spacing: gap) {
                    HStack(spacing: gap) {
                        numpadButton(key: "7").frame(width: colWidth)
                        numpadButton(key: "8").frame(width: colWidth)
                        numpadButton(key: "9").frame(width: colWidth)
                    }
                    HStack(spacing: gap) {
                        numpadButton(key: "0").frame(width: colWidth)
                        numpadButton(key: "00").frame(width: colWidth * 2 + gap)
                    }
                }
                doneButton
                    .frame(width: colWidth, height: buttonHeight * 2 + gap)
            }
        }
        .frame(height: buttonHeight * 2 + Spacing.sm)
    }

    // MARK: - Button Components

    private func numpadButton(key: String) -> some View {
        Button {
            handleKeyPress(key)
        } label: {
            numpadButtonLabel(key: key)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .contentShape(Rectangle())
        }
        .frame(maxWidth: .infinity)
        .frame(height: buttonHeight)
        .background(AppColors.card)
        .cornerRadius(AppRadius.Tablet.lg)
        .overlay(
            RoundedRectangle(cornerRadius: AppRadius.Tablet.lg)
                .stroke(AppColors.buttonStrokeLine, lineWidth: 1)
        )
    }

    @ViewBuilder
    private func numpadButtonLabel(key: String) -> some View {
        switch key {
        case "backspace":
            Image(systemName: "delete.backward")
                .font(.system(size: 28, weight: .regular))
                .foregroundColor(AppColors.textPrimary)
        case "clear":
            Text("Clear")
                .font(AppFont.tabletDisplay6Regular)
                .foregroundColor(AppColors.textPrimary)
        default:
            Text(key)
                .font(AppFont.tabletDisplay3Regular)
                .foregroundColor(AppColors.textPrimary)
        }
    }

    private var doneButton: some View {
        Button {
            let cents = Double(amountString) ?? 0
            onDone(cents / 100.0)
        } label: {
            Text("Done")
                .font(AppFont.tabletH1Medium)
                .foregroundColor(AppColors.buttonPrimaryText)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .contentShape(Rectangle())
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppColors.buttonPrimaryBg)
        .cornerRadius(AppRadius.Tablet.lg)
    }

    // MARK: - Key Handling

    private func handleKeyPress(_ key: String) {
        switch key {
        case "backspace":
            if !amountString.isEmpty {
                amountString.removeLast()
            }
        case "clear":
            amountString = ""
        case "00":
            if amountString.count < 7 {
                amountString += "00"
            }
        default:
            if amountString.count < 8 {
                amountString += key
            }
        }
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: Spacing.xl) {
//        ReportCashTipsView(mode: .required, onDone: { _ in })
//        ReportCashTipsView(mode: .optional, onDone: { _ in })
        ReportCashTipsView(mode: .amount, onDone: { _ in })
    }
    .padding(Spacing.xl)
    .background(AppColors.pageBg)
}
