//
//  OverlaySelectField.swift
//  AldeloPro
//
//  Created by wanghui on 2026/06/15.
//

import SwiftUI

// MARK: - OverlaySelectField

/// 单选下拉选择框（泛型，overlay 浮层样式）。
///
/// 提取自 `AddItemView.taxClassField` 的视觉/交互，做成通用组件：
/// - chevron 触发按钮显示当前选中项；点击展开/收起
/// - 选项列表用 `.overlay(alignment: .top)` + `.offset` 浮在内容之上，**不撑开布局**
/// - 单选，选中即收起；选项之间用 `Divider` 分隔；展开时触发按钮蓝色描边
/// - 选项超过 `maxVisibleOptions` 时浮层内部滚动；整行可点
/// - 点击浮层外部收起（展开时铺一层全屏透明背景接收点击）
///
/// 浮层位于组件自身 `.overlay`，会盖过同一 ScrollView 内的后续兄弟元素
/// （需父级在该字段上加 `.zIndex`）；但不会盖过 ScrollView 之外的元素（如固定底部按钮）。
/// 若靠近滚动区底部，父级 ScrollView 需预留底部 padding 供浮层展开。
///
/// 泛型 `T: Hashable`：可接 enum（`\.rawValue` 作 display）或 `String`（`{ $0 }`）。
///
/// 用法：
/// ```swift
/// OverlaySelectField(
///     title: "City",
///     options: viewModel.cityOptions,
///     selection: $viewModel.city,
///     display: { $0 }
/// )
/// ```
struct OverlaySelectField<T: Hashable>: View {

    // MARK: - Public Properties

    let title: String
    let options: [T]
    @Binding var selection: T
    /// 把选项映射为展示文案（enum 传 `\.rawValue`，String 传 `{ $0 }`）
    var display: (T) -> String
    var placeholder: String = ""
    var isRequired: Bool = false
    /// 控件高度（pt）。不传 → 设备感知默认(48/64)并自动缩放；传值 → 绝对高度，绕过缩放。
    var height: CGFloat? = nil
    /// 下拉浮层最多显示多少个选项的高度，超出则内部滚动（默认 5）
    var maxVisibleOptions: Int = 5
    /// 展开/收起回调（供父级做多字段互斥或滚动定位）
    var onOpenChange: ((Bool) -> Void)? = nil

    // MARK: - Environment

    /// 控件高度缩放因子（大屏 iPad=1.0，其它=0.85；由根视图 `.provideControlHeightScale()` 注入）
    @Environment(\.controlHeightScale) private var controlHeightScale
    /// 设备布局（由根视图 `.provideDeviceLayout()` 注入；默认 iPad 横屏）
    @Environment(\.deviceLayout) private var deviceLayout

    /// 实际渲染高度：
    /// - `height` 传值 → 视为绝对高度，原样使用（逃生舱，绕过缩放）
    /// - `height` 为 nil → 设备感知默认（iPhone 48 / iPad 64）经 `AppControl.height` 自动缩放（含 44pt 兜底）
    private var resolvedHeight: CGFloat {
        if let height { return height }
        let designPx: CGFloat = 64
        return AppControl.height(designPx, scale: controlHeightScale)
    }

    // MARK: - Private State

    @State private var isOpen: Bool = false

