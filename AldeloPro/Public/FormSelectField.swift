//
//  FormSelectField.swift
//  AldeloPro
//
//  Created by wanghui on 2026/06/09.
//

import SwiftUI
import UIKit
import Combine

// MARK: - FormSelectField
//
// 表单选择框公共控件（支持单选/多选，Pill 样式）。
//
// 支持 6 种状态：default / focus / selected / completed / error / disabled
// 状态根据 isOpen、selectedOptions、errorMessage、isDisabled 自动推导。
//
// ──────────────────────────────────────────────────────────────────────────
// 下拉面板的收起逻辑（无需业务侧接线，基于 NotificationCenter + window 点击识别器）
// ──────────────────────────────────────────────────────────────────────────
//
// 本组件自带三套协作机制，多个 FormSelectField 之间无需额外代码：
//
// 1. 字段互切（自动，零配置）
//    点击任意 FormSelectField 打开它时，会广播 `didOpenNotification`，
//    其它已展开的字段收到后自动收起 —— 单击即可切换。
//
// 2. 点击空白处 / 其它控件收起（需在页面根部挂一次 `.dropdownHost()`）
//    `.dropdownHost()` 会在所在 window 上安装一个非阻断点击识别器
//    （cancelsTouchesInView = false）。识别器只在点击「落在所有 FormSelectField
//    的触发器 / 展开面板区域之外」时才触发，触发后广播 `dismissAllNotification`
//    收起面板；落在触发器/面板内的点击会被识别器忽略（交给字段自身处理），
//    因此多选点选项、点触发器、字段互切都不会被误收。同一次点击仍会照常
//    传给被点的按钮 / 文本框，不会出现「点两次」。
//
//        var body: some View {
//            ZStack { content }
//                .dropdownHost()   // ← 整个页面挂一次即可
//        }
//
// 3. 点击某个普通按钮时主动收起（可选，`.dismissesDropdown()`）
//    若按钮所在层级没有 `.dropdownHost()`，又希望点它时收起面板，
//    可单独给该按钮加 `.dismissesDropdown()`，按钮自身 action 照常执行：
//
//        Button("Save") { save() }
//            .dismissesDropdown()
//
struct FormSelectField: View {

    // MARK: - Public Properties

    let title: String
    let options: [String]
    @Binding var selectedOptions: [String]
    var placeholder: String = ""
    var isRequired: Bool = false
    var helpText: String? = nil
    var errorMessage: String? = nil
    var isDisabled: Bool = false
    /// 控件高度（pt）。不传 → 设备感知默认(48/64)并自动缩放；传值 → 绝对高度，绕过缩放。
    var height: CGFloat? = nil
    var cornerRadius: CGFloat = AppRadius.Tablet.sm
    var isSingleSelect: Bool = false
    /// 展开/收起回调（供父级 ScrollView 滚动定位用）
    var onOpenChange: ((Bool) -> Void)? = nil

    // MARK: - Environment

    /// 由 `.dropdownHost()` 注入；用于把触发器/面板区域登记到 window 识别器，
    /// 使「点击区域外才收起」生效。未挂 `.dropdownHost()` 时为 nil（点空白不收，但其余功能正常）。
    @Environment(\.dropdownDismissRegistry) private var dismissRegistry
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
    /// 本实例唯一标识，用于字段互切时区分 “是不是我自己打开的”
    @State private var instanceID = UUID()

    // MARK: - Notifications

    /// 某个 FormSelectField 展开时广播（object = 该实例的 instanceID）
    static let didOpenNotification = Notification.Name("FormSelectField.didOpen")
    /// 请求收起所有展开中的 FormSelectField（由 `.dropdownHost()` / `.dismissesDropdown()` 广播）
    static let dismissAllNotification = Notification.Name("FormSelectField.dismissAll")

    // MARK: - Computed State

    private var fieldState: SelectFieldState {
        if isDisabled { return .disabled }
        if errorMessage != nil { return .error }
        if isOpen && selectedOptions.isEmpty { return .focus }
        if isOpen && selectedOptions.isEmpty == false { return .selected }
        if isOpen == false && selectedOptions.isEmpty == false { return .completed }
        return .default
    }

