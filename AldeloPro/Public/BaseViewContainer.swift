//
//  BaseView.swift
//  AldeloPro
//
//  Created by 孙仲伟 on 6/7/26.
//

import SwiftUI

//struct BaseView: View {
//    @State private var coverManager = FullScreenCoverManager()
//    var body: some View {
//        ZStack {
//            // 正常的业务根视图，里面包含极其复杂的层级
//            CashierBaseView()
//                .environment(coverManager) // 注入环境
//            
//            // 【核心】在这里实现真正的全局自定义全屏转场
//            if coverManager.isPresented {
//                Color.black.opacity(0.4)
//                    .ignoresSafeArea()
//                    .onTapGesture { coverManager.dismiss() }
//                                
//                coverManager.content
//                // 在这里自由定制你需要的任何高级转场
//                    .transition(.asymmetric(
//                        insertion: .opacity.combined(with: .scale(scale: 0.9)).combined(with: .offset(y: 30)),
//                        removal: .opacity.combined(with: .scale(scale: 0.95))
//                    ))
//                // 确保全屏内容顶上去，不被下面的手势干扰
//                    .zIndex(10)
//            }
//        }
//    }
//}
//
//
//@Observable class FullScreenCoverManager {
//    var isPresented: Bool = false
//    var content: AnyView = AnyView(EmptyView())
//    
//    func present<V: View>(@ViewBuilder _ view: () -> V) {
//        self.content = AnyView(view())
//        withAnimation(.spring(response: 0.45, dampingFraction: 0.82)) {
//            self.isPresented = true
//        }
//    }
//    
//    func dismiss() {
//        withAnimation(.easeOut(duration: 0.2)) {
//            self.isPresented = false
//        }
//    }
//}



import SwiftUI
import UIKit

struct BaseViewContainer<Content: View>: View {
    @State private var uiManager = AppUIManager()
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        ZStack {
            // 图层 0：业务根图层
            content
                .environment(uiManager)
                // 注入 \.alert 环境入口：任意 View 可 @Environment(\.alert) 后一行调用弹窗
                .environment(\.alert, AlertPresenter(manager: uiManager))
            
            // 图层 10：自定义全屏 Cover (zIndex: 10)
            if uiManager.isCoverPresented {
                
                // 1. 遮罩层：只做纯粹的渐显渐隐
                AppColors.mask
                    .ignoresSafeArea()
                    .onTapGesture {
                        uiManager.dismissCover()
                        uiManager.coverDismissed?()
                    }
                    .transition(.opacity) // 明确指定遮罩只做淡入淡出
                    .zIndex(10)           // 赋予明确的层级
                
                // 2. 内容层：完美触发你的自定义复合转场
                uiManager.coverContent
                    .transition(.asymmetric(
                        insertion: .opacity
                            .combined(with: .scale(scale: 0.95))
                            .combined(with: .offset(y: 30)),
                        removal: .opacity
                            .combined(with: .scale(scale: 0.95))
                    ))
                    .zIndex(11)           // 确保内容永远盖在遮罩上方
                    .environment(uiManager)
                
            }
            
            // 图层 20：自定义 Alert 弹窗 (zIndex: 20)
            if uiManager.isAlertPresented {
                ZStack {
                    AppColors.mask
                        .ignoresSafeArea()
                    
                    uiManager.alertContent
                }
                .zIndex(20)
                .transition(.opacity)
            }
            
            // 图层 25：轻量级自动消失 Toast（非阻断浮层，zIndex: 25）
            if uiManager.isToastPresented, let message = uiManager.toastMessage {
                VStack {
                    Spacer()
                    Text(message)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white)
                        .padding(.horizontal, 18)
                        .padding(.vertical, 12)
                        .background(
                            Capsule()
                                .fill(Color(.systemBackground))
                                .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
                                .environment(\.colorScheme, .dark) // 确保气泡背景无论系统模式都是深色
                        )
                        .padding(.bottom, 60)
                }
                .zIndex(25)
                .transition(.move(edge: .bottom).combined(with: .opacity))
                .allowsHitTesting(false) // 允许手势穿透，不阻断底层操作
            }
            
