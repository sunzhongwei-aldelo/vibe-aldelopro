//
//  PrinterSetupView.swift
//  AldeloPro
//
//  Created by wanghui on 2026/06/15.
//

import SwiftUI

// MARK: - PrinterSetupView

/// Add Hardware 注册步骤页（设备/打印机搜索）。
///
/// 对应设计稿 Registration 15（初始）与 Registration 16（搜索中）两个状态：
/// 点击中心「Search for Devices」卡片切换到「Searching …」并在下方显示雷达 loading 动画。
/// 顶栏复用 `SetupTopBarView`；右上角 Ask AI 入口暂不实现。
struct PrinterSetupView: View {

    // MARK: - Environment

    /// 全局设备布局（由根视图 `.provideDeviceLayout()` 注入）
    @Environment(\.deviceLayout) private var layout

    // MARK: - State

    @State private var viewModel = PrinterSetupViewModel()

    // MARK: - Callbacks

    /// 上一步（出栈返回，由父级 SetupFlowRootView 注入）。
    var onPrevious: (() -> Void)?
    /// 流程完成，进入 Login（由父级注入）。
    var onComplete: (() -> Void)?

    private var isPhone: Bool { layout.isPhonePortrait }

    // MARK: - Body

    var body: some View {
        VStack(spacing: 0) {
            SetupTopBarView(progress: 1.0)

            centerContent
                .frame(maxWidth: .infinity, maxHeight: .infinity)

            bottomButtons
        }
        .background(AppColors.pageBgDeep)
    }

    // MARK: - Center Content

    private var centerContent: some View {
        VStack(spacing: isPhone ? Spacing.xl : Spacing.xxl) {
            title
            deviceCard
            if viewModel.isSearching {
                RadarLoadingView(diameter: isPhone ? 200 : 260)
            }
        }
        .padding(.horizontal, isPhone ? Spacing.md : Spacing.xl)
    }

    private var title: some View {
        Text("Add Hardware")
            .font(isPhone ? AppFont.mobileH1Medium : AppFont.tabletH1Medium)
            .foregroundColor(AppColors.textPrimary)
    }

    // MARK: - Device Card

    /// 中心可点击卡片：待搜索显示「Search for Devices」，搜索中显示「Searching …」。
    private var deviceCard: some View {
        Button {
            viewModel.toggleSearching()
        } label: {
            VStack(spacing: Spacing.md) {
                Image("Search for Devices")
                    .foregroundColor(AppColors.textPrimary)

                Text(viewModel.isSearching ? "Searching …" : "Search for Devices")
                    .font(isPhone ? AppFont.mobileH3Medium : AppFont.tabletH3Medium)
                    .foregroundColor(AppColors.textPrimary)
            }
            .frame(maxWidth: 360)
            .frame(height: 180)
            .frame(maxWidth: .infinity)
            .background(AppColors.card)
            .clipShape(RoundedRectangle(cornerRadius: AppRadius.Tablet.lg))
            .overlay(
                RoundedRectangle(cornerRadius: AppRadius.Tablet.lg)
                    .stroke(AppColors.line, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .frame(maxWidth: 360)
    }

    // MARK: - Bottom Buttons

    private var bottomButtons: some View {
        HStack(spacing: Spacing.md) {
            if isPhone == false { Spacer() }

            Button {
                viewModel.previousStep()
                onPrevious?()
            } label: {
                Text("Previous Step")
                    .font(isPhone ? AppFont.mobileButton1Medium : AppFont.tabletButton3Medium)
                    .foregroundColor(AppColors.primaryNormal)
                    .frame(maxWidth: isPhone ? .infinity : 382)
                    .controlHeight(64)
                    .background(AppColors.card)
                    .clipShape(RoundedRectangle(cornerRadius: AppRadius.Tablet.lg))
            }
            .buttonStyle(.plain)

            Button {
                viewModel.skipStep()
                onComplete?()
            } label: {
                Text("Skip This Step")
                    .font(isPhone ? AppFont.mobileButton1Medium : AppFont.tabletButton3Medium)
                    .foregroundColor(AppColors.primaryNormal)
                    .frame(maxWidth: isPhone ? .infinity : 382)
                    .controlHeight(64)
                    .background(AppColors.card)
                    .clipShape(RoundedRectangle(cornerRadius: AppRadius.Tablet.lg))
            }
            .buttonStyle(.plain)

            if isPhone == false { Spacer() }
        }
        .padding(.horizontal, isPhone ? Spacing.md : Spacing.xl)
        .padding(.bottom, Spacing.xl)
    }
}

// MARK: - Preview

#Preview {
    PrinterSetupView()
        .provideDeviceLayout()
}
