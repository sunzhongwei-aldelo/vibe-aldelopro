//
//  CashierInView.swift
//  AldeloPro
//
//  Created by Sen on 2026/06/04.
//

import SwiftUI

// MARK: - 收银员登录主视图

/// 收银员登录流程的容器视图
/// 根据 ViewModel 的 currentStep 切换显示不同子页面：
/// - 面部识别扫描页
/// - 密码输入页
/// - 登录成功页
/// - 开班金额设置页
struct CashierInView: View {
    // MARK: - ViewModel
    @State private var viewModel: CashierInViewModel
    @Environment(\.dismiss) private var dismiss

    // MARK: - 初始化

    /// - Parameter viewModel: 注入的 ViewModel 实例
    init(viewModel: CashierInViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    // MARK: - Body
    var body: some View {
        VStack(spacing: 0) {
            headerBar
            Divider()
                .foregroundColor(AppColors.line)

            contentArea
        }
        .background(AppColors.pageBg)
        .alert(
            viewModel.alertError?.title ?? "",
            isPresented: Binding(
                get: { viewModel.alertError != nil },
                set: { if !$0 { viewModel.dismissAlert() } }
            ),
            presenting: viewModel.alertError,
            actions: { _ in
                Button("OK") { viewModel.dismissAlert() }
            },
            message: { error in
                Text(error.message)
            }
        )
    }

    // MARK: - 顶部导航栏

    /// 包含 Cashier 标题和返回按钮
    private var headerBar: some View {
        HStack {
            HStack(spacing: Spacing.xs) {
                Image(systemName: "keyboard")
                    .font(.system(size: 28))
                    .foregroundColor(AppColors.textPrimary)
                Text("Cashier")
                    .font(AppFont.tabletH1Medium)
                    .foregroundColor(AppColors.textPrimary)
            }

            Spacer()

            // 返回按钮
            Button {
                dismiss()
            } label: {
                Text("Back")
                    .font(AppFont.tabletH3Medium)
                    .foregroundColor(AppColors.textPrimary)
                    .padding(.horizontal, Spacing.lg)
                    .padding(.vertical, Spacing.sm)
                    .background(AppColors.inputBg)
                    .clipShape(RoundedRectangle(cornerRadius: AppRadius.Tablet.lg))
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, Spacing.lg)
        .padding(.vertical, Spacing.md)
        .background(AppColors.pageBgDeep.opacity(0.5))
    }

    // MARK: - 内容区域（根据步骤切换）

    @ViewBuilder
    private var contentArea: some View {
        switch viewModel.currentStep {
        case .faceIDScanning, .faceIDRecognizing, .faceIDFailed:
            // 面部识别相关页面
            CashierFaceIDView(viewModel: viewModel)

        case .passwordEntry:
            // 密码输入页面
            CashierPasswordView(viewModel: viewModel)

        case .signedInSuccess(let session):
            // 登录成功展示页面
            CashierSuccessView(session: session) {
                viewModel.proceedToStartAmount()
            }

        case .startAmount:
            // 开班金额设置页面
            CashierStartAmountView(viewModel: viewModel)
        }
    }
}

// MARK: - Preview

#Preview("面部识别扫描") {
    CashierInView(viewModel: .preview(step: .faceIDScanning))
}

#Preview("密码输入") {
    CashierInView(viewModel: .preview(step: .passwordEntry))
}

#Preview("登录成功") {
    CashierInView(viewModel: .preview(step: .signedInSuccess(.preview)))
}

#Preview("开班金额") {
    CashierInView(viewModel: .preview(step: .startAmount(.preview)))
}
