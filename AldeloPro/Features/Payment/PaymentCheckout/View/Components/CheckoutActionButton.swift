import SwiftUI

// MARK: - 结账操作按钮
/// Continue / Done 按钮
/// 可用时：实心蓝色；不可用时：蓝色 + 0.4 透明度
struct CheckoutActionButton: View {
    /// 按钮文字
    let title: String
    /// 是否可点击
    let isEnabled: Bool
    /// 点击回调
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(AppFont.tabletButton4Medium)
                .foregroundColor(AppColors.white100)
                .frame(maxWidth: 360)
                .frame(height: 56)
                .background(buttonBackground)
                .clipShape(RoundedRectangle(cornerRadius: AppRadius.Tablet.md))
        }
        .disabled(!isEnabled)
    }

    // MARK: - 按钮背景

    private var buttonBackground: Color {
        AppColors.primaryNormal.opacity(isEnabled ? 1.0 : 0.4)
    }
}
