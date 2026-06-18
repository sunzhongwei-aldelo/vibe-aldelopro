//
//  SetupFlowRootView.swift
//  AldeloPro
//
//  Created by wanghui on 2026/06/16.
//

import SwiftUI

// MARK: - SetupFlowRootView

/// 注册引导流程的导航根容器。
///
/// 链路：Registration → BusinessSetup → BasicSetup → MenuSetup
///       → EmployeeSetup → PrinterSetup → Login（终点）。
///
/// 用 `NavigationStack` + 类型化 `NavigationPath` 实现标准 push 导航；
/// 各页跳转闭包在此集中接到 `AppRouter`，是流程内唯一的导航编排点。
/// 各业务页自带顶栏（SetupTopBarView / 自定义），故隐藏系统导航栏。
struct SetupFlowRootView: View {

    @State private var router = AppRouter()

    var body: some View {
        NavigationStack(path: $router.path) {
            RegistrationView(onComplete: { router.push(.businessSetup) })
                .toolbar(.hidden, for: .navigationBar)
                .navigationDestination(for: SetupRoute.self) { route in
                    destination(for: route)
                        .toolbar(.hidden, for: .navigationBar)
                }
        }
    }

    // MARK: - 路由表

    @ViewBuilder
    private func destination(for route: SetupRoute) -> some View {
        switch route {
        case .businessSetup:
            BusinessSetupView(
                onNext: { router.push(.basicSetup) }
            )
        case .basicSetup:
            BasicSetupView(
                onPrevious: { router.pop() },
                onNext: { router.push(.menuSetup) }
            )
        case .menuSetup:
            MenuSetupView(
                onPreviousStep: { router.pop() },
                onSkipStep: { router.push(.employeeSetup) },
                onSaveAndNextStep: { router.push(.employeeSetup) }
            )
        case .employeeSetup:
            EmployeeSetupView(
                onPreviousStep: { router.pop() },
                onSkipStep: { router.push(.printerSetup) },
                onCompleteSetup: { router.push(.printerSetup) }
            )
        case .printerSetup:
            PrinterSetupView(
                onPrevious: { router.pop() },
                onComplete: { router.push(.login) }
            )
        case .login:
            LoginView()
        }
    }
}

// MARK: - Preview

#Preview {
    SetupFlowRootView()
        .provideDeviceLayout()
}
