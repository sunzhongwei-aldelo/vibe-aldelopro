//
//  CashierSignOutSuccessView.swift
//  AldeloPro
//
//  Created by Sen on 2026/06/05.
//

import SwiftUI

// MARK: - CashierSignOutSuccessView

/// 签退成功视图 — 展示绿色对勾、成功文本、Done 按钮
/// 右下角带有可暂停的自动退出倒计时
struct CashierSignOutSuccessView: View {
    let onDone: () -> Void

    @State private var appeared: Bool = false

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            // 主内容 - 居中
            VStack(spacing: Spacing.xl) {
                // 标题
                Text("Cashier Sign Out")
                    .font(AppFont.tabletH2Medium)
                    .foregroundColor(AppColors.textSecondary)

                // 绿色对勾
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 80))
                    .foregroundColor(AppColors.successNormal)
                    .scaleEffect(appeared ? 1.0 : 0.5)
                    .opacity(appeared ? 1.0 : 0)

                // Success 文字
                Text("Success")
                    .font(AppFont.tabletDisplay3Medium)
                    .foregroundColor(AppColors.textPrimary)

                // Done 按钮
                Button(action: onDone) {
                    Text("Done")
                        .font(AppFont.tabletH3Medium)
                        .foregroundColor(AppColors.buttonPrimaryText)
                        .frame(width: 280, height: 56)
                        .background(
                            RoundedRectangle(cornerRadius: AppRadius.Tablet.md)
                                .fill(AppColors.buttonPrimaryBg)
                        )
                }
                .buttonStyle(.plain)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            // 右下角倒计时
            SelfDrivingCountdownBadge(totalSeconds: 10, onExpire: onDone)
                .padding(Spacing.lg)
        }
        .background(AppColors.pageBg.ignoresSafeArea())
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                appeared = true
            }
        }
    }
}

// MARK: - Preview

#Preview("Sign Out Success") {
    CashierSignOutSuccessView(onDone: { print("Done") })
}

#Preview("Sign Out Success - Dark") {
    CashierSignOutSuccessView(onDone: { print("Done") })
        .preferredColorScheme(.dark)
}
