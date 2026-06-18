//
//  RefundTextReceiptInputView.swift
//  AldeloPro
//
//  Created by Sen on 2026/06/09.
//

import SwiftUI

// MARK: - RefundTextReceiptInputView

/// Full-screen Text Receipt page with phone number input + T9 keyboard (图360-362)
/// Features: live (XXX) XXX-XXXX masking, red border on invalid, anti-layout-shift error slot
struct RefundTextReceiptInputView: View {

    // MARK: - Parameters

    let onSend: (String) -> Void
    let onGoBack: () -> Void

    // MARK: - State

    @State private var rawDigits: String = ""
    @State private var showError: Bool = false

    @Environment(\.horizontalSizeClass) private var hSizeClass
    private var isCompact: Bool { hSizeClass == .compact }

    // MARK: - Computed

    private var formattedPhone: String {
        formatPhoneNumber(rawDigits)
    }

    private var isValid: Bool {
        rawDigits.count == 10
    }

    // MARK: - Body

    var body: some View {
        VStack(spacing: 0) {
            headerBar
            Divider().foregroundColor(AppColors.theme)

            formSection

            Spacer()

            telephoneKeypad
        }
        .background(AppColors.pageBg)
    }

    // MARK: - Header

    private var headerBar: some View {
        HStack(spacing: Spacing.sm) {
            Image(systemName: "iphone")
                .font(.system(size: 24, weight: .medium))
                .foregroundColor(AppColors.textPrimary)
            Text("Text Receipt")
                .font(isCompact ? AppFont.mobileH1Medium : AppFont.tabletH1Medium)
                .foregroundColor(AppColors.textPrimary)
            Spacer()
        }
        .padding(.horizontal, Spacing.lg)
        .padding(.vertical, Spacing.md)
    }

    // MARK: - Form Section

    private var formSection: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text("Customer Info")
                .font(isCompact ? AppFont.mobileH3Medium : AppFont.tabletH3Medium)
                .foregroundColor(AppColors.textPrimary)

            Text("Phone Number")
                .font(AppFont.tabletCaption1Regular)
                .foregroundColor(AppColors.textSecondary)

            // Phone input field
            phoneInputField

            // Error slot (fixed height to prevent layout shift)
            errorSlot

