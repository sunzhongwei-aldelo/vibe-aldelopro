//
//  AldeloSegment.swift
//  AldeloProject
//
//  Created by Sen on 2026/06/09.
//
//  ============================================================================
//  Aldelo POS 通用分段选择器（Segmented Control）
//  —— 覆盖设计稿全部样式，一个组件搞定，亮/暗色均已校准
//  ============================================================================
//
//  ┌──────────────────────────────────────────────────────────────────────┐
//  │ 🧭 选型速查：我该用哪种？                                                │
//  ├──────────────────────────────────────────────────────────────────────┤
//  │ 想要「灰底 + 白色药丸滑块」的 iOS 原生分段控件观感？                       │
//  │      → style: .filled（默认，可省略）。例：设备类型 / 连接方式 / 时长切换 │
//  │                                                                        │
//  │ 想要「白底描边卡片 + 仅文字变蓝高亮（无药丸）」的轻量观感？                 │
//  │      → style: .bordered。例：Pay Out/Tip out 操作切换、Tab Name/Customer│
//  │                                                                        │
//  │ 选项很少、想铺满整行平均分？      → distribution: .equalWidth（默认）     │
//  │ 选项文字长短不一、想贴合内容宽度？ → distribution: .fit                  │
//  │                                                                        │
//  │ 选项要带图标（如 Passcode/Face ID）？ → 传 iconMapper                    │
//  │ 想换主题色/选中色等任意颜色？          → 传 colors（见 AldeloSegmentColors）│
//  └──────────────────────────────────────────────────────────────────────┘
//
//  ▸ 三个泛型映射闭包（把你的数据 T 翻译给组件看）：
//      • titleMapper: (T) -> String     【必填】每个选项显示什么文字
//      • iconMapper:  (T) -> String?    【可选】每个选项的 SF Symbol 图标名（返回 nil 则该项无图标）
//      • selection:   Binding<T>        【必填】当前选中项（点击会自动写回）
//
//  ▸ 配色（全部对照设计图像素校准，亮/暗色双模式可用；传 colors 可逐项覆盖）：
//      元素            .filled 默认                         .bordered 默认
//      ───────────────────────────────────────────────────────────────────
//      轨道/容器底 track   pageBgDeep(亮#E5EAF4/暗#000000)     card(亮#FFF/暗#171A1E)
//      描边 border        line(亮#E0E0E0/暗#454545，细0.5)     line(同左，1pt)
//      选中药丸 selectedBackground  buttonSecondaryBg(亮#F8F8F8/暗#373737)  〔无药丸〕
//      选中字/图标 selectedForeground  theme #007CFF                       theme #007CFF
//      未选中字/图标 normalForeground  textTertiary(亮#6B7785/暗#696A6D)     同左
//    （暗色专门校准：选中药丸用 buttonSecondaryBg 而非 card，确保在近黑轨道上清晰可见。）
//
//  ============================================================================
//  ▸ 用法速查（复制即用）
//  ============================================================================
//
//      // ① 最简：等宽 + 填充式 + 纯文字（与历史用法完全一致，零改动）
//      AldeloSegment(selection: $tab, items: tabs, titleMapper: { $0.title })
//
//      // ② 内容自适应 + 填充式（Wi-Fi / USB / Bluetooth，文字长短不一）
//      AldeloSegment(selection: $conn, items: conns, titleMapper: { $0.name },
//                    distribution: .fit)
//
//      // ③ 描边卡片式 + 纯文字（Pay Out / Tip out / Safe Drop / Refund）
//      AldeloSegment(selection: $action, items: actions, titleMapper: { $0.label },
//                    style: .bordered)
//
//      // ④ 描边卡片式 + 图标（Passcode / Face Recognition）
//      AldeloSegment(selection: $auth, items: auths,
//                    titleMapper: { $0.title }, iconMapper: { $0.icon },
//                    style: .bordered)
//
//      // ⑤ 自定义配色（只写想改的项，其余自动用上面的校准默认色）
//      AldeloSegment(selection: $tab, items: tabs, titleMapper: { $0.title },
//                    colors: AldeloSegmentColors(selectedForeground: .green))
//
//  ▸ 兼容性：三参构造器 AldeloSegment(selection:items:titleMapper:) 原样保留，
//    新增参数全部带默认值，现有调用点无需任何改动。
//  ============================================================================

