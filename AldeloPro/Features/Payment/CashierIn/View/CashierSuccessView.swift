//
//  CashierSuccessView.swift
//  AldeloPro
//
//  Created by Sen on 2026/06/04.
//

import SwiftUI

// MARK: - 登录成功视图

/// 登录成功后展示员工头像、姓名和职位
/// 带有绿色对勾弹入动画
/// 2 秒后自动跳转到下一步（设置开班金额）
/// - 页面内容竖直居中（即使上方有 HeaderBar）
/// - 所有尺寸按 screenWidth/1440 比例缩放，适配横竖屏
struct CashierSuccessView: View {
    // MARK: - 属性

    /// 当前登录会话信息
    let session: CashierSession
    /// 继续操作的回调（跳转到开班金额设置）
    let onContinue: () -> Void

    @Environment(\.horizontalSizeClass) private var hSizeClass
    /// 控制入场动画
    @State private var appeared = false

    // MARK: - Body
    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            let isCompact = hSizeClass == .compact
            let isLandscape = w > h
            // iPad: width/1440, iPhone横屏: height/960, iPhone竖屏: width/390
            let scale = isCompact
                ? (isLandscape ? h / 960 : w / 390)
                : w / 1440

            // 整体竖直居中，iPhone横屏可滚动
            ScrollView(showsIndicators: false) {
                VStack(spacing: scale * 24) {
                    Spacer(minLength: 0)
                    // 标题 + 对勾图标
                    VStack(spacing: scale * 16) {
                        Text("Signed In Successfully")
                            .font(isCompact ? AppFont.tabletH3Medium : AppFont.tabletH1Medium)
                            .foregroundColor(AppColors.textPrimary)

                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: isCompact ? 44 : scale * 60))
                            .foregroundColor(AppColors.successNormal)
                            .scaleEffect(appeared ? 1.0 : 0.5)
                            .opacity(appeared ? 1.0 : 0)
                    }

                    // 用户信息卡片
                    userInfoCard(scale: scale, isCompact: isCompact)
                    Spacer(minLength: 0)
                }
                .frame(maxWidth: .infinity, minHeight: h)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                appeared = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                onContinue()
            }
        }
    }

    // MARK: - 用户信息卡片

    /// 显示头像、姓名、职位的圆角卡片（比例缩放）
    private func userInfoCard(scale: CGFloat, isCompact: Bool) -> some View {
        let cardWidth: CGFloat = isCompact ? .infinity : scale * 640
        let avatarSize: CGFloat = isCompact ? 80 : scale * 150

        return VStack(spacing: scale * 16) {
            // 头像占位
            Circle()
                .fill(AppColors.pageBgDeep)
                .frame(width: avatarSize, height: avatarSize)
                .overlay(
                    Image(systemName: "person.fill")
                        .font(.system(size: avatarSize * 0.42))
                        .foregroundColor(AppColors.textTertiary)
                )
                .overlay(
                    Circle()
                        .stroke(AppColors.line, lineWidth: 2)
                )

            // 员工姓名
            Text(session.employeeName)
                .font(AppFont.tabletH1Medium)
                .foregroundColor(AppColors.textPrimary)

            // 员工职位
            HStack(spacing: Spacing.xxs) {
                Image(systemName: "person")
                    .font(.system(size: 18))
                    .foregroundColor(AppColors.textSecondary)
                Text(session.employeeRole)
                    .font(AppFont.tabletBody2Regular)
                    .foregroundColor(AppColors.textSecondary)
            }
        }
        .padding(.vertical, scale * 40)
        .padding(.horizontal, scale * 32)
        .frame(maxWidth: cardWidth)
        .padding(.horizontal, isCompact ? Spacing.lg : 0)
        .background(AppColors.card)
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.Tablet.lg))
    }
}

// MARK: - Preview

#Preview("登录成功") {
    CashierSuccessView(session: .preview) {}
}