    // MARK: - Body

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.xxs) {
            titleLabel
            selectBox
            bottomText
        }
        .zIndex(isOpen ? 100 : 0)
        .onChange(of: isOpen) { _, newValue in
            onOpenChange?(newValue)
            if newValue {
                // 展开：登记到计数 + 通知其它字段收起（字段互切）
                dismissRegistry?.incrementOpen()
                NotificationCenter.default.post(
                    name: FormSelectField.didOpenNotification,
                    object: instanceID
                )
            } else {
                dismissRegistry?.decrementOpen()
            }
        }
        // 其它字段展开 → 收起自己
        .onReceive(NotificationCenter.default.publisher(for: FormSelectField.didOpenNotification)) { note in
            if (note.object as? UUID) != instanceID, isOpen {
                isOpen = false
            }
        }
        // 点击区域外（由 window 识别器判定）→ 收起
        .onReceive(NotificationCenter.default.publisher(for: FormSelectField.dismissAllNotification)) { _ in
            if isOpen { isOpen = false }
        }
        // 键盘弹出 → 收起面板
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)) { _ in
            if isOpen { isOpen = false }
        }
    }

    // MARK: - Title Label

    private var titleLabel: some View {
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

    // MARK: - Select Box

    private var selectBox: some View {
        selectTrigger
            .overlay(alignment: .topLeading) {
                if isOpen {
                    dropdownPanel
                        .offset(y: resolvedHeight + Spacing.xs)
                }
            }
            .zIndex(1)
    }

    // MARK: - Select Trigger (Input Area)

    private var selectTrigger: some View {
        HStack(spacing: Spacing.xs) {
            if selectedOptions.isEmpty {
                Text(placeholder)
                    .font(AppFont.tabletBody2Regular)
                    .foregroundColor(AppColors.inputPlaceholder)
            } else {
                selectedTags
            }

            Spacer()

            arrowIcon
        }
        .padding(.horizontal, Spacing.md)
        .frame(height: resolvedHeight)
        .background(backgroundColor)
        // 把触发器区域登记给 window 识别器：点这里不触发“区域外收起”
        .background(DropdownRegionMarker(registry: dismissRegistry))
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
        .overlay(
            RoundedRectangle(cornerRadius: cornerRadius)
                .stroke(borderColor, lineWidth: hasBorder ? 1 : 0)
        )
        .contentShape(Rectangle())
        .onTapGesture {
            guard isDisabled == false else { return }
            if isOpen {
                isOpen = false
            } else {
                FormSelectField.dismissKeyboard()
                isOpen = true
            }
        }
    }

    // MARK: - Selected Tags

    private var selectedTags: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: Spacing.xs) {
                    ForEach(selectedOptions, id: \.self) { option in
                        tagView(for: option)
                            .id(option)
                    }
                }
            }
            .onChange(of: selectedOptions) { oldValue, newValue in
                scrollToChangedTag(old: oldValue, new: newValue, proxy: proxy)
            }
        }
    }

    private func tagView(for option: String) -> some View {
        HStack(spacing: Spacing.xxs) {
            Text(option)
                .font(AppFont.tabletBody2Regular)
                .foregroundColor(AppColors.inputText)

            if isDisabled == false, isSingleSelect == false {
                Button {
                    removeOption(option)
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(AppColors.inputPlaceholder)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, Spacing.xs)
        .padding(.vertical, 5)
        .background(tagBackground)
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.Tablet.xs))
    }

    // MARK: - Arrow Icon

    private var arrowIcon: some View {
        Image(systemName: isOpen ? "chevron.up" : "chevron.down")
            .font(.system(size: 12, weight: .medium))
            .foregroundColor(AppColors.textSecondary)
    }

    // MARK: - Dropdown Panel

    private var dropdownPanel: some View {
        DropdownFlowLayout(spacing: Spacing.xs) {
            ForEach(options, id: \.self) { option in
                optionPill(for: option)
            }
        }
        .padding(.horizontal, Spacing.lg)
        .padding(.vertical, Spacing.lg)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppColors.inputBg)
        // 把面板区域登记给 window 识别器：点面板内（含选项）不触发“区域外收起”，多选保持展开
        .background(DropdownRegionMarker(registry: dismissRegistry))
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
        .shadow(color: AppColors.black8, radius: 8, x: 0, y: 4)
    }

    // MARK: - Option Pill

    private func optionPill(for option: String) -> some View {
        let isSelected = selectedOptions.contains(option)
        return Button {
            toggleOption(option)
        } label: {
            Text(option)
                .font(AppFont.tabletBody2Regular)
                .foregroundColor(isSelected ? AppColors.inputText : AppColors.inputText)
                .padding(.horizontal, Spacing.lg)
                .frame(height: 45)
                .background(isSelected ? AppColors.optionSelectedFill : AppColors.optionUnselectedFill)
                .clipShape(RoundedRectangle(cornerRadius: AppRadius.Tablet.sm))
                .overlay(
                    RoundedRectangle(cornerRadius: AppRadius.Tablet.sm)
                        .stroke(
                            isSelected ? AppColors.optionSelectedStroke : AppColors.optionUnselectedStroke,
                            lineWidth: 1
                        )
                )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Bottom Text

    @ViewBuilder
    private var bottomText: some View {
        if fieldState == .error, let error = errorMessage {
            Text(error)
                .font(AppFont.tabletH4Medium)
                .foregroundColor(AppColors.errorNormal)
        } else if let help = helpText {
            Text(help)
                .font(AppFont.tabletH4Medium)
                .foregroundColor(AppColors.inputPlaceholder)
        }
    }

    // MARK: - Style Helpers

    private var backgroundColor: Color {
        switch fieldState {
        case .disabled:
            return AppColors.inputDisabledBg
        default:
            return AppColors.inputBg
        }
    }

    private var borderColor: Color {
        switch fieldState {
        case .focus, .selected:
            return AppColors.inputFocusBorder
        case .error:
            return AppColors.inputErrorBorder
        default:
            return .clear
        }
    }

    private var hasBorder: Bool {
        switch fieldState {
        case .focus, .selected, .error:
            return true
        default:
            return false
        }
    }

    private var tagBackground: Color {
        if isSingleSelect {
            return Color.clear
        }
        if isDisabled {
            return AppColors.black8
        }
        return AppColors.inputDisabledBg
    }

    // MARK: - Actions

    private func toggleOption(_ option: String) {
        if isSingleSelect {
            if selectedOptions.contains(option) {
                selectedOptions = []
            } else {
                selectedOptions = [option]
            }
            isOpen = false
        } else {
            if let index = selectedOptions.firstIndex(of: option) {
                var updated = selectedOptions
                updated.remove(at: index)
                selectedOptions = updated
            } else {
                selectedOptions = selectedOptions + [option]
            }
        }
    }

    private func removeOption(_ option: String) {
        if let index = selectedOptions.firstIndex(of: option) {
            var updated = selectedOptions
            updated.remove(at: index)
            selectedOptions = updated
        }
    }

    /// 选中标签变化时，把横向标签栏滚动到新增/删除的位置，让用户看到变化
    private func scrollToChangedTag(old: [String], new: [String], proxy: ScrollViewProxy) {
        if new.count > old.count {
            // 新增：滚动到新加入的标签
            if let added = new.first(where: { old.contains($0) == false }) {
                withAnimation(.easeInOut(duration: 0.25)) {
                    proxy.scrollTo(added, anchor: .trailing)
                }
            }
        } else if new.count < old.count, new.isEmpty == false {
            // 删除：滚动到原删除位置现在所占的标签（越界则取末尾）
            if let removedIndex = old.firstIndex(where: { new.contains($0) == false }) {
                let targetIndex = min(removedIndex, new.count - 1)
                let target = new[targetIndex]
                withAnimation(.easeInOut(duration: 0.25)) {
                    proxy.scrollTo(target, anchor: .trailing)
                }
            }
        }
    }

    // MARK: - Keyboard

    static func dismissKeyboard() {
        UIApplication.shared.sendAction(
            #selector(UIResponder.resignFirstResponder),
            to: nil,
            from: nil,
            for: nil
        )
    }
}

// MARK: - SelectFieldState

private enum SelectFieldState {
    case `default`
    case focus
    case selected
    case completed
    case error
    case disabled
}

// MARK: - Dropdown Dismiss Modifiers

extension View {

    /// 在页面根部挂一次。会在所在 window 上安装一个非阻断点击识别器：
    /// 点击「落在所有 FormSelectField 触发器 / 展开面板之外」时收起面板，
    /// 点击区域内（触发器、选项、删除标签）则交给字段自身处理，不会误收；
    /// 被点的普通控件（按钮 / 文本框）仍能正常响应同一次点击。
    ///
    ///     var body: some View {
    ///         ZStack { content }
    ///             .dropdownHost()
    ///     }
    func dropdownHost() -> some View {
        modifier(DropdownHostModifier())
    }

    /// 给某个按钮加上后，点击它时主动请求收起所有展开中的下拉面板。
    /// 适用于该按钮所在层级没有 `.dropdownHost()`、又希望点它顺带收起的场景；
    /// 按钮自身的 action 照常执行。
    ///
    ///     Button("Save") { save() }
    ///         .dismissesDropdown()
    func dismissesDropdown() -> some View {
        simultaneousGesture(
            TapGesture().onEnded {
                NotificationCenter.default.post(
                    name: FormSelectField.dismissAllNotification,
                    object: nil
                )
            }
        )
    }
}

// MARK: - Dropdown Dismiss Registry

/// 收集当前页面内所有 FormSelectField 的「触发器 / 面板」标记视图（弱引用）。
/// window 识别器在点击时即时计算这些视图的实时 window frame 来判断点击是否落在区域内，
/// 因此天然反映 `.offset` 等渲染位移，且不依赖触发时序。
final class DropdownDismissRegistry {
    private let markers = NSHashTable<UIView>.weakObjects()
    weak var window: UIWindow?
    /// 当前展开中的 FormSelectField 数量；为 0 时 window 识别器直接不参与判断（省去无谓遍历/广播）
    private(set) var openCount = 0

    func register(_ view: UIView) {
        markers.add(view)
    }

    func incrementOpen() { openCount += 1 }
    func decrementOpen() { openCount = max(0, openCount - 1) }

    /// 判断 window 坐标下的点是否落在任一已登记区域内
    func contains(_ point: CGPoint, in window: UIWindow) -> Bool {
        for view in markers.allObjects {
            guard view.window === window else { continue }
            if view.convert(view.bounds, to: window).contains(point) {
                return true
            }
        }
        return false
    }
}

// MARK: - DropdownDismissRegistry Environment

private struct DropdownDismissRegistryKey: EnvironmentKey {
    static let defaultValue: DropdownDismissRegistry? = nil
}

extension EnvironmentValues {
    /// 内部使用：由 `.dropdownHost()` 注入，业务侧无需直接接触
    var dropdownDismissRegistry: DropdownDismissRegistry? {
        get { self[DropdownDismissRegistryKey.self] }
        set { self[DropdownDismissRegistryKey.self] = newValue }
    }
}

// MARK: - DropdownHostModifier

/// `.dropdownHost()` 的实现：创建并向下注入 Registry，同时安装 window 识别器
private struct DropdownHostModifier: ViewModifier {
    @State private var registry = DropdownDismissRegistry()

    func body(content: Content) -> some View {
        content
            .environment(\.dropdownDismissRegistry, registry)
            .background(DropdownWindowTapInstaller(registry: registry))
    }
}

// MARK: - DropdownRegionMarker (区域标记)

/// 透明、不可交互的标记视图，作为触发器 / 面板的 `.background` 注入；
/// 仅用于把自身（及其实时 window frame）登记到 Registry，不影响布局与命中。
private struct DropdownRegionMarker: UIViewRepresentable {
    let registry: DropdownDismissRegistry?

    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        view.backgroundColor = .clear
        view.isUserInteractionEnabled = false
        registry?.register(view)
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        registry?.register(uiView)
    }
}