import SwiftUI

// MARK: - 样式 AldeloSegmentStyle

/// 分段选择器外观样式。**先想清楚要哪种观感，再决定其余参数。**
enum AldeloSegmentStyle {
    /// 灰色轨道 + 白色药丸滑块（选中项落在白药丸里、文字变蓝，带丝滑位移动画）。
    /// iOS 原生分段控件的经典观感。适合：主切换、Tab 切换、过滤器。
    /// 对应设计图：88174 / 88181 / 88372。
    case filled
    /// 白底细描边的整块卡片 + 仅靠「文字变蓝」表示选中（**无药丸滑块**）。
    /// 更轻、更扁平。适合：操作类切换、表单内联切换。
    /// 对应设计图：88373 / 883723 / 883732。
    case bordered
}

// MARK: - 分布 AldeloSegmentDistribution

/// 分段选择器各段的宽度分布方式。
enum AldeloSegmentDistribution {
    /// 每段等宽，整体铺满可用宽度（`maxWidth: .infinity`）。选项少、想填满一行时用。
    case equalWidth
    /// 每段按各自内容宽度自适应，整体只占内容所需宽度。文字长短差异大时用，避免短词被拉太宽。
    case fit
}

// MARK: - 配色自定义 AldeloSegmentColors

/// 分段选择器配色。**每项均可选，nil = 沿用「对照设计图校准的样式默认色」。**
/// 只需传入想覆盖的项，例如把选中色改绿：`AldeloSegmentColors(selectedForeground: .green)`。
struct AldeloSegmentColors {
    /// 轨道 / 容器背景色（.filled 是灰轨道，.bordered 是白卡片底）。
    var track: Color?
    /// 轨道 / 容器描边色。
    var border: Color?
    /// 选中药丸底色（**仅 .filled 有药丸**，.bordered 无视此项）。
    var selectedBackground: Color?
    /// 选中项的文字 / 图标颜色。
    var selectedForeground: Color?
    /// 未选中项的文字 / 图标颜色。
    var normalForeground: Color?
    /// 选中药丸的阴影色（仅 .filled）。
    var shadow: Color?

    init(
        track: Color? = nil,
        border: Color? = nil,
        selectedBackground: Color? = nil,
        selectedForeground: Color? = nil,
        normalForeground: Color? = nil,
        shadow: Color? = nil
    ) {
        self.track = track
        self.border = border
        self.selectedBackground = selectedBackground
        self.selectedForeground = selectedForeground
        self.normalForeground = normalForeground
        self.shadow = shadow
    }
}

// MARK: - AldeloSegment

/// Aldelo POS 通用分段选择器（详尽用法 / 选型见文件顶部速查注释）。
/// 泛型选项 + 亮/暗色自适应；.filled 用 matchedGeometryEffect 实现丝滑药丸位移。
struct AldeloSegment<T: Hashable>: View {

    // MARK: 参数

    /// 【必填】当前选中项，双向绑定（点击某段会自动写回）。
    @Binding var selection: T
    /// 【必填】所有可选项。
    let items: [T]
    /// 【必填】把选项映射成显示文字。
    let titleMapper: (T) -> String
    /// 【可选】把选项映射成 SF Symbol 图标名；返回 nil 表示该项不显示图标。
    var iconMapper: ((T) -> String?)? = nil
    /// 外观样式，默认 .filled（灰底白药丸）。
    var style: AldeloSegmentStyle = .filled
    /// 宽度分布，默认 .equalWidth（等宽铺满）。
    var distribution: AldeloSegmentDistribution = .equalWidth
    /// 自定义配色，默认全用校准色。
    var colors: AldeloSegmentColors = AldeloSegmentColors()