            // 图层 30：全屏独占式引用计数 Loading (zIndex: 30)
            if uiManager.isLoadingPresented {
                ZStack {
                    AppColors.mask
                        .ignoresSafeArea()
                    
                    VStack(spacing: 14) {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(1.2)
                        
                        Text(uiManager.loadingText)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white)
                    }
                    .padding(24)
                    .background(.ultraThinMaterial)
                    .cornerRadius(16)
                    .environment(\.colorScheme, .dark)
                }
                .zIndex(30)
                .transition(.opacity)
            }

            // 图层 40：底部上滑式日期选择器 (zIndex: 40)
            if uiManager.isDatePickerPresented {
                
                // 上方半透明遮罩，点击关闭
//                Color.white.opacity(0.5)
//                    .background(ignoresSafeAreaEdges: .all)
//                    .zIndex(40)
//                    .onTapGesture { uiManager.dismissDatePicker() }
//                
                // 1. 遮罩层：只做纯粹的渐显渐隐
                Color.white.opacity(0.01)
                    .ignoresSafeArea()
                    .onTapGesture { uiManager.dismissDatePicker() }
                    .zIndex(40)           // 赋予明确的层级
                
                // 底部锚定的选择器内容
                VStack {
                    Spacer()
                    uiManager.datePickerContent
                }
                .ignoresSafeArea(.all, edges: .bottom)
                .zIndex(41)
                .transition(.asymmetric(
                    insertion: .opacity
                        .combined(with: .scale(scale: 0.95))
                        .combined(with: .offset(y: 30)),
                    removal: .opacity
//                        .combined(with: .scale(scale: 0.95))
                ))
            }
        }
    }
}

// MARK: - 触觉反馈类型定义
enum AppHapticType {
    case success, warning, error, lightTap
}

// MARK: - 日期选择器类型
/// `showDatePicker` 通过该枚举区分要弹出的具体 picker，并携带各自的初始值与确认回调。
/// 所有 picker 内部已去掉 @Binding，选中的结果通过对应的 onConfirm 回调返回。
enum AppDatePickerKind {
    /// 单日选择器：确认返回选中的 Date
    case single(initial: Date, onConfirm: (Date) -> Void)
    /// 日期区间选择器：确认返回 (start, end)
    case range(start: Date, end: Date, onConfirm: (Date, Date) -> Void)
    /// Tab 选择器（单日 / 区间二合一）：确认返回统一的 DatePickerResult
    case tab(initialDate: Date, start: Date, end: Date, onConfirm: (DatePickerResult) -> Void)
}

// MARK: - 1. 全局 UI 状态管家
@Observable
@MainActor
class AppUIManager {
    // 1. 自定义全屏 Cover 状态
    var coverContent: AnyView? = nil
    var isCoverPresented: Bool = false
    
    // 2. 自定义 Alert 状态
    var alertContent: AnyView? = nil
    var isAlertPresented: Bool = false
    
    // 3. 引用计数 Loading 状态与动态文本
    private(set) var loadingCount: Int = 0
    var loadingText: String = "Loading..."
    var isLoadingPresented: Bool { loadingCount > 0 }
    
    // 4. 轻量级 Toast 提示状态
    var toastMessage: String? = nil
    var isToastPresented: Bool = false
    private var toastTask: Task<Void, Never>? = nil

    // 5. 日期选择器状态
    var datePickerContent: AnyView? = nil
    var isDatePickerPresented: Bool = false
    
    var coverDismissed: (() -> Void)?
    // MARK: - 触觉反馈核心方法
    func triggerHaptic(_ type: AppHapticType) {
        switch type {
        case .success:
            UINotificationFeedbackGenerator().notificationOccurred(.success)
        case .warning:
            UINotificationFeedbackGenerator().notificationOccurred(.warning)
        case .error:
            UINotificationFeedbackGenerator().notificationOccurred(.error)
        case .lightTap:
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        }
    }
    
    // MARK: - Cover 控制
    func presentCover<V: View>(@ViewBuilder _ content: () -> V) {
        triggerHaptic(.lightTap)
        self.coverContent = AnyView(content())
        withAnimation(.spring(response: 0.45, dampingFraction: 0.82)) {
            self.isCoverPresented = true
        }
    }
    
    func dismissCover() {
        withAnimation(.easeOut(duration: 0.25)) {
            self.isCoverPresented = false
        }
    }
    
