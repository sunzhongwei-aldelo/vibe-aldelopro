//
//  CashCountModels.swift
//  AldeloPro
//
//  Created by Sen on 2026/06/05.
//

import Foundation

// MARK: - Sign Out Step

/// 签退流程的三个阶段
enum SignOutStep {
    case cashCounting      // 1. 现金清点主界面
    case processing        // 2. 数据同步加载
    case success           // 3. 结算成功退出
}

// MARK: - Cash Match Status

/// 现金对比计算结果
enum CashMatchStatus: Equatable {
    case idle              // 初始状态 (Actual 为 0)
    case match             // 金额完全吻合 (Expected == Actual)
    case short(Decimal)    // 亏损短缺 (Expected > Actual)，携带差额
    case over(Decimal)     // 盈余超出 (Expected < Actual)，携带差额
}

// MARK: - Loading Phase

/// 异步加载步骤
enum LoadingPhase: String {
    case syncData = "Sync Data"
    case getTipOutAmount = "Get Tip Out Amount"
}

// MARK: - Denomination

/// 面额模型
struct Denomination: Identifiable, Equatable, Sendable {
    let id: String
    let label: String
    let value: Decimal
    var count: Int

    /// 该面额的小计金额
    var subtotal: Decimal {
        value * Decimal(count)
    }

    /// 固定的10种面额
    static let allDenominations: [Denomination] = [
        Denomination(id: "100.00", label: "$100.00", value: 100.00, count: 0),
        Denomination(id: "50.00", label: "$50.00", value: 50.00, count: 0),
        Denomination(id: "20.00", label: "$20.00", value: 20.00, count: 0),
        Denomination(id: "10.00", label: "$10.00", value: 10.00, count: 0),
        Denomination(id: "5.00", label: "$5.00", value: 5.00, count: 0),
        Denomination(id: "1.00", label: "$1.00", value: 1.00, count: 0),
        Denomination(id: "0.25", label: "$0.25", value: 0.25, count: 0),
        Denomination(id: "0.10", label: "$0.10", value: 0.10, count: 0),
        Denomination(id: "0.05", label: "$0.05", value: 0.05, count: 0),
        Denomination(id: "0.01", label: "$0.01", value: 0.01, count: 0),
    ]
}

