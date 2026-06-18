import SwiftUI

// MARK: - 底部操作栏
/// 截图对照：Done/Continue 按钮居中，倒计时胶囊在按钮右侧同一行
/// 按钮和倒计时不重叠，而是 HStack 布局
struct CheckoutBottomBar: View {
    /// 按钮文字
    let buttonTitle: String
    /// 按钮是否可用
    let isEnabled: Bool
    /// 是否显示倒计时
    let showCountdown: Bool
    /// 倒计时秒数
    var countdownSeconds: Int = 0
    /// 是否暂停
    var isPaused: Bool = false
    /// 暂停回调
    var onTogglePause: () -> Void = {}
    /// 按钮点击
    let onAction: () -> Void

    var body: some View {
        HStack(alignment: .center) {
            // 左侧占位（平衡右侧倒计时宽度）
            if showCountdown {
                Color.clear
                    .frame(width: 70, height: 1)
            }

            Spacer()

            // 中间按钮
            Button(action: onAction) {
                Text(buttonTitle)
                    .font(AppFont.tabletButton4Medium)
                    .foregroundColor(AppColors.white100)
                    .frame(width: 280, height: 56)
                    .background(AppColors.primaryNormal.opacity(isEnabled ? 1.0 : 0.4))
                    .clipShape(RoundedRectangle(cornerRadius: AppRadius.Tablet.md))
            }
            .disabled(!isEnabled)

            Spacer()

            // 右侧倒计时
            if showCountdown {
                CountdownBadge(
                    seconds: countdownSeconds,
                    isPaused: isPaused,
                    onTogglePause: onTogglePause
                )
                .frame(width: 70)
            }
        }
        .padding(.horizontal, Spacing.lg)
        .padding(.bottom, Spacing.xl)
    }
}
