import SwiftUI

// MARK: - 签名板容器
/// 包含签名画布 + "Sign Here" 占位 + "Clear" 按钮
/// 未签名时显示灰色 "Sign Here"，签名后隐藏占位文字
struct SignaturePadView: View {
    /// 签名画布 ViewModel
    @Bindable var canvasViewModel: SignatureCanvasViewModel
    /// 签名完成状态（双向绑定到父级）
    @Binding var hasSignature: Bool

    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            // 签名区域
            ZStack {
                // 背景
                RoundedRectangle(cornerRadius: AppRadius.Tablet.lg)
                    .fill(cardBg)

                // 占位文字（未签名时显示）
                if !canvasViewModel.hasContent {
                    Text("Sign Here")
                        .font(AppFont.tabletH1Medium)
                        .foregroundColor(AppColors.inputPlaceholder)
                }

                // 签名画布
                SignatureCanvasView(viewModel: canvasViewModel)
                    .clipShape(RoundedRectangle(cornerRadius: AppRadius.Tablet.lg))
            }
            .frame(minHeight: 200)

            // Clear 按钮（签名后显示）
            if canvasViewModel.hasContent {
                clearButton
                    .padding(Spacing.md)
            }
        }
        .onChange(of: canvasViewModel.hasContent) { _, newValue in
            hasSignature = newValue
        }
    }

    // MARK: - Clear 按钮

    private var clearButton: some View {
        Button {
            canvasViewModel.clear()
        } label: {
            Text("Clear")
                .font(AppFont.tabletCaption1Regular)
                .foregroundColor(textColor)
                .padding(.horizontal, Spacing.md)
                .padding(.vertical, Spacing.xs)
                .background(cardBg)
                .clipShape(RoundedRectangle(cornerRadius: AppRadius.Tablet.sm))
                .overlay(
                    RoundedRectangle(cornerRadius: AppRadius.Tablet.sm)
                        .stroke(AppColors.optionUnselectedStroke, lineWidth: 1)
                )
        }
    }

    private var cardBg: Color {
        colorScheme == .dark ? AppColors.card : AppColors.white100
    }

    private var textColor: Color {
        colorScheme == .dark ? AppColors.white100 : AppColors.textPrimary
    }
}