// MARK: - DropdownWindowTapInstaller (window 非阻断点击识别器)

/// 在所在 window 上安装一个非阻断点击识别器：
/// `cancelsTouchesInView = false` 保证被点控件照常响应；
/// 仅当点击落在所有已登记区域之外时才识别 → 广播 dismissAll。
private struct DropdownWindowTapInstaller: UIViewRepresentable {
    let registry: DropdownDismissRegistry

    func makeCoordinator() -> Coordinator { Coordinator(registry: registry) }

    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        view.backgroundColor = .clear
        view.isUserInteractionEnabled = false
        context.coordinator.install(from: view)
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        context.coordinator.install(from: uiView)
    }

    /// 视图销毁时移除 window 上的识别器，避免页面反复 present 时在共享 window 上累积
    static func dismantleUIView(_ uiView: UIView, coordinator: Coordinator) {
        coordinator.uninstall()
    }

    final class Coordinator: NSObject, UIGestureRecognizerDelegate {
        private let registry: DropdownDismissRegistry
        private weak var installedTap: UITapGestureRecognizer?

        init(registry: DropdownDismissRegistry) {
            self.registry = registry
        }

        func uninstall() {
            if let tap = installedTap {
                tap.view?.removeGestureRecognizer(tap)
            }
            installedTap = nil
        }

        /// window 需在 layout 后才可用，延迟到下一个 runloop 再安装（只装一次）
        func install(from view: UIView) {
            DispatchQueue.main.async { [weak self, weak view] in
                guard let self,
                      let window = view?.window,
                      self.installedTap == nil else { return }
                self.registry.window = window
                let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap))
                tap.cancelsTouchesInView = false
                tap.delaysTouchesBegan = false
                tap.delaysTouchesEnded = false
                tap.delegate = self
                window.addGestureRecognizer(tap)
                self.installedTap = tap
            }
        }

        @objc private func handleTap() {
            NotificationCenter.default.post(
                name: FormSelectField.dismissAllNotification,
                object: nil
            )
        }

        // 点击落在任一登记区域内 → 不识别（交给字段/控件自身处理）
        func gestureRecognizer(
            _ gestureRecognizer: UIGestureRecognizer,
            shouldReceive touch: UITouch
        ) -> Bool {
            // 没有任何面板展开 → 识别器完全不参与（点按 window 任意处都不触发）
            guard registry.openCount > 0 else { return false }
            guard let window = registry.window else { return false }
            let point = touch.location(in: window)
            return registry.contains(point, in: window) == false
        }

        // 与其它手势并存，不抢占
        func gestureRecognizer(
            _ gestureRecognizer: UIGestureRecognizer,
            shouldRecognizeSimultaneouslyWith other: UIGestureRecognizer
        ) -> Bool {
            true
        }
    }
}

