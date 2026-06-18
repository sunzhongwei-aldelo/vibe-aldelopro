//
//  RefundEmailReceiptInputView.swift
//  AldeloPro
//
//  Created by Sen on 2026/06/09.
//

import SwiftUI

// MARK: - RefundEmailReceiptInputView

/// Full-screen Email Receipt page (图379, 381)
/// Features: email keyboard, regex validation, red border on invalid, fixed-height error slot
struct RefundEmailReceiptInputView: View {

    // MARK: - Parameters

    let onSend: (String) -> Void
    let onGoBack: () -> Void

    // MARK: - State

    @State private var email: String = ""
    @State private var showError: Bool = false
    @FocusState private var isFieldFocused: Bool

    @Environment(\.horizontalSizeClass) private var hSizeClass
    private var isCompact: Bool { hSizeClass == .compact }

    // MARK: - Body

    var body: some View {
        VStack(spacing: 0) {
            headerBar
            Divider().foregroundColor(AppColors.theme)

            formSection

            Spacer()
        }
        .background(AppColors.pageBg)
        .onAppear { isFieldFocused = true }
    }

    // MARK: - Header

    private var headerBar: some View {
        HStack(spacing: Spacing.sm) {
            Image(systemName: "envelope")
                .font(.system(size: 24, weight: .medium))
                .foregroundColor(AppColors.textPrimary)
            Text("Email Receipt")
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

            Text("Email Address")
                .font(AppFont.tabletCaption1Regular)
                .foregroundColor(AppColors.textSecondary)

            emailInputField

            // Fixed-height error slot (prevents layout shift)
            errorSlot

            buttonRow
        }
        .padding(.horizontal, isCompact ? Spacing.lg : Spacing.xl * 2)
        .padding(.top, Spacing.lg)
    }

    private var emailInputField: some View {
        TextField("", text: $email)
            .font(isCompact ? AppFont.mobileBody1Regular : AppFont.tabletBody2Regular)
            .foregroundColor(AppColors.textPrimary)
            .keyboardType(.emailAddress)
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled()
            .focused($isFieldFocused)
            .padding(.horizontal, Spacing.md)
            .frame(height: isCompact ? 48 : 56)
            .background(AppColors.inputBg)
            .clipShape(RoundedRectangle(cornerRadius: AppRadius.Tablet.sm))
            .overlay(
                RoundedRectangle(cornerRadius: AppRadius.Tablet.sm)
                    .stroke(
                        showError ? AppColors.errorNormal : (isFieldFocused ? AppColors.theme : AppColors.line),
                        lineWidth: showError ? 1.5 : 1
                    )
            )
            .onChange(of: email) { _, _ in
                if showError { showError = false }
            }
    }

    private var errorSlot: some View {
        Text(showError ? "Invalid Email Address" : " ")
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

    // MARK: - Validation

    private func handleSend() {
        if isValidEmail(email) {
            onSend(email)
        } else {
            showError = true
        }
    }

    private func isValidEmail(_ text: String) -> Bool {
        let pattern = #"^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$"#
        return text.range(of: pattern, options: .regularExpression) != nil
    }
}

// MARK: - Preview

#Preview("Empty") {
    RefundEmailReceiptInputView(onSend: { _ in }, onGoBack: {})
}

