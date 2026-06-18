//
//  InlineReceiptMenuPopover.swift
//  AldeloPro
//
//  Created by Sen on 2026/06/09.
//

import SwiftUI

// MARK: - InlineReceiptMenuPopover

/// Floating popover menu with Email/Print/Text Receipt options (图367)
/// Anchored to the receipt icon, appears to its upper-left with shadow
struct InlineReceiptMenuPopover: View {

    let onEmail: () -> Void
    let onPrint: () -> Void
    let onText: () -> Void
    let onDismiss: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            menuItem(icon: "envelope", title: "Email Receipt", action: onEmail)
            Divider()
            menuItem(icon: "printer", title: "Print Receipt", action: onPrint)
            Divider()
            menuItem(icon: "iphone", title: "Text Receipt", action: onText)
        }
        .frame(width: 200)
        .background(
            RoundedRectangle(cornerRadius: AppRadius.Tablet.md)
                .fill(AppColors.card)
                .shadow(color: AppColors.black20, radius: 12, x: 0, y: 4)
        )
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.Tablet.md))
    }

    private func menuItem(icon: String, title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: Spacing.sm) {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(AppColors.textPrimary)
                    .frame(width: 24)
                Text(title)
                    .font(AppFont.tabletBody3Regular)
                    .foregroundColor(AppColors.textPrimary)
                Spacer()
            }
            .padding(.horizontal, Spacing.md)
            .padding(.vertical, Spacing.sm)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preview

#Preview("Receipt Popover") {
    ZStack {
        AppColors.pageBg.ignoresSafeArea()
        InlineReceiptMenuPopover(
            onEmail: {},
            onPrint: {},
            onText: {},
            onDismiss: {}
        )
    }
}

