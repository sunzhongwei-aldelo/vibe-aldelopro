import SwiftUI

struct AuthApprovedView: View {
    let amount: Decimal?
    let onDone: () -> Void

    @State private var countdown: Int = 10
    @State private var timer: Timer?

    var body: some View {
        ZStack {
            // Background
            Color(hex: "#EBEEF5")
                .ignoresSafeArea()

            VStack(spacing: Spacing.lg) {
                Spacer()

                // Approved Title
                Text("Approved")
                    .font(AppFont.tabletH1Medium)
                    .foregroundColor(AppColors.textSecondary)

                // Amount (if present)
                if let amount = amount {
                    Text("$\(NSDecimalNumber(decimal: amount).stringValue).00")
                        .font(AppFont.tabletDisplay3Semibold)
                        .foregroundColor(AppColors.textPrimary)
                }

                // Success Checkmark
                ZStack {
                    Circle()
                        .fill(AppColors.successNormal)
                        .frame(width: 64, height: 64)

                    Image(systemName: "checkmark")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.white)
                }
                .padding(.top, Spacing.lg)

                // Success Text
                Text("Success")
                    .font(AppFont.tabletDisplay5Semibold)
                    .foregroundColor(AppColors.textPrimary)

                Spacer()

                // Done Button
                Button(action: {
                    stopTimer()
                    onDone()
                }) {
                    Text("Done")
                        .font(AppFont.tabletButton3Medium)
                        .foregroundColor(.white)
                        .frame(width: 200, height: 48)
                        .background(AppColors.buttonPrimaryBg)
                        .cornerRadius(AppRadius.Tablet.lg)
                }
                .padding(.bottom, Spacing.xxl)
            }

            // Countdown Badge
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    countdownBadge
                        .padding(.trailing, Spacing.lg)
                        .padding(.bottom, Spacing.lg)
                }
            }
        }
        .onAppear {
            startTimer()
        }
        .onDisappear {
            stopTimer()
        }
    }

    // MARK: - Countdown Badge

    private var countdownBadge: some View {
        HStack(spacing: Spacing.xxs) {
            Image(systemName: "timer")
                .font(.system(size: 14))
                .foregroundColor(AppColors.textSecondary)
            Text("\(countdown)s")
                .font(AppFont.tabletBody3Regular)
                .foregroundColor(AppColors.textSecondary)
        }
        .padding(.horizontal, Spacing.sm)
        .padding(.vertical, Spacing.xxs)
        .background(Color.white)
        .cornerRadius(AppRadius.Tablet.full)
    }

    // MARK: - Timer

    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if countdown > 0 {
                countdown -= 1
            } else {
                stopTimer()
                onDone()
            }
        }
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
}

// MARK: - Preview

#Preview("With Amount") {
    AuthApprovedView(amount: 100, onDone: {})
}

#Preview("Without Amount") {
    AuthApprovedView(amount: nil, onDone: {})
}
