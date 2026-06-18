import SwiftUI

extension CGFloat {
    static var screenHeight: CGFloat {
        return UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first?.screen.bounds.height ?? 0
    }
    
    static var screenWidth: CGFloat {
        return UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first?.screen.bounds.width ?? 0
    }
}

struct CashierTopBar: View {
    var employeeName: String = "Zhang San"
    var clockInTime: String = "Clocked In 12:25 PM"
    var onBack: (() -> Void)?

    private var barHeight: CGFloat {
        return CGFloat.screenHeight < 800 ? 80 : 96
    }
    
    var body: some View {
        HStack(spacing: Spacing.md) {
            // Left: Cashier icon + title
            cashierTitle

            Spacer()

            // Center: AI search bar
            aiSearchBar

            Spacer()

            // Right: User info + Back button
            HStack(spacing: Spacing.md) {
                userInfo
                backButton
            }
        }
        .padding(.horizontal, Spacing.lg)
        .frame(height: barHeight)
        .background(AppColors.glass)
        .overlay(
            Rectangle()
                .frame(height: 1)
                .foregroundColor(AppColors.line),
            alignment: .bottom
        )
    }

    // MARK: - Cashier Title
    private var cashierTitle: some View {
        HStack(spacing: Spacing.sm) {
            Image(systemName: "basket")
                .font(.system(size: 24))
                .foregroundColor(AppColors.textPrimary)
            Text("Cashier")
                .font(AppFont.tabletH1Medium)
                .foregroundColor(AppColors.textPrimary)
        }
    }

    // MARK: - AI Search Bar
    private var aiSearchBar: some View {
        HStack(spacing: Spacing.sm) {
            Text("Say \"Hey Aldelo\" to talk with AI..")
                .font(AppFont.tabletBody5Regular)
                .foregroundColor(AppColors.inputPlaceholder)
            Spacer()
            Circle()
                .fill(AppColors.pageBg)
                .frame(width: 38, height: 38)
                .overlay(
                    Image(systemName: "mic")
                        .font(.system(size: 15))
                        .foregroundColor(AppColors.textPrimary)
                )
        }
        .padding(.horizontal, Spacing.md)
        .frame(width: 391, height: 48)
        .background(
            RoundedRectangle(cornerRadius: Spacing.lg)
                .fill(AppColors.inputBg)
        )
    }

    // MARK: - User Info
    private var userInfo: some View {
        HStack(spacing: Spacing.md) {
            ZStack {
                Circle()
                    .fill(AppColors.primaryNormal.opacity(0.1))
                    .frame(width: 48, height: 48)
                Circle()
                    .fill(AppColors.primaryNormal.opacity(0.7))
                    .frame(width: 40, height: 40)
                Text(String(employeeName.prefix(1)))
                    .font(AppFont.tabletH3Medium)
                    .foregroundColor(AppColors.white100)
            }
            VStack(alignment: .leading, spacing: Spacing.xxs) {
                Text(employeeName)
                    .font(AppFont.tabletBody5Regular)
                    .foregroundColor(AppColors.textPrimary)
                Text(clockInTime)
                    .font(AppFont.tabletCaption1Regular)
                    .foregroundColor(AppColors.textSecondary)
            }
        }
    }

    // MARK: - Back Button
    private var backButton: some View {
        AldeloButton(title: "Back",style:.secondary, size: .large) {
            onBack?()
        }.frame(width: 178)
//        Button(action: { onBack?() }) {
//            Text("Back")
//                .font(AppFont.tabletH3Medium)
//                .foregroundColor(AppColors.textPrimary)
//                .frame(width: 178, height: 64)
//                .background(
//                    RoundedRectangle(cornerRadius: AppRadius.Tablet.lg)
//                        .fill(AppColors.inputBg)
//                )
//        }
    }
}

#Preview {
    CashierTopBar()
}
