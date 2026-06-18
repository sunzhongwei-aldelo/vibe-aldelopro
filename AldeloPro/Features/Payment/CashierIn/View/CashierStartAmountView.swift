//
//  CashierStartAmountView.swift
//  AldeloPro
//
//  Created by Sen on 2026/06/04.
//

import SwiftUI

// MARK: - 开班金额设置视图

/// 收银员登录成功后设置 Start Amount（开班金额）
/// 布局：
/// - 顶部标题 "Cashier Start Amount"
/// - 金额显示框（左侧 "Amount" 标签，右侧格式化金额）
/// - 数字键盘 4 列（左侧 3 列数字 + 右侧功能列：删除/清除/Cashier In）
/// - 所有尺寸按 screenWidth/1440 比例缩放，适配横竖屏
struct CashierStartAmountView: View {
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
            let contentWidth = isCompact
                ? (isLandscape ? h * 0.6 : w - Spacing.lg * 2)
                : scale * 580

            ScrollView(showsIndicators: false) {
                VStack(spacing: scale * 28) {
                    Spacer(minLength: isCompact ? Spacing.md : scale * 60)

                    Text("Cashier Start Amount")
                        .font(isCompact ? AppFont.tabletH3Medium : AppFont.tabletH1Medium)
                        .foregroundColor(AppColors.textPrimary)

                    amountField(scale: scale)

                    numpadSection(scale: scale)

                    Spacer(minLength: isCompact ? Spacing.md : 0)
                }
                .frame(width: contentWidth)
                .frame(maxWidth: .infinity, minHeight: h)
            }
        }
    }

    // MARK: - 金额显示框

    /// 左侧标签 + 右侧格式化金额（如 "$100.00"）
    private func amountField(scale: CGFloat) -> some View {
        HStack {
            Text("Amount")
                .font(AppFont.tabletBody2Regular)
                .foregroundColor(AppColors.textSecondary)
            Spacer()
            Text(viewModel.formattedStartAmount)
                .font(AppFont.tabletH1Medium)
                .foregroundColor(AppColors.textPrimary)
                .fontWeight(.semibold)
        }
        .frame(height: scale * 74)
        .padding(.horizontal, Spacing.lg)
        .background(AppColors.inputBg)
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.Tablet.sm))
    }

    // MARK: - 数字键盘

    /// 左侧数字区 + 右侧功能列的组合布局（比例缩放）
    private func numpadSection(scale: CGFloat) -> some View {
        // 设计稿: key=131.6×107.6, gap=17.4, 4列等宽
        let keyHeight = scale * 107.6
        let gap = scale * 17.4

        return HStack(alignment: .top, spacing: gap) {
            // 左侧：数字键盘 3 列（1-9, 0, 00）
            VStack(spacing: gap) {
                numpadRow(["1", "2", "3"], height: keyHeight, gap: gap)
                numpadRow(["4", "5", "6"], height: keyHeight, gap: gap)
                numpadRow(["7", "8", "9"], height: keyHeight, gap: gap)

                // 底行: 0 + 00（00 跨两列宽度）
                HStack(spacing: gap) {
                    numpadDigitButton("0", height: keyHeight)
                    doubleZeroButton(height: keyHeight)
                }
            }

            // 右侧：功能列（删除 / 清除 / Cashier In）
            // 设计稿：与数字键同宽（单列），Cashier In 高=234(约 2 行 + gap)
            VStack(spacing: gap) {
                deleteButton(height: keyHeight)
                clearButton(height: keyHeight)
                cashierInButton(height: keyHeight * 2 + gap)
            }
            .frame(width: scale * 133)
        }
    }

    /// 数字行（3 个等宽数字按钮）
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
            viewModel.appendAmountDigit(digit)
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

    /// "00" 快捷按钮（跨两列宽度）
    private func doubleZeroButton(height: CGFloat) -> some View {
        Button {
            viewModel.appendDoubleZero()
        } label: {
            Text("00")
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

    /// 删除按钮（退格）
    private func deleteButton(height: CGFloat) -> some View {
        Button {
            viewModel.deleteAmountDigit()
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

    /// 清除按钮（归零）
    private func clearButton(height: CGFloat) -> some View {
        Button {
            viewModel.clearAmount()
        } label: {
            Text("Clear")
                .font(AppFont.tabletDisplay6Medium)
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

    /// Cashier In 确认按钮（提交金额并完成开班）
    private func cashierInButton(height: CGFloat) -> some View {
        Button {
            Task { await viewModel.cashierIn() }
        } label: {
            Text("Cashier In")
                .font(AppFont.tabletH3Medium)
                .foregroundColor(AppColors.buttonPrimaryText)
                .frame(maxWidth: .infinity)
                .frame(height: height)
                .background(AppColors.buttonPrimaryBg)
                .clipShape(RoundedRectangle(cornerRadius: AppRadius.Tablet.lg))
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preview

#Preview("开班金额设置") {
    CashierStartAmountView(viewModel: .preview(step: .startAmount(.preview)))
}