    // MARK: - Body

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.xxs) {
            label
            trigger
        }
    }

    // MARK: - Label

    // 与 FormTextField.titleLabel 保持一致：字体 tabletH4Medium、颜色 inputTitle、间距 0
    @ViewBuilder
    private var label: some View {
        HStack(spacing: 0) {
            if isRequired {
                Text("*")
                    .font(AppFont.tabletH4Medium)
                    .foregroundColor(AppColors.errorNormal)
            }
            Text(title)
                .font(AppFont.tabletH4Medium)
                .foregroundColor(AppColors.inputTitle)
        }
    }

    // MARK: - Trigger + Dropdown Overlay

    private var trigger: some View {
        Button {
            setOpen(!isOpen)
        } label: {
            HStack {
                Text(triggerText)
                    .font(AppFont.tabletBody2Regular)
                    .foregroundColor(hasSelection ? AppColors.textPrimary : AppColors.inputPlaceholder)
                Spacer()
                Image(systemName: isOpen ? "chevron.up" : "chevron.down")
                    .foregroundColor(AppColors.textTertiary)
            }
            .frame(height: resolvedHeight)
            .padding(.horizontal, Spacing.md)
            .frame(maxWidth: .infinity)
            .background(AppColors.card)
            .cornerRadius(AppRadius.Tablet.sm)
            .overlay(
                RoundedRectangle(cornerRadius: AppRadius.Tablet.sm)
                    .stroke(isOpen ? AppColors.primaryNormal : Color.clear, lineWidth: 1)
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .background(outsideTapBackdrop)
        .overlay(alignment: .top) {
            if isOpen {
                dropdownList
                    .offset(y: resolvedHeight + Spacing.xxs)
            }
        }
    }

    /// 点击浮层外部收起：展开时铺一层全屏透明背景接收点击。
    /// 放在 trigger 的 `.background`（位于浮层之下），故不挡选项点击。
    @ViewBuilder
    private var outsideTapBackdrop: some View {
        if isOpen {
            Color.clear
                .frame(width: 6000, height: 6000)
                .contentShape(Rectangle())
                .onTapGesture { setOpen(false) }
        }
    }

    private var dropdownList: some View {
        ScrollView {
            VStack(spacing: 0) {
                ForEach(Array(options.enumerated()), id: \.element) { index, option in
                    Button {
                        selection = option
                        setOpen(false)
                    } label: {
                        Text(display(option))
                            .font(AppFont.tabletBody2Regular)
                            .foregroundColor(AppColors.textPrimary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .frame(height: rowHeight)
                            .padding(.horizontal, Spacing.md)
                            .contentShape(Rectangle())   // 整行可点
                    }
                    .buttonStyle(.plain)

                    if index < options.count - 1 {
                        Divider()
                            .background(AppColors.line)
                            .padding(.horizontal, Spacing.md)
                    }
                }
            }
        }
        .frame(height: dropdownHeight)
        .frame(maxWidth: .infinity)              // 浮层宽度撑满 trigger（= 字段宽度）
        .background(AppColors.card)
        .cornerRadius(AppRadius.Tablet.sm)
        .shadow(color: AppColors.black8, radius: 8, y: 4)
    }

    // MARK: - Sizing

    private var rowHeight: CGFloat { 44 }

    /// 浮层固定高度：内容实际高度与「最多显示 maxVisibleOptions 项」的较小值。
    /// 用固定 height（非 maxHeight）避免 ScrollView 在 overlay 浮层中塌缩成一行。
    private var dropdownHeight: CGFloat {
        let dividers = CGFloat(max(0, options.count - 1)) * 1
        let contentHeight = rowHeight * CGFloat(options.count) + dividers
        let capHeight = rowHeight * CGFloat(maxVisibleOptions)
        return min(contentHeight, capHeight)
    }

    // MARK: - Helpers

    private var hasSelection: Bool { options.contains(selection) }
    private var triggerText: String { hasSelection ? display(selection) : placeholder }

    private func setOpen(_ open: Bool) {
        guard open != isOpen else { return }
        isOpen = open
        onOpenChange?(open)
    }
}

// MARK: - Preview

#Preview {
    struct Demo: View {
        @State private var city = "Pleasanton"
        var body: some View {
            VStack(alignment: .leading) {
                HStack(alignment: .top, spacing: 16) {
                    OverlaySelectField(
                        title: "City",
                        options: ["Pleasanton", "San Francisco", "San Jose", "Oakland", "Fremont", "Hayward", "Berkeley"],
                        selection: $city,
                        display: { $0 },
                        placeholder: "Select city",
                        isRequired: true
                    )
                    .zIndex(1)
                    Color.clear.frame(maxWidth: .infinity)
                }
                Spacer()
            }
            .padding(Spacing.xl)
            .background(AppColors.pageBg)
        }
    }
    return Demo()
}