    // MARK: - Alert 控制
    func showAlert<V: View>(@ViewBuilder _ content: () -> V) {
        triggerHaptic(.warning)
        self.alertContent = AnyView(content())
        withAnimation(.spring(response: 0.35, dampingFraction: 0.78)) {
            self.isAlertPresented = true
        }
    }
    
    func dismissAlert() {
        withAnimation(.easeOut(duration: 0.2)) {
            self.isAlertPresented = false
        }
    }
    
    /// Convenience: show AldeloAlertView with config and callbacks
    func showAlert(
        config: AldeloAlertConfig,
        onConfirm: (() -> Void)? = nil,
        onCancel: (() -> Void)? = nil
    ) {
        showAlert {
            AldeloAlertView(
                config: config,
                onConfirm: { [weak self] in
                    self?.dismissAlert()
                    onConfirm?()
                },
                onCancel: { [weak self] in
                    self?.dismissAlert()
                    onCancel?()
                }
            )
            .frame(width: 560)
        }
    }
    
    // MARK: - Loading 引用计数控制（支持动态文本更新）
    func showLoading(text: String = "加载中...") {
        self.loadingText = text
        if loadingCount == 0 {
            withAnimation(.easeInOut(duration: 0.2)) {
                loadingCount += 1
            }
        } else {
            loadingCount += 1
        }
    }
    
    func hideLoading() {
        if loadingCount > 0 {
            if loadingCount == 1 {
                withAnimation(.easeInOut(duration: 0.2)) {
                    loadingCount -= 1
                }
            } else {
                loadingCount -= 1
            }
        }
    }
    
    // MARK: - Toast 控制（自动隐藏 + 动态倒计时）
    func showToast(_ message: String, haptic: AppHapticType = .lightTap, duration: TimeInterval = 2.0) {
        triggerHaptic(haptic)
        toastTask?.cancel() // 取消上一次未完成的定时器
        
        self.toastMessage = message
        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            self.isToastPresented = true
        }
        
        // 开启非阻塞计时任务
        toastTask = Task {
            try? await Task.sleep(nanoseconds: UInt64(duration * 1_000_000_000))
            guard !Task.isCancelled else { return }
            
            withAnimation(.easeOut(duration: 0.25)) {
                self.isToastPresented = false
            }
        }
    }

    // MARK: - DatePicker 控制
    /// 在最顶层（底部上滑式）展示日期选择器。通过 `kind` 区分要展示的 picker。
    /// 选中结果通过 kind 自带的 onConfirm 返回；确认后自动收起浮层。
    func showDatePicker(_ kind: AppDatePickerKind) {
        triggerHaptic(.lightTap)
        self.datePickerContent = makeDatePickerView(for: kind)
        withAnimation(.easeInOut(duration: 0.25)) {
            self.isDatePickerPresented = true
        }
    }

    func dismissDatePicker() {
        withAnimation(.easeInOut(duration: 0.25)) {
            self.isDatePickerPresented = false
        }
    }

    /// 根据 kind 构造对应的 picker 视图，并在 onConfirm 中回传结果后收起浮层。
    private func makeDatePickerView(for kind: AppDatePickerKind) -> AnyView {
        switch kind {
        case let .single(initial, onConfirm):
            return AnyView(
                AppSingleDatePicker(
                    initialDate: initial,
                    onConfirm: { [weak self] date in
                        self?.dismissDatePicker()
                        onConfirm(date)
                    },
                    onDismiss: { [weak self] in
                        self?.dismissDatePicker()
                    }
                )
            )
        case let .range(start, end, onConfirm):
            return AnyView(
                AppDateRangePicker(
                    initialStart: start,
                    initialEnd: end,
                    onConfirm: { [weak self] s, e in
                        self?.dismissDatePicker()
                        onConfirm(s, e)
                    },
                    onDismiss: { [weak self] in
                        self?.dismissDatePicker()
                    }
                )
            )
        case let .tab(initialDate, start, end, onConfirm):
            return AnyView(
                AppTabDatePicker(
                    initialDate: initialDate,
                    initialStart: start,
                    initialEnd: end,
                    onConfirm: { [weak self] result in
                        self?.dismissDatePicker()
                        onConfirm(result)
                    },
                    onDismiss: { [weak self] in
                        self?.dismissDatePicker()
                    }
                )
            )
        }
    }
}
