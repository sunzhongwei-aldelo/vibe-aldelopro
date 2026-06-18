//
//  AldeloHeaderModel.swift
//  AldeloPro
//
//  Created by Sen on 2026/06/12.
//

import Foundation

// MARK: - 概述
//
// AldeloHeaderBar 子系统的领域模型层（纯数据，仅 import Foundation）。
// 这里集中定义：高度档位、宽度模式（解决"特殊长度"）、AI 指令栏状态、
// 通用动作 DTO、按钮样式，供 Core / Atoms / 各 façade View 共享，
// 从而消灭散落在各处的魔数与重复结构体。
//
// 设计依据：designs/HeaderBar 下 37 张运行截图（去重 33 张），归纳为
// 4 个语义族 × 3 种 iPad 高度（详见 AldeloHeaderBar.swift 顶部文档）。

// MARK: - 高度档位

/// 顶栏高度档位。数值来源于 Figma @1440 设计稿三种实测高度：
/// - `.statusBar`  78pt → D 族「App Mode 状态栏」
/// - `.dashboard`  88pt → A 族「工作台主干栏」
/// - `.standard`  112pt → B 族「交易开单栏」/ C 族「配置弹窗栏」
///
/// `regular` 用于 iPad（Regular×Regular），`compact` 用于 iPhone。
/// iPhone 默认单行降高；唯 `.dashboard` 因 AI 搜索下沉为第二行而升高到 96pt。
public enum AldeloHeaderHeight: Equatable, Sendable {
    case statusBar
    case dashboard
    case standard

    /// iPad（Regular）高度
    public var regular: CGFloat {
        switch self {
        case .statusBar: return 78
        case .dashboard: return 88
        case .standard:  return 112
        }
    }

    /// iPhone（Compact）高度。dashboard 为两行布局故升高。
    public var compact: CGFloat {
        switch self {
        case .statusBar: return 56
        case .dashboard: return 96
        case .standard:  return 64
        }
    }
}

// MARK: - 宽度模式（解决"特殊长度"红框）

/// 顶栏宽度模式。对应两张全屏大图红框区域的不同长度：
/// - `.fill`：横贯父容器全宽（如「桌台.png」≈1428pt，顶栏在最上、左栏在其下方）。
/// - `.inset(leading:)`：只覆盖右内容列（如「weweqeqw.png」≈1080pt，
///   左侧订单详情面板通顶，顶栏从 leading 偏移处才开始）。
///
/// 组件内部 **绝不写死任何子元素宽度**（如搜索框宽度），一律由本模式 + 父容器决定，
/// 以兼容 1080 / 1428 / iPhone 全宽等所有挂载场景。
public enum AldeloHeaderWidth: Equatable, Sendable {
    case fill
    case inset(leading: CGFloat)

    /// 左侧需要让出的固定宽度（fill 为 0）。
    public var leadingInset: CGFloat {
        switch self {
        case .fill: return 0
        case .inset(let leading): return leading
        }
    }
}

// MARK: - AI 指令栏状态（A 族中心区）

/// 工作台栏中心「AI 指令/搜索」胶囊的四种运行态，逐一对应截图：
/// - `.idle`           占位文案 `Say "Hey Aldelo"...` + 实心麦克风（1233123.png）
/// - `.listening`      浅色底蓝色声波动画 + 实心麦克风（123424324.png）
/// - `.listeningDark`  深色胶囊 + 蓝色声波 + 高亮麦克风（21341244123.png）
/// - `.typing`         `Type to Search...` 异文案 + 斜杠禁用麦克风（13243242134.png）
public enum AICommandState: Equatable, Sendable {
    case idle
    case listening
    case listeningDark
    case typing

    /// 是否处于声波动画态（listening 系）。
    public var isWaveform: Bool {
        self == .listening || self == .listeningDark
    }

    /// 麦克风是否被禁用（typing 态显示斜杠麦克风）。
    public var isMicDisabled: Bool {
        self == .typing
    }
}

// MARK: - 通用动作 DTO

/// 顶栏右侧动作按钮的视觉样式。
/// - `.primary`   实心主题蓝（Continue / Save / Apply / Add / Confirm）
/// - `.secondary` 白底描边（Back / Cancel / All）
public enum AldeloHeaderActionStyle: Equatable, Sendable {
    case primary
    case secondary
}

/// 顶栏动作按钮数据。统一描述 B 族 Back/Continue、C 族 0~3 个按钮等所有场景。
///
/// - `badge`：可选数字角标（对应 Repeat 页 Confirm 右上角红色「1」徽标）。
/// - `isEnabled`：禁用态（对应 Add Item 页置灰不可点的 Add 按钮）。
public struct AldeloHeaderAction: Identifiable, Equatable {
    public let id: String
    public let title: String
    public let style: AldeloHeaderActionStyle
    public let isEnabled: Bool
    public let badge: Int?
    public let action: () -> Void

    public init(
        id: String? = nil,
        title: String,
        style: AldeloHeaderActionStyle = .primary,
        isEnabled: Bool = true,
        badge: Int? = nil,
        action: @escaping () -> Void
    ) {
        self.id = id ?? title
        self.title = title
        self.style = style
        self.isEnabled = isEnabled
        self.badge = badge
        self.action = action
    }

    public static func == (lhs: AldeloHeaderAction, rhs: AldeloHeaderAction) -> Bool {
        lhs.id == rhs.id
            && lhs.title == rhs.title
            && lhs.style == rhs.style
            && lhs.isEnabled == rhs.isEnabled
            && lhs.badge == rhs.badge
    }

    // 便捷构造：常见二元按钮对。
    public static func back(_ action: @escaping () -> Void) -> AldeloHeaderAction {
        AldeloHeaderAction(id: "back", title: "Back", style: .secondary, action: action)
    }

    public static func cancel(_ action: @escaping () -> Void) -> AldeloHeaderAction {
        AldeloHeaderAction(id: "cancel", title: "Cancel", style: .secondary, action: action)
    }

    public static func primary(
        _ title: String,
        isEnabled: Bool = true,
        badge: Int? = nil,
        action: @escaping () -> Void
    ) -> AldeloHeaderAction {
        AldeloHeaderAction(id: title, title: title, style: .primary, isEnabled: isEnabled, badge: badge, action: action)
    }
}