// MARK: - DropdownFlowLayout (waterfall wrap)

private struct DropdownFlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = arrange(in: proposal.width ?? .infinity, subviews: subviews)
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = arrange(in: bounds.width, subviews: subviews)
        for (index, position) in result.positions.enumerated() {
            subviews[index].place(
                at: CGPoint(x: bounds.minX + position.x, y: bounds.minY + position.y),
                proposal: .unspecified
            )
        }
    }

    private func arrange(in maxWidth: CGFloat, subviews: Subviews) -> ArrangeResult {
        var positions: [CGPoint] = []
        var currentX: CGFloat = 0
        var currentY: CGFloat = 0
        var lineHeight: CGFloat = 0
        var totalWidth: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)

            if currentX + size.width > maxWidth, currentX > 0 {
                currentX = 0
                currentY += lineHeight + spacing
                lineHeight = 0
            }

            positions.append(CGPoint(x: currentX, y: currentY))
            lineHeight = max(lineHeight, size.height)
            currentX += size.width + spacing
            totalWidth = max(totalWidth, currentX - spacing)
        }

        return ArrangeResult(
            size: CGSize(width: totalWidth, height: currentY + lineHeight),
            positions: positions
        )
    }

    private struct ArrangeResult {
        let size: CGSize
        let positions: [CGPoint]
    }
}

// MARK: - Preview

#Preview("FormSelectField") {
    VStack(spacing: Spacing.lg) {
        FormSelectField(
            title: "Job Title",
            options: ["Manager", "Server", "Chef", "Host"],
            selectedOptions: .constant(["Manager"]),
            placeholder: "Select one",
            isSingleSelect: true
        )

        FormSelectField(
            title: "POS Accessibilities",
            options: ["Driver", "Cashier", "Hostess", "Waiter", "Owner"],
            selectedOptions: .constant(["Driver", "Waiter"]),
            placeholder: "Example",
            isRequired: true
        )
    }
    .padding(Spacing.lg)
    .background(AppColors.pageBg)
    .dropdownHost()
}
