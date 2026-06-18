//
//  DecimalNumpadView.swift
//  AldeloPro
//
//  Created by jiangxia on 2026/06/05.
//

import SwiftUI

// MARK: - Half Numpad View，点击0.5
struct HalfNumpadView: View {
    @Binding var value: Double
    var buttonTitle: String = "Update"
    var onCommit: () -> Void = {}

    @State private var inputBuffer: String = ""
    @State private var isEditing: Bool = false

    private let gridColumns = [
        GridItem(.flexible(), spacing: Spacing.sm),
        GridItem(.flexible(), spacing: Spacing.sm),
        GridItem(.flexible(), spacing: Spacing.sm)
    ]

    var body: some View {
        VStack(spacing: Spacing.md) {
            numberGrid
            updateButton
        }
        .padding(.horizontal, Spacing.lg)
        .padding(.vertical, 20)
        .frame(width: 342)
        .background(
            RoundedRectangle(cornerRadius: AppRadius.Tablet.lg)
                .fill(AppColors.numpadPanelBg.opacity(0.5))
                .overlay(
                    RoundedRectangle(cornerRadius: AppRadius.Tablet.lg)
                        .stroke(AppColors.line, lineWidth: 1)
                )
        )
    }

    // MARK: - Number Grid

    private var numberGrid: some View {
        LazyVGrid(columns: gridColumns, spacing: Spacing.sm) {
            ForEach(1...9, id: \.self) { number in
                numberButton("\(number)") { appendDigit("\(number)") }
            }
            backspaceButton
            numberButton("0") { appendDigit("0") }
            numberButton("0.5") { appendHalf() }
        }
    }

    // MARK: - Update Button

    private var updateButton: some View {
        Button(action: {
            commitInput()
            onCommit()
        }) {
            Text(buttonTitle)
                .font(AppFont.tabletButton4Medium)
                .foregroundColor(AppColors.buttonPrimaryText)
                .frame(maxWidth: .infinity)
                .frame(height: 55)
                .background(
                    RoundedRectangle(cornerRadius: AppRadius.Tablet.lg)
                        .fill(AppColors.buttonPrimaryBg)
                )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Button Components

    private func numberButton(_ label: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(label)
                .font(AppFont.tabletH1Medium)
                .foregroundColor(AppColors.textEmphasis)
                .frame(maxWidth: .infinity)
                .frame(height: 72)
                .background(
                    RoundedRectangle(cornerRadius: AppRadius.Tablet.lg)
                        .fill(AppColors.buttonStrokeBg)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: AppRadius.Tablet.lg)
                        .stroke(AppColors.buttonStrokeLine, lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
    }

    private var backspaceButton: some View {
        Button(action: deleteLastCharacter) {
            Image(systemName: "delete.backward")
                .font(.system(size: 22, weight: .medium))
                .foregroundColor(AppColors.textEmphasis)
                .frame(maxWidth: .infinity)
                .frame(height: 72)
                .background(
                    RoundedRectangle(cornerRadius: AppRadius.Tablet.lg)
                        .fill(AppColors.buttonStrokeBg)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: AppRadius.Tablet.lg)
                        .stroke(AppColors.buttonStrokeLine, lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Logic

    private var displayValue: String {
        isEditing ? inputBuffer : formatValue(value)
    }

    private func formatValue(_ val: Double) -> String {
        val.truncatingRemainder(dividingBy: 1) == 0
            ? String(format: "%.0f", val)
            : String(val)
    }

    private func appendDigit(_ digit: String) {
        if !isEditing {
            inputBuffer = ""
            isEditing = true
        }
        let newBuffer = inputBuffer + digit
        if isValidDecimal(newBuffer) {
            inputBuffer = newBuffer
            value = Double(newBuffer) ?? value
        }
    }

    private func appendHalf() {
        inputBuffer = "0.5"
        isEditing = true
        value = 0.5
    }

    private func deleteLastCharacter() {
        if isEditing && !inputBuffer.isEmpty {
            inputBuffer = String(inputBuffer.dropLast())
            if inputBuffer.isEmpty || inputBuffer == "." {
                inputBuffer = ""
                value = 0
                isEditing = false
            } else {
                value = Double(inputBuffer) ?? 0
            }
        } else {
            value = 0
            isEditing = false
        }
    }

    private func commitInput() {
        if isEditing {
            value = Double(inputBuffer) ?? value
            isEditing = false
        }
    }

    private func isValidDecimal(_ str: String) -> Bool {
        let parts = str.split(separator: ".", omittingEmptySubsequences: false)
        if parts.count > 2 { return false }
        let integerPart = String(parts[0])
        if integerPart.count > 5 { return false }
        if parts.count == 2 {
            let decimalPart = String(parts[1])
            if decimalPart.count > 2 { return false }
        }
        return true
    }
}

// MARK: - Preview

#Preview("Half Numpad") {
    ZStack {
        AppColors.pageBg
            .ignoresSafeArea()

        HalfNumpadView(
            value: .constant(0),
            onCommit: { print("Update") }
        )
    }
}
