//
//  TimeCardFlowState.swift
//  AldeloPro
//
//  Created by jiangxia on 2026/06/11.
//

import Foundation

// MARK: - Flow State

/// Time Card 流程状态机。驱动主内容卡片与侧边栏的显隐及选中态。
enum TimeCardFlowState {
    case clockInAction      // Clock In - no sidebar
    case clockInSuccess     // Clock In Successful - with sidebar
    case clockOutAction     // Clock Out - with sidebar
    case clockOutSuccess    // Clock Out Successful - with sidebar
    case reportCashTips     // Report Cash Tips - with sidebar
    case reportCashTipsOnClockOut  // Report Cash Tips (no sidebar) - from Clock Out，根据设置
    case tipSummaryOnClockOut   // Tip Summary (no sidebar) - after reporting tips (from Clock Out)

    var hasSidebar: Bool {
        switch self {
        case .clockInAction, .clockOutSuccess, .reportCashTipsOnClockOut, .tipSummaryOnClockOut:
            return false
        case .clockInSuccess, .clockOutAction, .reportCashTips:
            return true
        }
    }

    var selectedMenuItem: TimeCardMenuItem? {
        switch self {
        case .clockInAction: return nil
        case .clockInSuccess: return .clockOut
        case .clockOutAction: return .clockOut
        case .clockOutSuccess: return .timeCards
        case .reportCashTips: return .reportCashTips
        case .reportCashTipsOnClockOut: return nil
        case .tipSummaryOnClockOut: return nil
        }
    }

    /// 是否处于成功态（需展示倒计时徽标）。
    var showsCountdown: Bool {
        self == .clockInSuccess || self == .clockOutSuccess
    }
}

// MARK: - Sidebar Menu Item

/// Time Card 侧边栏菜单项。
enum TimeCardMenuItem: String, CaseIterable, Identifiable {
    case breakTime = "Break"
    case reportCashTips = "Report\nCash Tips"
    case workSchedules = "Work\nSchedules"
    case timeCards = "Time Cards"
    case clockOut = "Clock Out"

    var id: String { rawValue }

    var iconName: String {
        switch self {
        case .breakTime: return "cup.and.saucer"
        case .reportCashTips: return "doc.text"
        case .workSchedules: return "tablecells"
        case .timeCards: return "calendar"
        case .clockOut: return "rectangle.portrait.and.arrow.right"
        }
    }
}
