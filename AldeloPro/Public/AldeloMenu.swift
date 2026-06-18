//
//  AldeloMenu.swift
//  AldeloPro
//
//  Created by Sen on 2026/06/09.
//

import SwiftUI

// MARK: - 锚点定位枚举

/// 决定菜单相对于触发按钮屏幕位置的四象限方位
enum AldeloMenuAnchor {
    case topLeft      // 菜单出现在按钮左上方
    case topRight     // 菜单出现在按钮右上方
    case bottomLeft   // 菜单出现在按钮左下方
    case bottomRight  // 菜单出现在按钮右下方
}

// MARK: - 菜单项数据模型

/// 单个菜单按钮的配置（图标 + 标题）
struct AldeloMenuItem: Identifiable {
    let id: String
    let icon: String    // SF Symbol 名称
    let title: String   // 按钮显示文本

    init(id: String = UUID().uuidString, icon: String, title: String) {
        self.id = id
        self.icon = icon
        self.title = title
    }
}

// MARK: - AldeloMenu 全屏浮层菜单

/// 通用公共弹出菜单组件，支持四象限锚点定位。
/// 以全屏透明遮罩 + 绝对坐标定位方式渲染，点击任意空白区域自动关闭。
///
/// 特性：
/// - 支持自定义菜单项数量、名称、图标（通过 [AldeloMenuItem] 传入）
/// - 支持四象限锚点定位（topLeft/topRight/bottomLeft/bottomRight）
/// - 全屏遮罩层，点击空白处自动关闭
///
/// 使用方式：
/// ```swift
/// .aldeloMenu(
///     isPresented: $showMenu,
///     anchor: .bottomRight,
///     buttonRect: savedButtonRect,
///     items: [
///         AldeloMenuItem(icon: "envelope", title: "Email Receipt"),
///         AldeloMenuItem(icon: "printer.fill", title: "Print Receipt"),
///         AldeloMenuItem(icon: "iphone", title: "Text Receipt"),
///     ]
/// ) { selectedItem in
///     handle(selectedItem)
/// }
/// ```
struct AldeloMenuOverlay: View {

    @Binding var isPresented: Bool
    let anchor: AldeloMenuAnchor
    let buttonRect: CGRect
    let items: [AldeloMenuItem]
    let onSelect: (AldeloMenuItem) -> Void

    private let menuWidth: CGFloat = 210
    private let itemHeight: CGFloat = 44
    private let gap: CGFloat = 6

    var body: some View {
        ZStack(alignment: .topLeading) {
            // 全屏透明遮罩层 — 点击任意空白区域关闭菜单
            Color.clear
                .contentShape(Rectangle())
                .onTapGesture { isPresented = false }

            // 菜单主体 — 根据按钮屏幕坐标绝对定位
            menuContent
                .position(x: menuX, y: menuY)
        }
        .ignoresSafeArea()
        .transition(.opacity)
        .animation(.easeOut(duration: 0.15), value: isPresented)
    }

    // MARK: - 菜单视觉样式

    private var menuContent: some View {
        VStack(spacing: gap) {
            ForEach(items) { item in
                menuButton(item: item)
            }
        }
        .padding(Spacing.sm)
        .background(
            RoundedRectangle(cornerRadius: AppRadius.Tablet.md)
                .fill(AppColors.pageBgDeep)
        )
        .shadow(color: Color.black.opacity(0.15), radius: 8, x: 0, y: 4)
        .frame(width: menuWidth)
    }

    private func menuButton(item: AldeloMenuItem) -> some View {
        Button {
            onSelect(item)
            isPresented = false
        } label: {
            HStack(spacing: Spacing.sm) {
                Image(systemName: item.icon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(AppColors.textPrimary)
                    .frame(width: 24, height: 24)
                Text(item.title)
                    .font(AppFont.tabletBody3Regular)
                    .foregroundColor(AppColors.textPrimary)
                Spacer()
            }
            .padding(.horizontal, Spacing.md)
            .frame(height: itemHeight)
            .background(AppColors.card)
            .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }

    // MARK: - 坐标计算

    private var totalMenuHeight: CGFloat {
        itemHeight * CGFloat(items.count) + gap * CGFloat(items.count - 1) + Spacing.sm * 2
    }

    private var menuX: CGFloat {
        switch anchor {
        case .topLeft, .bottomLeft:
            // 菜单右边缘对齐按钮右边缘（向左展开）
            return buttonRect.maxX - menuWidth / 2
        case .topRight, .bottomRight:
            // 菜单左边缘对齐按钮左边缘（向右展开）
            return buttonRect.minX + menuWidth / 2
        }
    }

    private var menuY: CGFloat {
        switch anchor {
        case .topLeft, .topRight:
            // 菜单底部紧贴按钮顶部（零重叠）
            return buttonRect.minY - totalMenuHeight / 2 - gap
        case .bottomLeft, .bottomRight:
            // 菜单顶部紧贴按钮底部（零重叠）
            return buttonRect.maxY + totalMenuHeight / 2 + gap
        }
    }
}

// MARK: - View 扩展（便捷调用）

extension View {
    /// 挂载 AldeloMenu 浮层菜单到当前视图，支持自定义菜单项。
    /// - Parameters:
    ///   - isPresented: 控制菜单显示/隐藏的绑定
    ///   - anchor: 菜单相对按钮的锚点方位
    ///   - buttonRect: 触发按钮在屏幕上的全局坐标矩形
    ///   - items: 菜单项列表（图标 + 标题）
    ///   - onSelect: 用户点击某项后的回调
    func aldeloMenu(
        isPresented: Binding<Bool>,
        anchor: AldeloMenuAnchor,
        buttonRect: CGRect,
        items: [AldeloMenuItem],
        onSelect: @escaping (AldeloMenuItem) -> Void
    ) -> some View {
        self.overlay {
            if isPresented.wrappedValue {
                AldeloMenuOverlay(
                    isPresented: isPresented,
                    anchor: anchor,
                    buttonRect: buttonRect,
                    items: items,
                    onSelect: onSelect
                )
            }
        }
    }
}

// MARK: - Preview

#Preview("AldeloMenu 浮层菜单") {
    ZStack {
        AppColors.pageBg.ignoresSafeArea()
        Text("背景内容")
    }
    .overlay {
        AldeloMenuOverlay(
            isPresented: .constant(true),
            anchor: .bottomRight,
            buttonRect: CGRect(x: 300, y: 200, width: 32, height: 32),
            items: [
                AldeloMenuItem(icon: "envelope", title: "Email Receipt"),
                AldeloMenuItem(icon: "printer.fill", title: "Print Receipt"),
                AldeloMenuItem(icon: "iphone", title: "Text Receipt"),
            ],
            onSelect: { _ in }
        )
    }
}