            // Buttons: Go Back + Send
            buttonRow
        }
        .padding(.horizontal, isCompact ? Spacing.lg : Spacing.xl * 2)
        .padding(.top, Spacing.lg)
    }

    private var phoneInputField: some View {
        Text(formattedPhone.isEmpty ? " " : formattedPhone)
            .font(isCompact ? AppFont.mobileBody1Regular : AppFont.tabletBody2Regular)
            .foregroundColor(formattedPhone.isEmpty ? AppColors.inputPlaceholder : AppColors.textPrimary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, Spacing.md)
            .frame(height: isCompact ? 48 : 56)
            .background(AppColors.inputBg)
            .clipShape(RoundedRectangle(cornerRadius: AppRadius.Tablet.sm))
            .overlay(
                RoundedRectangle(cornerRadius: AppRadius.Tablet.sm)
                    .stroke(showError ? AppColors.errorNormal : AppColors.theme, lineWidth: showError ? 1.5 : 1)
            )
    }

    private var errorSlot: some View {
        Text(showError ? "Invalid Phone Number" : " ")
            .font(AppFont.tabletCaption2Regular)
            .foregroundColor(AppColors.errorNormal)
            .frame(height: 18)
    }

    private var buttonRow: some View {
        HStack(spacing: Spacing.md) {
            Button(action: onGoBack) {
                Text("Go Back")
                    .font(isCompact ? AppFont.mobileButton2Medium : AppFont.tabletH4Medium)
                    .foregroundColor(AppColors.textPrimary)
                    .frame(maxWidth: .infinity)
                    .frame(height: isCompact ? 48 : 54)
                    .background(AppColors.card)
                    .clipShape(RoundedRectangle(cornerRadius: AppRadius.Tablet.md))
                    .overlay(
                        RoundedRectangle(cornerRadius: AppRadius.Tablet.md)
                            .stroke(AppColors.line, lineWidth: 0.5)
                    )
            }
            .buttonStyle(.plain)

            Button(action: handleSend) {
                Text("Send")
                    .font(isCompact ? AppFont.mobileButton2Medium : AppFont.tabletH4Medium)
                    .foregroundColor(AppColors.buttonPrimaryText)
                    .frame(maxWidth: .infinity)
                    .frame(height: isCompact ? 48 : 54)
                    .background(AppColors.buttonPrimaryBg)
                    .clipShape(RoundedRectangle(cornerRadius: AppRadius.Tablet.md))
            }
            .buttonStyle(.plain)
        }
    }

    // MARK: - T9 Telephone Keypad

    private var telephoneKeypad: some View {
        let keys: [(String, String)] = [
            ("1", ""), ("2", "ABC"), ("3", "DEF"),
            ("4", "GHI"), ("5", "JKL"), ("6", "MNO"),
            ("7", "PQRS"), ("8", "TUV"), ("9", "WXYZ")
        ]
        let buttonH: CGFloat = isCompact ? 52 : 64
        let spacing: CGFloat = isCompact ? Spacing.xs : Spacing.sm

        return VStack(spacing: spacing) {
            // Rows 1-3 (1-9)
            ForEach(0..<3, id: \.self) { row in
                HStack(spacing: spacing) {
                    ForEach(0..<3, id: \.self) { col in
                        let idx = row * 3 + col
                        t9Key(digit: keys[idx].0, letters: keys[idx].1, height: buttonH)
                    }
                }
            }
            // Row 4: empty, 0, delete
            HStack(spacing: spacing) {
                Color.clear.frame(height: buttonH)
                t9Key(digit: "0", letters: "", height: buttonH)
                deleteKey(height: buttonH)
            }
        }
        .padding(.horizontal, isCompact ? Spacing.lg : Spacing.xl * 2)
        .padding(.bottom, Spacing.lg)
    }

    private func t9Key(digit: String, letters: String, height: CGFloat) -> some View {
        Button { appendDigit(digit) } label: {
            VStack(spacing: 2) {
                Text(digit)
                    .font(.system(size: isCompact ? 24 : 30, weight: .regular))
                    .foregroundColor(AppColors.textPrimary)
                if !letters.isEmpty {
                    Text(letters)
                        .font(.system(size: isCompact ? 9 : 11, weight: .medium))
                        .foregroundColor(AppColors.textSecondary)
                        .tracking(2)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: height)
            .background(AppColors.card)
            .clipShape(RoundedRectangle(cornerRadius: AppRadius.Tablet.sm))
        }
        .buttonStyle(.plain)
    }

    private func deleteKey(height: CGFloat) -> some View {
        Button { deleteLastDigit() } label: {
            Image(systemName: "delete.backward")
                .font(.system(size: isCompact ? 18 : 22, weight: .medium))
                .foregroundColor(AppColors.textPrimary)
                .frame(maxWidth: .infinity)
                .frame(height: height)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Logic

    private func appendDigit(_ digit: String) {
        guard rawDigits.count < 10 else { return }
        rawDigits += digit
        showError = false
    }

    private func deleteLastDigit() {
        guard !rawDigits.isEmpty else { return }
        rawDigits.removeLast()
        showError = false
    }

    private func handleSend() {
        if isValid {
            onSend(formattedPhone)
        } else {
            showError = true
        }
    }

    private func formatPhoneNumber(_ digits: String) -> String {
        let d = digits
        switch d.count {
        case 0: return ""
        case 1...3: return "(\(d))"
        case 4...6:
            let area = String(d.prefix(3))
            let mid = String(d.dropFirst(3))
            return "(\(area)) \(mid)"
        case 7...10:
            let area = String(d.prefix(3))
            let mid = String(d.dropFirst(3).prefix(3))
            let last = String(d.dropFirst(6))
            return "(\(area)) \(mid)-\(last)"
        default: return d
        }
    }
}

// MARK: - Preview

#Preview("Empty") {
    RefundTextReceiptInputView(onSend: { _ in }, onGoBack: {})
}

#Preview("Filled") {
    let view = RefundTextReceiptInputView(onSend: { _ in }, onGoBack: {})
    return view
}

