//
//  RefundStatusWorkspace.swift
//  AldeloPro
//
//  Created by Sen on 2026/06/09.
//

import SwiftUI

// MARK: - RefundStatusWorkspace

/// Right-side panel for idle/fullyRefunded/newRefund states
/// Shows centered illustration + status text + optional action button
struct RefundStatusWorkspace: View {

    enum StatusMode {
        /// Default idle state - "Select a Payment to Refund" (图352)
        case idle
        /// Payment fully refunded with checkmark badge (图368)
        case fullyRefunded(message: String)
        /// Partial refund done, can start new (图385)
        case newRefundAvailable(onNewRefund: () -> Void)
    }

    let mode: StatusMode

    @Environment(\.horizontalSizeClass) private var hSizeClass
    private var isCompact: Bool { hSizeClass == .compact }

    // MARK: - Body

    var body: some View {
        VStack(spacing: Spacing.lg) {
            Spacer()
            illustrationView
            statusText
            actionButton
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Illustration

    private var illustrationView: some View {
        ZStack(alignment: .bottomTrailing) {
            // Main document/receipt illustration
            Image(systemName: "doc.text.magnifyingglass")
                .font(.system(size: isCompact ? 60 : 80, weight: .thin))
                .foregroundColor(AppColors.theme.opacity(0.4))

            // Badge overlay
            badgeOverlay
        }
    }

    @ViewBuilder
    private var badgeOverlay: some View {
        switch mode {
        case .idle:
            EmptyView()
        case .fullyRefunded:
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: isCompact ? 20 : 28))
                .foregroundColor(AppColors.theme)
                .offset(x: 8, y: 4)
        case .newRefundAvailable:
            Image(systemName: "plus.circle.fill")
                .font(.system(size: isCompact ? 20 : 28))
                .foregroundColor(AppColors.theme)
                .offset(x: 8, y: 4)
        }
    }

    // MARK: - Status Text

    private var statusText: some View {
        Text(statusMessage)
            .font(isCompact ? AppFont.mobileBody1Regular : AppFont.tabletBody2Regular)
            .foregroundColor(AppColors.textSecondary)
            .multilineTextAlignment(.center)
    }

    private var statusMessage: String {
        switch mode {
        case .idle:
            return "Select a Payment to Refund"
        case .fullyRefunded(let message):
            return message
        case .newRefundAvailable:
            return "Start a New Refund"
        }
    }

    // MARK: - Action Button

    @ViewBuilder
    private var actionButton: some View {
        switch mode {
        case .newRefundAvailable(let onNewRefund):
            Button(action: onNewRefund) {
                Text("New Refund")
                    .font(isCompact ? AppFont.mobileButton2Medium : AppFont.tabletH4Medium)
                    .foregroundColor(AppColors.buttonPrimaryText)
                    .padding(.horizontal, Spacing.xxxl)
                    .frame(height: isCompact ? 48 : 54)
                    .background(
                        Capsule().fill(AppColors.buttonPrimaryBg)
                    )
            }
            .buttonStyle(.plain)
        default:
            EmptyView()
        }
    }
}

// MARK: - Preview

#Preview("Idle") {
    RefundStatusWorkspace(mode: .idle)
        .background(AppColors.pageBg)
}

#Preview("Fully Refunded") {
    RefundStatusWorkspace(mode: .fullyRefunded(message: "Selected Payment Fully Refunded"))
        .background(AppColors.pageBg)
}

#Preview("New Refund Available") {
    RefundStatusWorkspace(mode: .newRefundAvailable(onNewRefund: {}))
        .background(AppColors.pageBg)
}

