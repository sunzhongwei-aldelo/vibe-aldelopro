//
//  RefundMethodSelector.swift
//  AldeloPro
//
//  Created by Sen on 2026/06/09.
//

import SwiftUI

// MARK: - RefundMethodSelector

/// Right-side Step 3 (Custom Refund only): Five refund method cards + Go Back button
/// Layout per design 图374: vertical list of white rounded cards with icon + title, centered
struct RefundMethodSelector: View {

    // MARK: - Parameters

    let onSelectMethod: (CustomRefundMethod) -> Void
    let onGoBack: () -> Void

    @Environment(\.horizontalSizeClass) private var hSizeClass

    private var isCompact: Bool { hSizeClass == .compact }

    // MARK: - Body

    var body: some View {
        VStack(spacing: isCompact ? Spacing.sm : Spacing.md) {
            sectionTitle

            ForEach(CustomRefundMethod.allCases) { method in
                methodCard(method)
            }

            Spacer()

            goBackButton
        }
    }

    // MARK: - Section Title

    private var sectionTitle: some View {
        HStack {
            Text("Refund Method")
                .font(isCompact ? AppFont.mobileH3Medium : AppFont.tabletBody3Regular)
                .foregroundColor(AppColors.textSecondary)
            Spacer()
        }
    }

    // MARK: - Method Card

    private func methodCard(_ method: CustomRefundMethod) -> some View {
        Button { onSelectMethod(method) } label: {
            HStack(spacing: Spacing.md) {
                Image(systemName: method.iconName)
                    .font(.system(size: isCompact ? 20 : 24, weight: .regular))
                    .foregroundColor(AppColors.textPrimary)
                    .frame(width: 32)
                Text(method.title)
                    .font(isCompact ? AppFont.mobileBody1Regular : AppFont.tabletBody1Regular)
                    .foregroundColor(AppColors.textPrimary)
                Spacer()
            }
            .padding(.horizontal, Spacing.lg)
            .frame(height: isCompact ? 56 : 64)
            .background(AppColors.card)
            .clipShape(RoundedRectangle(cornerRadius: AppRadius.Tablet.md))
        }
        .buttonStyle(.plain)
    }

    // MARK: - Go Back Button

    private var goBackButton: some View {
        Button(action: onGoBack) {
            Text("Go Back")
                .font(isCompact ? AppFont.mobileBody1Regular : AppFont.tabletBody1Regular)
                .foregroundColor(AppColors.textPrimary)
                .frame(maxWidth: .infinity)
                .frame(height: isCompact ? 52 : 60)
                .background(AppColors.card)
                .clipShape(RoundedRectangle(cornerRadius: AppRadius.Tablet.md))
                .overlay(
                    RoundedRectangle(cornerRadius: AppRadius.Tablet.md)
                        .stroke(AppColors.line, lineWidth: 0.5)
                )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preview

#Preview("Method Selector") {
    RefundMethodSelector(
        onSelectMethod: { _ in },
        onGoBack: {}
    )
    .padding()
    .background(AppColors.pageBg)
}

