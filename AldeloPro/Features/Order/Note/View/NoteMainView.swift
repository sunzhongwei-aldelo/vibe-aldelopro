//
//  NoteMainView.swift
//  AldeloPro
//
//  Created by Sen on 2026/06/10.
//

import SwiftUI
import UIKit

// MARK: - 商品备注主视图

/// 商品备注微件的统一入口视图
/// - iPad：全屏半透明遮罩 + 居中白色弹窗卡片（最大 540×480pt）
/// - iPhone：同样居中弹窗，随屏幕收缩留边
/// 卡片采用「固定头部 + 可滚动主体 + 固定底部动作栏」结构：
/// 键盘弹出、可用高度不足时，中间主体内部滚动，标题与动作栏始终可见，绝不被裁切。
/// 支持「编辑回显」（传入已有备注/数量）与「键盘弹出自动上移避让」
struct NoteMainView: View {
    /// 商品名称（显示在标题栏，如 "Cocktail"）
    let itemName: String
    /// 确认回调（返回备注文本和数量）
    var onConfirm: ((String, Int) -> Void)?
    /// 取消/关闭回调
    var onDismiss: (() -> Void)?

    private let isPad = UIDevice.current.userInterfaceIdiom == .pad
    @State private var viewModel: NoteViewModel
    /// 当前键盘高度（0 表示未弹出），驱动卡片高度收缩与上移避让
    @State private var keyboardHeight: CGFloat = 0

    // MARK: - 布局常量

    /// 卡片设计上限尺寸
    private let maxCardWidth: CGFloat = 540 * 1.05
    private let maxCardHeight: CGFloat = 480 * 1.05
    /// 键盘弹出时卡片顶部距屏幕顶的留白
    private let topInset: CGFloat = Spacing.md
    /// 键盘弹出时卡片底部距键盘顶的间隙
    private let keyboardGap: CGFloat = Spacing.md
    /// 卡片内容 frame 之外额外的上下 padding（见 body）
    private var outerVerticalPadding: CGFloat { Spacing.lg }

    // MARK: - 初始化

    /// - Parameters:
    ///   - itemName: 商品名称（标题栏显示 "\(itemName) Notes"）
    ///   - existingNote: 已有备注文本，编辑场景回显（默认空，显示占位符）
    ///   - existingQuantity: 已有套用数量（默认 5）
    ///   - quickChips: 快捷标签选项
    ///   - onConfirm: 确认回调（备注文本、套用数量）
    ///   - onDismiss: 取消/关闭回调
    init(
        itemName: String,
        existingNote: String = "",
        existingQuantity: Int? = nil,
        quickChips: [String] = ["No Cilantro", "Don't Add Chili Peppers", "Add More Sugar"],
        onConfirm: ((String, Int) -> Void)? = nil,
        onDismiss: (() -> Void)? = nil
    ) {
        self.itemName = itemName
        self.onConfirm = onConfirm
        self.onDismiss = onDismiss
        self._viewModel = State(initialValue: NoteViewModel(
            initialNote: existingNote,
            initialQuantity: existingQuantity,
            quickChips: quickChips
        ))
    }

