import SwiftUI

struct CardTapView: View {
    let mode: CardTapMode
    let onCancel: () -> Void
    let onVerified: () -> Void

    @State private var animateWaves: Bool = false

    var body: some View {
        ZStack {
            // Background
            Color(hex: "#EBEEF5")
                .ignoresSafeArea()

            VStack(spacing: Spacing.xxxl) {
                Spacer()

                // Title
                Text(titleText)
                    .font(AppFont.tabletH1Medium)
                    .foregroundColor(AppColors.textPrimary)

                // Amount (only for pre-auth)
                if case .preAuth(let amount) = mode {
                    Text("$\(NSDecimalNumber(decimal: amount).stringValue).00")
                        .font(AppFont.tabletDisplay3Semibold)
                        .foregroundColor(AppColors.textPrimary)
                }

                // NFC Card Tap Illustration
                cardTapIllustration

                Spacer()

                // Cancel Button
                Button(action: onCancel) {
                    Text("Cancel")
                        .font(AppFont.tabletButton3Medium)
                        .foregroundColor(AppColors.textPrimary)
                        .frame(width: 200, height: 48)
                        .background(Color.white)
                        .cornerRadius(AppRadius.Tablet.lg)
                        .shadow(color: AppColors.black8, radius: 4, y: 2)
                }
                .padding(.bottom, Spacing.xxl)
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                animateWaves = true
            }
        }
        .onTapGesture {
            // Simulate card tap for demo
            onVerified()
        }
    }

    // MARK: - Title

    private var titleText: String {
        switch mode {
        case .preAuth:
            return "Pre-Auth Ceiling Limit"
        case .openAuth:
            return "Verify Card for Open Auth"
        }
    }

    // MARK: - Card Tap Illustration

    private var cardTapIllustration: some View {
        ZStack {
            // Signal waves
            ForEach(0..<3, id: \.self) { index in
                Circle()
                    .stroke(AppColors.primaryNormal, lineWidth: 2)
                    .frame(
                        width: CGFloat(60 + index * 30),
                        height: CGFloat(60 + index * 30)
                    )
                    .opacity(animateWaves ? 0.3 + Double(index) * 0.2 : 0.6 - Double(index) * 0.15)
                    .scaleEffect(animateWaves ? 1.05 : 0.95)
                    .offset(y: -20)
            }

            // NFC reader circle
            Circle()
                .stroke(AppColors.primaryNormal, lineWidth: 3)
                .frame(width: 80, height: 80)
                .offset(y: -20)

            // Card icon
            cardIcon
                .offset(x: 20, y: 30)
        }
        .frame(width: 200, height: 200)
    }

    private var cardIcon: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 6)
                .stroke(AppColors.primaryNormal, lineWidth: 2)
                .frame(width: 60, height: 40)
                .rotationEffect(.degrees(-30))

            Text("CARD")
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(AppColors.primaryNormal)
                .rotationEffect(.degrees(-30))
        }
    }
}

// MARK: - Preview

#Preview("Pre-Auth") {
    CardTapView(
        mode: .preAuth(amount: 100),
        onCancel: {},
        onVerified: {}
    )
}

#Preview("Open Auth") {
    CardTapView(
        mode: .openAuth,
        onCancel: {},
        onVerified: {}
    )
}
