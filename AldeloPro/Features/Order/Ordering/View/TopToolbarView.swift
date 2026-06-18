//
//  TopToolbarView.swift
//  AldeloExpressPro
//
//  Created by LiZong on 2026/06/05.
//

import SwiftUI

// MARK: - 顶部工具栏


/// 点单页面顶部的导航工具栏
/// 包含返回按钮、订单号、桌号、客人数、时间等信息
struct TopToolbarView: View {
    var userName: String = "Zhang San"
    var clockedInTime: String = "Clocked In 12:25 PM"
    var userInitial: String = "Z"
    var hasNotification: Bool = true

    var body: some View {
        HStack(spacing: Spacing.md) {
            aiSearchField
            Spacer()
            notificationBell
            userInfoSection
        }
        .padding(.horizontal, Spacing.md)
    }

    // MARK: - AI Search Field

    private var aiSearchField: some View {
        HStack(spacing: Spacing.xs) {
            Text("Say \"Hey Aldelo\" to talk with AI..")
                .font(AppFont.tabletBody5Regular)
                .foregroundColor(AppColors.inputPlaceholder)
                .lineLimit(1)

            Spacer()

            ZStack {
                Capsule()
                    .fill(AppColors.aiSearchGradient)
                Image(systemName: "mic")
                    .font(.system(size: 18))
                    .foregroundColor(AppColors.black100)
            }
            .frame(width: 56, height: 38)
        }
        .padding(.leading, Spacing.md)
        .padding(.trailing, Spacing.xxs + 1)
        .frame(height: 48)
        .background(AppColors.inputBg)
        .clipShape(Capsule())
//        .overlay(
//            Capsule()
//                .stroke(style: StrokeStyle(lineWidth: 1.5, dash: [6, 4]))
//                .foregroundColor(AppColors.primaryLightActive)
//        )
        .frame(maxWidth: 391)
    }

    // MARK: - Notification Bell

    private var notificationBell: some View {
        ZStack(alignment: .topTrailing) {
            Circle()
                .fill(AppColors.inputBg)
                .frame(width: 48, height: 48)
                .overlay(
                    Image(.frame4)
                        .font(.system(size: 20))
                        .foregroundColor(AppColors.textPrimary)
                )

            if hasNotification {
                Circle()
                    .fill(AppColors.errorNormal)
                    .frame(width: 9, height: 9)
                    .overlay(
                        Circle()
                            .stroke(AppColors.white100, lineWidth: 1)
                    )
                    .offset(x: -2, y: 2)
            }
        }
    }

    // MARK: - User Info

    private var userInfoSection: some View {
        HStack(spacing: Spacing.xs) {
            ZStack {
                Circle()
                    .fill(AppColors.primaryNormal.opacity(0.1))
                    .frame(width: 48, height: 48)
                Circle()
                    .fill(AppColors.primaryNormal.opacity(0.7))
                    .frame(width: 40, height: 40)
                Text(userInitial)
                    .font(AppFont.tabletH3Medium)
                    .foregroundColor(AppColors.white100)
            }
            .frame(width: 48, height: 48)

            VStack(alignment: .leading, spacing: 2) {
                Text(userName)
                    .font(AppFont.tabletH6Medium)
                    .foregroundColor(AppColors.textPrimary)
                    .lineLimit(1)

                Text(clockedInTime)
                    .font(AppFont.tabletCaption2Regular)
                    .foregroundColor(AppColors.textSecondary)
                    .lineLimit(1)
            }

            Image(.switch)
                .resizable()
                .frame(width: 32, height: 32)
                .foregroundColor(AppColors.black_100)
        }
    }
}

// MARK: - Preview

#Preview("Top Toolbar") {
    TopToolbarView()
        .padding(.horizontal, Spacing.md)
        .padding(.vertical, Spacing.sm)
        .background(AppColors.pageBgDeep)
}