    /// 显式构造器：保留历史三参签名（其余参数均有默认值），现有调用点零改动。
    init(
        selection: Binding<T>,
        items: [T],
        titleMapper: @escaping (T) -> String,
        iconMapper: ((T) -> String?)? = nil,
        style: AldeloSegmentStyle = .filled,
        distribution: AldeloSegmentDistribution = .equalWidth,
        colors: AldeloSegmentColors = AldeloSegmentColors()
    ) {
        self._selection = selection
        self.items = items
        self.titleMapper = titleMapper
        self.iconMapper = iconMapper
        self.style = style
        self.distribution = distribution
        self.colors = colors
    }

    // MARK: 内部状态 / 适配

    @Namespace private var animationNamespace
    @Environment(\.horizontalSizeClass) private var hSizeClass
    private var isCompact: Bool { hSizeClass == .compact }

    private var trackHeight: CGFloat { isCompact ? 40 : 44 }
    private var trackPadding: CGFloat { style == .filled ? 3 : 1 }
    private var corner: CGFloat { isCompact ? AppRadius.Mobile.sm : AppRadius.Tablet.sm }
    private var borderedCorner: CGFloat { isCompact ? AppRadius.Mobile.md : AppRadius.Tablet.md }

    // MARK: 解析后的配色（自定义优先，否则用「亮/暗双模校准」默认）

    /// 轨道/容器底：.filled=pageBgDeep（亮#E5EAF4，暗自动转黑）/ .bordered=card（亮白/暗#171A1E）。
    private var trackColor: Color {
        colors.track ?? (style == .filled ? AppColors.pageBgDeep : AppColors.card)
    }
    /// 描边：line（亮#E0E0E0 / 暗#454545）。暗色下即使轨道填充与页面同为黑，也靠它勾出容器轮廓。
    private var borderColor: Color { colors.border ?? AppColors.line }
    /// 选中药丸底：buttonSecondaryBg（亮#F8F8F8≈白 / 暗#373737）。
    /// 暗色专门用它而非 card，确保药丸在近黑轨道上清晰可见、且比轨道更亮（符合选中态直觉）。
    private var selectedBgColor: Color { colors.selectedBackground ?? AppColors.buttonSecondaryBg }
    /// 选中字/图标：theme #007CFF。
    private var selectedFgColor: Color { colors.selectedForeground ?? AppColors.theme }
    /// 未选中字/图标：textTertiary（亮#6B7785，校准自设计图 / 暗#696A6D）。
    private var normalFgColor: Color { colors.normalForeground ?? AppColors.textTertiary }
    /// 选中药丸阴影。
    private var shadowColor: Color { colors.shadow ?? AppColors.textPrimary.opacity(0.08) }

    // MARK: Body

    var body: some View {
        HStack(spacing: 0) {
            ForEach(items, id: \.self) { item in
                itemView(item)
            }
        }
        .padding(trackPadding)
        .frame(height: trackHeight)
        .frame(maxWidth: distribution == .equalWidth ? .infinity : nil)
        .background(trackBackground)
    }

    // MARK: 单个选项

