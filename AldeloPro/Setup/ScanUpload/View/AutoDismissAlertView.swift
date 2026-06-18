//
//  AutoDismissAlertView.swift
//  AldeloPro
//
//  Created by wanghui on 2026/06/09.
//

import SwiftUI

struct AutoDismissAlertView: View {

    // MARK: - Properties

    let title: String
    let message: AttributedString
    var autoDismissSeconds: Double = 3.0
    var onDismiss: () -> Void

    // MARK: - State

    @State private var isVisible = true

    // MARK: - Body

    var body: some View {
        if isVisible {
            VStack(spacing: Spacing.md) {
                // Close button
                HStack {
                    Spacer()
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(AppColors.textPrimary)
                            .frame(width: 24, height: 24)
                    }
                    .buttonStyle(.plain)
                }
                .padding(.top, Spacing.xs)
                .padding(.trailing, Spacing.xs)

                // Icon
                Circle()
                    .fill(AppColors.errorNormal)
                    .frame(width: 50, height: 50)
                    .overlay(
                        VStack(spacing: 4) {
                            RoundedRectangle(cornerRadius: 2)
                                .fill(Color.white)
                                .frame(width: 5, height: 20)
                            Circle()
                                .fill(Color.white)
                                .frame(width: 6, height: 6)
                        }
                    )

                // Title
                Text(title)
                    .font(AppFont.tabletH1Medium)
                    .foregroundColor(AppColors.textPrimary)

                // Message
                Text(message)
                    .font(AppFont.tabletH2Medium)
                    .foregroundColor(AppColors.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, Spacing.md)
                    .padding(.bottom, Spacing.lg)
            }
            .frame(width: 500)
            .background(AppColors.card)
            .cornerRadius(AppRadius.Tablet.md)
            .task {
                try? await Task.sleep(nanoseconds: UInt64(autoDismissSeconds * 1_000_000_000))
                dismiss()
            }
        }
    }

    // MARK: - Private

    private func dismiss() {
        isVisible = false
        onDismiss()
    }
}

#Preview {
    AutoDismissAlertView(title: "Test", message: .init(stringLiteral: "Test AutoDismissAlertModifier"), onDismiss: {
        
    })
}

struct AutoDismissAlertModifier: ViewModifier {

    @Binding var isPresented: Bool
    let title: String
    let message: AttributedString
    var autoDismissSeconds: Double = 3.0

    func body(content: Content) -> some View {
        content
            .overlay {
                if isPresented {
                    ZStack {
                        Color.black.opacity(0.4).ignoresSafeArea()

                        AutoDismissAlertView(
                            title: title,
                            message: message,
                            autoDismissSeconds: autoDismissSeconds,
                            onDismiss: {
                                isPresented = false
                            }
                        )
                        .padding(.horizontal, Spacing.md)
                    }
                }
            }
    }
}

// MARK: - View Extension

extension View {
    func autoDismissAlert(
        isPresented: Binding<Bool>,
        title: String,
        message: AttributedString,
        autoDismissSeconds: Double = 3.0
    ) -> some View {
        modifier(AutoDismissAlertModifier(
            isPresented: isPresented,
            title: title,
            message: message,
            autoDismissSeconds: autoDismissSeconds
        ))
    }
}
