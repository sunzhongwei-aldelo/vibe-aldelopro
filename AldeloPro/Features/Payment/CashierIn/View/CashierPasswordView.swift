//
//  CashierPasswordView.swift
//  AldeloPro
//
//  Created by Sen on 2026/06/04.
//

import SwiftUI

// MARK: - 密码登录视图

/// 收银员通过输入密码进行登录
/// - 右上角提供 "Face ID Login" 按钮可切换回面部识别
/// - 中间显示密码输入框（圆点遮盖）
/// - 下方为 3×4 数字键盘 + 删除键 + Sign In 按钮
/// - 所有尺寸按 screenWidth/1440 比例缩放，适配横竖屏
struct CashierPasswordView: View {
    // MARK: - 依赖
    @Bindable var viewModel: CashierInViewModel
    @Environment(\.horizontalSizeClass) private var hSizeClass

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

            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    // 右上角：切换到面部识别登录
                    HStack {
                        Spacer()
                        faceIDLoginButton
                    }
                    .padding(.horizontal, Spacing.lg)
                    .padding(.top, Spacing.md)

                    Spacer(minLength: isCompact ? Spacing.md : 0)

                    // 居中内容：标题 + 密码框 + 数字键盘
                    VStack(spacing: scale * 24) {
                        Text("Please Enter Your Passcode")
                            .font(isCompact ? AppFont.tabletH3Medium : AppFont.tabletH1Medium)
                            .foregroundColor(AppColors.textPrimary)

                        passcodeField(scale: scale)

                        numpadGrid(scale: scale)
                    }
                    .frame(width: isCompact ? (isLandscape ? h * 0.52 : w - Spacing.lg * 2) : scale * 496)

                    Spacer(minLength: isCompact ? Spacing.md : 0)
                }
                .frame(maxWidth: .infinity, minHeight: h)
            }
        }
    }

    // MARK: - Face ID 登录切换按钮

    /// 右上角按钮，点击后切换回面部识别页面
    private var faceIDLoginButton: some View {
        Button {
            viewModel.switchToFaceID()
        } label: {
            HStack(spacing: Spacing.sm) {
                Image(systemName: "faceid")
                    .font(.system(size: 24))
                    .foregroundColor(AppColors.textPrimary)
                Text("Face ID Login")
                    .font(AppFont.tabletH3Medium)
                    .foregroundColor(AppColors.textPrimary)
            }
            .padding(.horizontal, Spacing.lg)
            .padding(.vertical, Spacing.sm)
            .background(AppColors.white100)
            .clipShape(RoundedRectangle(cornerRadius: AppRadius.Tablet.md))
            .overlay(
                RoundedRectangle(cornerRadius: AppRadius.Tablet.md)
                    .stroke(AppColors.line, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - 密码输入框

    /// 显示已输入密码的圆点遮盖
    private func passcodeField(scale: CGFloat) -> some View {
        HStack {
            Text(viewModel.maskedPasscode)
                .font(AppFont.tabletH1Medium)
                .foregroundColor(AppColors.textPrimary)
            Spacer()
        }
        .frame(height: scale * 74)
        .padding(.horizontal, Spacing.lg)
        .background(AppColors.inputBg)
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.Tablet.sm))
    }

    // MARK: - 数字键盘

    /// 3×4 数字键盘布局（比例缩放）
    private func numpadGrid(scale: CGFloat) -> some View {
        // 设计稿：key=153.267×122.6, gap≈17, 底行 delete=150.6, 0=150.6, signIn=160×124
        let keyHeight = scale * 122.6
        let gap = scale * 17

        return VStack(spacing: gap) {
            numpadRow(["1", "2", "3"], height: keyHeight, gap: gap)
            numpadRow(["4", "5", "6"], height: keyHeight, gap: gap)
            numpadRow(["7", "8", "9"], height: keyHeight, gap: gap)

            // 第四行: 删除, 0, Sign In
            HStack(spacing: gap) {
                deleteButton(height: scale * 124)
                numpadDigitButton("0", height: scale * 124)
                signInButton(height: scale * 124)
            }
        }
    }

    /// 数字行（3 个数字按钮）
    private func numpadRow(_ digits: [String], height: CGFloat, gap: CGFloat) -> some View {
        HStack(spacing: gap) {
            ForEach(digits, id: \.self) { digit in
                numpadDigitButton(digit, height: height)
            }
        }
    }

    /// 单个数字按钮
    private func numpadDigitButton(_ digit: String, height: CGFloat) -> some View {
        Button {
            viewModel.appendPasscodeDigit(digit)
        } label: {
            Text(digit)
                .font(AppFont.tabletDisplay1Medium)
                .foregroundColor(AppColors.textPrimary)
                .frame(maxWidth: .infinity)
                .frame(height: height)
                .background(AppColors.white100)
                .clipShape(RoundedRectangle(cornerRadius: AppRadius.Tablet.lg))
                .overlay(
                    RoundedRectangle(cornerRadius: AppRadius.Tablet.lg)
                        .stroke(AppColors.line, lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
    }

    /// 删除按钮
    private func deleteButton(height: CGFloat) -> some View {
        Button {
            viewModel.deletePasscodeDigit()
        } label: {
            Image(systemName: "delete.left")
                .font(.system(size: 28, weight: .medium))
                .foregroundColor(AppColors.textPrimary)
                .frame(maxWidth: .infinity)
                .frame(height: height)
                .background(AppColors.white100)
                .clipShape(RoundedRectangle(cornerRadius: AppRadius.Tablet.lg))
                .overlay(
                    RoundedRectangle(cornerRadius: AppRadius.Tablet.lg)
                        .stroke(AppColors.line, lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
    }

    /// Sign In 按钮（密码非空时可用）
    private func signInButton(height: CGFloat) -> some View {
        Button {
            Task { await viewModel.submitPasscode() }
        } label: {
            Text("Sign In")
                .font(AppFont.tabletDisplay6Medium)
                .foregroundColor(AppColors.buttonPrimaryText)
                .frame(maxWidth: .infinity)
                .frame(height: height)
                .background(AppColors.buttonPrimaryBg)
                .clipShape(RoundedRectangle(cornerRadius: AppRadius.Tablet.lg))
        }
        .buttonStyle(.plain)
        .disabled(viewModel.passcodeInput.isEmpty)
    }
}

// MARK: - Preview

#Preview("密码登录页") {
    CashierPasswordView(viewModel: .preview(step: .passwordEntry))
}
