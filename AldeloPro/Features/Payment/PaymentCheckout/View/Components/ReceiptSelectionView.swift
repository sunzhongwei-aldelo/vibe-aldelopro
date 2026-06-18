import SwiftUI

// MARK: - 收据选择页（Thank You）
/// 对照 Figma 设计：
/// - 绿色勾 + "Thank You" 文字在页面上方约 1/4 处
/// - 三个收据选项卡片（Email/Print/Text）+ 蓝色 Done 按钮，等宽居中
/// - iPad 内容宽度约 70%，iPhone 全宽
/// - 倒计时在右下角
/// - 默认按钮为 "No Receipt"，点击后变为 "Done" 执行退出
struct ReceiptSelectionView: View {
    @Binding var selectedReceipt: ReceiptOption?
    let countdownSeconds: Int
    let isPaused: Bool
    let onTogglePause: () -> Void
    let onDone: () -> Void

    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.horizontalSizeClass) private var hSizeClass

    private let receiptMethods: [ReceiptOption] = [.email, .print, .text]
    private var hasSelection: Bool { selectedReceipt != nil }

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            // 主内容（垂直+水平居中）
            VStack(spacing: 0) {
                Spacer()

                thankYouHeader

                Spacer()
                    .frame(height: Spacing.xxl)

                // 收据选项 + Done 按钮（等宽）
                VStack(spacing: Spacing.md) {
                    ForEach(receiptMethods) { option in
                        receiptRow(option)
                    }

                    actionButton
                }
                .frame(maxWidth: contentMaxWidth)

                Spacer()
            }
            .frame(maxWidth: .infinity)

            // 倒计时（右下角固定位置）
            CountdownBadge(
                seconds: countdownSeconds,
                isPaused: isPaused,
                onTogglePause: onTogglePause
            )
            .padding(.trailing, Spacing.lg)
            .padding(.bottom, Spacing.lg)
        }
        .background(AppColors.pageBg)
    }

    // MARK: - Thank You 头部

    private var thankYouHeader: some View {
        VStack(spacing: Spacing.md) {
            Image(systemName: "checkmark")
                .font(.system(size: 36, weight: .bold))
                .foregroundColor(AppColors.white100)
                .frame(width: 72, height: 72)
                .background(AppColors.successNormal)
                .clipShape(Circle())

            Text("Thank You")
                .font(AppFont.tabletH1Medium)
                .foregroundColor(titleColor)
        }
    }

    // MARK: - 收据选项行（白色卡片）

    private func receiptRow(_ option: ReceiptOption) -> some View {
        Button {
            selectedReceipt = option
        } label: {
            HStack(spacing: Spacing.md) {
                Image(systemName: option.iconName)
                    .font(.system(size: 22))
                    .foregroundColor(AppColors.textMuted)
                    .frame(width: 28)
                Text(option.rawValue)
                    .font(AppFont.tabletH4Medium)
                    .foregroundColor(titleColor)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 64)
            .background(rowBg(for: option))
            .clipShape(RoundedRectangle(cornerRadius: AppRadius.Tablet.md))
            .overlay(
                RoundedRectangle(cornerRadius: AppRadius.Tablet.md)
                    .stroke(
                        selectedReceipt == option ? AppColors.optionSelectedStroke : Color.clear,
                        lineWidth: 2
                    )
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - 底部操作按钮（与收据行等宽）

    private var actionButton: some View {
        Button {
            if hasSelection {
                onDone()
            } else {
                selectedReceipt = ReceiptOption.none
            }
        } label: {
            Text(hasSelection ? "Done" : "No Receipt")
                .font(AppFont.tabletButton4Medium)
                .foregroundColor(AppColors.white100)
                .frame(maxWidth: .infinity)
                .frame(height: 64)
                .background(AppColors.primaryNormal)
                .clipShape(RoundedRectangle(cornerRadius: AppRadius.Tablet.md))
        }
    }

    // MARK: - 适配

    private func rowBg(for option: ReceiptOption) -> Color {
        if selectedReceipt == option { return AppColors.optionSelectedFill }
        return colorScheme == .dark ? AppColors.card : AppColors.white100
    }

    private var titleColor: Color {
        colorScheme == .dark ? AppColors.white100 : AppColors.textPrimary
    }

    /// iPad 内容最大宽度约 70%（~700pt），iPhone 不限制
    private var contentMaxWidth: CGFloat {
        hSizeClass == .regular ? 700 : .infinity
    }
}

// MARK: - Preview

#Preview("Initial - iPad") {
    @Previewable @State var receipt: ReceiptOption? = nil
    ReceiptSelectionView(
        selectedReceipt: $receipt,
        countdownSeconds: 10, isPaused: false,
        onTogglePause: {}, onDone: {}
    )
}

#Preview("Done state") {
    @Previewable @State var receipt: ReceiptOption? = ReceiptOption.none
    ReceiptSelectionView(
        selectedReceipt: $receipt,
        countdownSeconds: 5, isPaused: false,
        onTogglePause: {}, onDone: {}
    )
}

