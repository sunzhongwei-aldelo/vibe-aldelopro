//
//  GlobalValues.swift
//  AldeloPro
//
//  Created by wanghui on 2026/6/11.
//

import SwiftUI

// MARK: - Device Layout

/// 全局设备布局类型，用于区分三种适配形态：
/// - iPadLandscape：iPad 横屏
/// - iPadPortrait：iPad 竖屏
/// - iPhonePortrait：iPhone 竖屏
enum DeviceLayout {
    case iPadLandscape
    case iPadPortrait
    case iPhonePortrait

    /// 是否为 iPhone 竖屏（紧凑布局）
    var isPhonePortrait: Bool { self == .iPhonePortrait }

    /// 是否为 iPad（横屏或竖屏）
    var isPad: Bool { self != .iPhonePortrait }
    
    var isPadPortrait: Bool { self == .iPadPortrait }
    
    var iPadLandscape: Bool { self == .iPadLandscape }

    /// 设备布局判定：
    /// - iPhone 竖屏：horizontalSizeClass == .compact
    /// - iPad：sizeClass 在横竖屏下都是 .regular，无法区分方向，
    ///   必须用几何宽高比较（width > height = 横屏）
    static func resolve(
        horizontalSizeClass: UserInterfaceSizeClass?,
        size: CGSize
    ) -> DeviceLayout {
        if horizontalSizeClass == .compact { return .iPhonePortrait }
        return size.width > size.height ? .iPadLandscape : .iPadPortrait
    }
}

// MARK: - DeviceLayout Environment

private struct DeviceLayoutKey: EnvironmentKey {
    /// 默认 iPad 横屏（App 为 iPad 优先）。
    /// 实际值由根视图 `.provideDeviceLayout()` 注入并随旋转刷新。
    static let defaultValue: DeviceLayout = .iPadLandscape
}

extension EnvironmentValues {
    /// 当前设备布局形态，下游页面通过 `@Environment(\.deviceLayout)` 读取，
    /// 无需各自再写 GeometryReader / horizontalSizeClass。
    var deviceLayout: DeviceLayout {
        get { self[DeviceLayoutKey.self] }
        set { self[DeviceLayoutKey.self] = newValue }
    }
}

// MARK: - DeviceLayout Provider

/// 在视图树某一层用单个 GeometryReader 计算并注入 `deviceLayout` 环境值。
/// 仅需在 App 根部调用一次，旋转时 geo.size 变化会自动重算、下游全部刷新。
private struct DeviceLayoutProvider: ViewModifier {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    func body(content: Content) -> some View {
        GeometryReader { geo in
            content
                .environment(
                    \.deviceLayout,
                    DeviceLayout.resolve(
                        horizontalSizeClass: horizontalSizeClass,
                        size: geo.size
                    )
                )
        }
        // 键盘弹出时不让 GeometryReader 的 geo.size 跟着收缩，
        // 否则被它包裹的根视图（及其 fullScreenCover）会整体被顶起。
        // 设备布局判定只依赖旋转时的尺寸，与键盘无关，故忽略键盘安全区是安全的。
        .ignoresSafeArea(.keyboard, edges: .bottom)
    }
}

extension View {
    /// 注入全局 `deviceLayout` 环境值。在 `@main` App 根容器上调用一次即可，
    /// 下游所有页面用 `@Environment(\.deviceLayout)` 读取，无需重复 GeometryReader。
    func provideDeviceLayout() -> some View {
        modifier(DeviceLayoutProvider())
    }
}
