import SwiftUI

struct HeaderActionButtons: View {
    let onBack: () -> Void
    let onConfirm: () -> Void

    var body: some View {
        HStack(spacing: Spacing.xs) {
            Button("Back", action: onBack)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(AppColors.textPrimary)
                .frame(width: 120, height: 40)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(AppColors.line, lineWidth: 1)
                )

            Button("Confirm", action: onConfirm)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(.white)
                .frame(width: 120, height: 40)
                .background(AppColors.primaryNormal)
                .clipShape(RoundedRectangle(cornerRadius: 8))
        }
    }
}
