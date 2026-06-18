import SwiftUI

// MARK: - 满意度反馈页
/// 截图对照：背景浅灰，中间 "How did we do today?" 大字
/// 下方两个大白色卡片（👍/👎），选中绿色/红色高亮
/// 底部 Continue 蓝色实心按钮
struct FeedbackRatingView: View {
    @Binding var rating: FeedbackRating?
    let onContinue: () -> Void

    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.horizontalSizeClass) private var hSizeClass

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            // 标题
            Text("How did we do today?")
                .font(AppFont.tabletH1Medium)
                .foregroundColor(titleColor)
                .padding(.bottom, Spacing.xxl)

            // 👍👎 卡片
            VStack(spacing: Spacing.lg) {
                feedbackCard(
                    icon: "hand.thumbsup",
                    iconColor: AppColors.successNormal,
                    isSelected: rating == .thumbsUp,
                    selectedBg: AppColors.successLight,
                    selectedBorder: AppColors.successNormal
                ) {
                    rating = .thumbsUp
                }

                feedbackCard(
                    icon: "hand.thumbsdown",
                    iconColor: AppColors.errorNormal,
                    isSelected: rating == .thumbsDown,
                    selectedBg: AppColors.errorLight,
                    selectedBorder: AppColors.errorNormal
                ) {
                    rating = .thumbsDown
                }
            }
            .padding(.horizontal, cardPadding)

            Spacer()
            Spacer()

            // Continue
            CheckoutBottomBar(
                buttonTitle: "Continue",
                isEnabled: true,
                showCountdown: false,
                onAction: onContinue
            )
        }
        .background(AppColors.pageBg)
    }

    // MARK: - 反馈卡片

    private func feedbackCard(
        icon: String,
        iconColor: Color,
        isSelected: Bool,
        selectedBg: Color,
        selectedBorder: Color,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 36))
                .foregroundColor(iconColor)
                .frame(maxWidth: .infinity)
                .frame(height: hSizeClass == .regular ? 120 : 90)
                .background(isSelected ? selectedBg : cardBg)
                .clipShape(RoundedRectangle(cornerRadius: AppRadius.Tablet.lg))
                .overlay(
                    RoundedRectangle(cornerRadius: AppRadius.Tablet.lg)
                        .stroke(isSelected ? selectedBorder : Color.clear, lineWidth: 2)
                )
        }
        .buttonStyle(.plain)
    }

    // MARK: - 颜色

    private var titleColor: Color {
        colorScheme == .dark ? AppColors.white100 : AppColors.textPrimary
    }

    private var cardBg: Color {
        colorScheme == .dark ? AppColors.card : AppColors.white100
    }

    /// iPad 卡片区域更窄（居中效果）
    private var cardPadding: CGFloat {
        hSizeClass == .regular ? Spacing.xxxxxl * 1.5 : Spacing.lg
    }
}

// MARK: - Preview

#Preview {
    @Previewable @State var rating: FeedbackRating? = nil
    FeedbackRatingView(rating: $rating, onContinue: {})
}

#Preview("Selected") {
    @Previewable @State var rating: FeedbackRating? = .thumbsUp
    FeedbackRatingView(rating: $rating, onContinue: {})
}
