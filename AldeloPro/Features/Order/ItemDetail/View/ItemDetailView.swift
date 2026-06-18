//
//  ItemDetailView.swift
//  AldeloPro
//
//  Created by Sen on 2026/06/10.
//

import SwiftUI

// MARK: - 餐品详情容器视图

/// 顶级入口容器：根据设备环境自动分流渲染模式
/// - iPad (Regular Width)：半透明遮罩 + 居中浮动白卡片弹窗
/// - iPhone (Compact Width)：原生 NavigationStack 全屏压栈
struct ItemDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    /// 餐品详情 ViewModel（由父级注入）
    @State private var viewModel: ItemDetailViewModel

    init(viewModel: ItemDetailViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    /// 判断当前是否为 iPad 宽屏环境
    private var isPad: Bool {
        horizontalSizeClass == .regular
    }

    var body: some View {
        if isPad {
            iPadModalLayout
        } else {
            iPhoneFullScreenLayout
        }
    }

    // MARK: - iPad 模态弹窗布局

    /// iPad 端：全屏半透明遮罩 + 居中最大宽度 820pt 的白色圆角卡片
    /// 点击遮罩区域或卡片内关闭按钮触发 dismiss
    private var iPadModalLayout: some View {
        ZStack {
            // 半透明黑色调暗遮罩层
            AppColors.black40
                .ignoresSafeArea()
                .onTapGesture { dismiss() }

            // 居中浮动详情卡片
            ItemDetailMainView(viewModel: viewModel, isPad: true, onDismiss: { dismiss() })
                .background(AppColors.card)
                .clipShape(RoundedRectangle(cornerRadius: AppRadius.Tablet.lg))
                .frame(maxWidth: 820)
                .frame(maxHeight: UIScreen.main.bounds.height * 0.85)
        }
    }

    // MARK: - iPhone 全屏布局

    /// iPhone 端：剥离遮罩，全屏填满，依赖系统 NavigationStack 返回手势
    private var iPhoneFullScreenLayout: some View {
        ItemDetailMainView(viewModel: viewModel, isPad: false, onDismiss: nil)
            .background(AppColors.card)
            .navigationBarBackButtonHidden(false)
            .toolbar(.hidden, for: .navigationBar)
    }
}

// MARK: - Preview 预览

#Preview("iPad - 多图画廊版式 (图96)") {
    ItemDetailView(viewModel: .previewWithMultipleImages())
        .environment(\.horizontalSizeClass, .regular)
}

#Preview("iPad - 单图大图版式 (图97)") {
    ItemDetailView(viewModel: .previewWithSingleImage())
        .environment(\.horizontalSizeClass, .regular)
}

#Preview("iPhone 竖屏 - 暗色模式") {
    NavigationStack {
        ItemDetailView(viewModel: .previewWithMultipleImages())
    }
    .preferredColorScheme(.dark)
    .environment(\.horizontalSizeClass, .compact)
}