    private func itemView(_ item: T) -> some View {
        let isActive = selection == item
        return Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                selection = item
            }
        } label: {
            itemLabel(item, isActive: isActive)
                .frame(maxWidth: distribution == .equalWidth ? .infinity : nil)
                .frame(height: trackHeight - trackPadding * 2)
                .padding(.horizontal, distribution == .fit ? Spacing.md : Spacing.xs)
                .background(sliderBackground(isActive: isActive))
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    /// 图标（可选）+ 文字，颜色随选中态切换。
    @ViewBuilder
    private func itemLabel(_ item: T, isActive: Bool) -> some View {
        let tint = isActive ? selectedFgColor : normalFgColor
        HStack(spacing: Spacing.xs) {
            if let icon = iconMapper?(item) {
                Image(systemName: icon)
                    .font(isCompact ? AppFont.mobileBody2Regular : AppFont.tabletBody3Regular)
                    .foregroundColor(tint)
            }
            Text(titleMapper(item))
                .font(isCompact ? AppFont.mobileBody2Regular : AppFont.tabletBody3Regular)
                .fontWeight(isActive ? .medium : .regular)
                .foregroundColor(tint)
        }
        .lineLimit(1)
    }

    // MARK: 选中态药丸（仅 .filled 有白药丸；.bordered 无药丸，仅靠文字变蓝高亮）

    @ViewBuilder
    private func sliderBackground(isActive: Bool) -> some View {
        if style == .filled, isActive {
            RoundedRectangle(cornerRadius: corner)
                .fill(selectedBgColor)
                .shadow(color: shadowColor, radius: 3, y: 1)
                .matchedGeometryEffect(id: "activeSlider", in: animationNamespace)
        } else {
            Color.clear
        }
    }

    // MARK: 外层轨道 / 容器背景

    @ViewBuilder
    private var trackBackground: some View {
        switch style {
        case .filled:
            // 细描边（0.5pt）：亮色细灰、暗色给黑底勾出可见容器轮廓。
            RoundedRectangle(cornerRadius: corner)
                .fill(trackColor)
                .overlay(
                    RoundedRectangle(cornerRadius: corner)
                        .stroke(borderColor, lineWidth: 0.5)
                )
        case .bordered:
            // 1pt 实描边：白卡片轮廓。
            RoundedRectangle(cornerRadius: borderedCorner)
                .fill(trackColor)
                .overlay(
                    RoundedRectangle(cornerRadius: borderedCorner)
                        .stroke(borderColor, lineWidth: 1)
                )
        }
    }
}

// MARK: - Previews

#Preview("Filled · 等宽 · 多项（图 88174）") {
    StatefulPreview(selected: "All", items: ["All", "Printer", "Cash Drawer", "Scanner", "Weight Scale"])
}

#Preview("Filled · 自适应（图 88181）") {
    StatefulPreview(selected: "Wi-Fi", items: ["Wi-Fi", "USB", "Bluetooth"], distribution: .fit)
}

#Preview("Filled · 两项（图 88372）") {
    StatefulPreview(selected: "Duration", items: ["Duration", "Time"])
}

#Preview("Bordered · 多项（图 883723）") {
    StatefulPreview(selected: "Pay Out", items: ["Pay Out", "Tip out", "Safe Drop", "Refund"], style: .bordered)
}

#Preview("Bordered · 两项（图 883732）") {
    StatefulPreview(selected: "Customer", items: ["Tab Name", "Customer"], style: .bordered)
}

#Preview("Bordered · 图标（图 88373）") {
    struct IconPreview: View {
        @State private var sel = "Passcode"
        var body: some View {
            AldeloSegment(
                selection: $sel,
                items: ["Passcode", "Face Recognition"],
                titleMapper: { $0 },
                iconMapper: { $0 == "Passcode" ? "rectangle.and.pencil.and.ellipsis" : "faceid" },
                style: .bordered
            )
            .padding()
            .background(AppColors.pageBg)
        }
    }
    return IconPreview()
}

#Preview("自定义配色") {
    StatefulPreview(
        selected: "B", items: ["A", "B", "C"],
        colors: AldeloSegmentColors(selectedForeground: AppColors.successNormal)
    )
}

#Preview("暗色 · Filled（轨道+药丸均可见）") {
    StatefulPreview(selected: "Duration", items: ["Duration", "Time"])
        .preferredColorScheme(.dark)
}

#Preview("暗色 · Bordered") {
    StatefulPreview(selected: "Pay Out", items: ["Pay Out", "Tip out", "Safe Drop"], style: .bordered)
        .preferredColorScheme(.dark)
}

/// Preview 辅助：本地 @State 驱动选中。
private struct StatefulPreview: View {
    @State var selected: String
    let items: [String]
    var style: AldeloSegmentStyle = .filled
    var distribution: AldeloSegmentDistribution = .equalWidth
    var colors: AldeloSegmentColors = AldeloSegmentColors()

    var body: some View {
        VStack(spacing: Spacing.lg) {
            AldeloSegment(
                selection: $selected,
                items: items,
                titleMapper: { $0 },
                style: style,
                distribution: distribution,
                colors: colors
            )
            Text("Selected: \(selected)")
                .font(AppFont.tabletBody3Regular)
                .foregroundColor(AppColors.textTertiary)
        }
        .padding()
        .background(AppColors.pageBg)
    }
}
