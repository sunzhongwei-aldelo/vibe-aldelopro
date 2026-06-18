//
//  AppRouter.swift
//  AldeloPro
//
//  Created by wanghui on 2026/06/16.
//

import SwiftUI

// MARK: - SetupRoute

/// 注册引导流程的可达页面（NavigationStack 的栈内目的地）。
/// 起始页 RegistrationView 是 NavigationStack 的根，不在此枚举内。
enum SetupRoute: Hashable {
    case businessSetup
    case basicSetup
    case menuSetup
    case employeeSetup
    case printerSetup
    case login
}

// MARK: - AppRouter

/// 引导流程导航器（Router 模式）。
///
/// 持有 `NavigationPath`，对外暴露 push / pop 语义，供 `SetupFlowRootView`
/// 在 `navigationDestination` 中集中编排页面跳转。各业务页通过注入的闭包
/// 间接调用此处，不直接持有 Router，从而与导航实现解耦。
@Observable
@MainActor
final class AppRouter {

    /// 当前导航栈路径。绑定到 `NavigationStack(path:)`。
    var path = NavigationPath()

    /// 入栈一个目的地（push 动画）。
    func push(_ route: SetupRoute) {
        path.append(route)
    }

    /// 出栈一层（等同系统返回）。空栈时安全忽略。
    func pop() {
        guard path.isEmpty == false else { return }
        path.removeLast()
    }

    /// 清空回到根页面。
    func popToRoot() {
        path = NavigationPath()
    }
}