    var body: some View {
        GeometryReader { geo in
            let size = cardSize(in: geo)
            ZStack {
                // 全屏半透明黑色遮罩
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .onTapGesture { handleBackdropTap() }

                // 居中悬浮白色模态卡片
                cardContent
                    .frame(width: size.width, height: size.height)
                    .padding(.vertical, outerVerticalPadding)
                    .background(AppColors.card)
                    .clipShape(RoundedRectangle(cornerRadius: isPad ? AppRadius.Tablet.lg : AppRadius.Mobile.lg))
                    .shadow(color: .black.opacity(0.12), radius: 24, x: 0, y: 8)
                    .offset(y: cardOffsetY(in: geo))
                    .animation(.easeOut(duration: 0.25), value: keyboardHeight)
            }
        }
        .ignoresSafeArea()
        // 监听键盘弹起/收起，记录高度用于卡片避让
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)) { note in
            if let frame = note.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
                keyboardHeight = frame.height
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)) { _ in
            keyboardHeight = 0
        }
    }

    // MARK: - 卡片尺寸 / 键盘避让

    /// 计算卡片内容 frame 高度（不含 body 外层的 outerVerticalPadding）。
    /// 键盘弹出时，收缩到「键盘上方可用空间」内；由于主体可滚动，
    /// 即使收缩到很小，头部标题与底部动作栏也始终完整可见。
    private func cardSize(in geo: GeometryProxy) -> CGSize {
        let width = min(maxCardWidth, geo.size.width - Spacing.xl)
        let height: CGFloat
        if keyboardHeight > 0 {
            // 视觉卡片（含白底）可占的最大高度：屏幕顶留白 ~ 键盘顶上方间隙
            let maxVisual = geo.size.height - keyboardHeight - topInset - keyboardGap
            // 减去 body 外层上下 padding，换算成内容 frame 高度
            let contentMax = maxVisual - outerVerticalPadding * 2
            height = min(maxCardHeight, max(0, contentMax))
        } else {
            height = min(maxCardHeight, geo.size.height - 80)
        }
        return CGSize(width: width, height: height)
    }

    /// 键盘弹出时，将居中卡片上移，使其顶边对齐到 `topInset`（只上移、不下移）。
    /// 配合 cardSize 的高度收缩，卡片完整落在键盘上方，顶部标题始终可见。
    private func cardOffsetY(in geo: GeometryProxy) -> CGFloat {
        guard keyboardHeight > 0 else { return 0 }
        // 视觉卡片高度 = 内容 frame 高 + 外层上下 padding
        let visualHeight = cardSize(in: geo).height + outerVerticalPadding * 2
        let centeredTop = (geo.size.height - visualHeight) / 2
        // 居中状态下卡片顶若已在 topInset 之下，则上移补足差值
        return min(0, topInset - centeredTop)
    }

    // MARK: - 交互

    /// 点击遮罩：键盘开启时先收起键盘，否则关闭弹窗
    private func handleBackdropTap() {
        if keyboardHeight > 0 {
            dismissKeyboard()
        } else {
            onDismiss?()
        }
    }

    /// 主动收起键盘
    private func dismissKeyboard() {
        UIApplication.shared.sendAction(
            #selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil
        )
    }

    // MARK: - 卡片内容（固定头部 + 可滚动主体 + 固定底部）

    /// 头部与底部动作栏固定，中间主体在空间不足时内部滚动
    private var cardContent: some View {
        VStack(alignment: .leading, spacing: 0) {
            // 1. 固定头部标题行（始终可见，不随键盘滚动）
            headerRow
                .padding(.bottom, Spacing.lg)

            // 2. 可滚动主体：文本域 + 快捷标签 + 数量步进器
            //    空间不足（键盘弹出）时内部滚动，保证头部与底部动作栏始终可见
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    // 核心文本域（点击聚焦弹出键盘，锁死高度，灰色背景）
                    NoteTextEditorField(
                        text: $viewModel.noteText,
                        isPad: isPad,
                        isOrder: viewModel.quantity == 0
                    )
                    .padding(.bottom, Spacing.lg)

                    // 快捷标签流式折行矩阵
                    QuickChipsFlowLayout(
                        chips: viewModel.quickChips,
                        isPad: isPad,
                        onChipTap: { viewModel.appendChip($0) }
                    )
                    .padding(.bottom, Spacing.lg)

                    if viewModel.quantity > 0 {
                        // 数量步进器
                        NoteQuantityStepper(
                            quantity: $viewModel.quantity,
                            isPad: isPad,
                            maximum:viewModel.quantity
                        )
                    }
                }
            }
            .frame(maxHeight: .infinity)
            .scrollBounceBehavior(.basedOnSize)

            // 3. 固定底部分割线 + 动作栏（始终可见）
            Divider().overlay(AppColors.line)
                .padding(.top, Spacing.lg)
                .padding(.bottom, Spacing.md)

            actionBar
        }
        // 四周留出充足边距，确保内容与卡片边缘有明显间隔
        .padding(.horizontal, Spacing.xl)
        .padding(.vertical, Spacing.xl)
    }

    // MARK: - 头部标题行

    /// 左侧 "Cocktail Notes"，右侧 X 关闭图标
    private var headerRow: some View {
        HStack {
            Text("\(itemName) Notes")
                .font(isPad ? AppFont.tabletH2Medium : AppFont.mobileH2Medium)
                .foregroundStyle(AppColors.textPrimary)
            Spacer()
            Button(action: { onDismiss?() }) {
                Image(systemName: "xmark")
                    .font(.system(size: isPad ? 22 : 18, weight: .semibold))
                    .foregroundStyle(AppColors.textPrimary)
            }
        }
    }

    // MARK: - 底部动作栏

    /// Cancel（白底描边胶囊）+ Confirm（蓝底白字胶囊）
    private var actionBar: some View {
        HStack(spacing: Spacing.md) {
            // Cancel 按钮
            Button(action: { onDismiss?() }) {
                Text("Cancel")
                    .font(isPad ? AppFont.tabletH3Medium : AppFont.mobileH3Medium)
                    .foregroundStyle(AppColors.textPrimary)
                    .frame(maxWidth: .infinity, minHeight: isPad ? 48 : 40)
                    .background(AppColors.card)
                    .clipShape(Capsule())
                    .overlay(Capsule().stroke(AppColors.line, lineWidth: 1))
            }

            // Confirm 按钮
            Button(action: {
                onConfirm?(viewModel.noteText, viewModel.quantity)
            }) {
                Text("Confirm")
                    .font(isPad ? AppFont.tabletH3Medium : AppFont.mobileH3Medium)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity, minHeight: isPad ? 48 : 40)
                    .background(AppColors.theme)
                    .clipShape(Capsule())
            }
        }
    }

    // MARK: - Preview 工厂方法

    /// 提供 Preview 用的预填实例
    static func previewInstance(itemName: String = "Cocktail") -> NoteMainView {
        NoteMainView(itemName: itemName)
    }
}

// MARK: - Preview

#Preview("iPad - 空备注（新建）") {
    NoteMainView(itemName: "Cocktail")
}

#Preview("iPad - 已有备注（编辑回显）") {
    NoteMainView(
        itemName: "Cocktail",
        existingNote: "No ice, extra sugar please",
        existingQuantity: 3
    )
}

#Preview("Dark Mode - 商品备注") {
    NoteMainView(itemName: "Cocktail")
        .preferredColorScheme(.dark)
}
