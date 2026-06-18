//
//  CashierSignOutViewModel.swift
//  AldeloPro
//
//  Created by Sen on 2026/06/05.
//

import Foundation

// MARK: - 收银员签退视图模型


// MARK: - CashierSignOutViewModel

/// 收银员签退流程的状态管理器
/// 管理现金盘点数据、差异计算、签退确认等业务逻辑
@Observable @MainActor
final class CashierSignOutViewModel {

    // MARK: - State

    private(set) var step: SignOutStep = .cashCounting
    private(set) var denominations: [Denomination] = Denomination.allDenominations
    private(set) var loadingPhase: LoadingPhase = .syncData

    /// 系统应有金额 (Expected Cash + Start Amount)
    let expectedAmount: Decimal

    /// 当前正在编辑的面额 ID
    var editingDenominationID: String?

    /// NumpadView 绑定的数量暂存值
    var editingQuantityValue: Int = 0

    /// 是否显示 Clear All 确认弹窗
    var showClearAllAlert: Bool = false

    /// 是否显示 Done 确认弹窗
    var showDoneAlert: Bool = false

    // MARK: - 派生状态

    /// 实际现金总额
    var actualTotal: Decimal {
        denominations.reduce(Decimal.zero) { $0 + $1.subtotal }
    }

    /// 匹配状态
    var matchStatus: CashMatchStatus {
        if actualTotal == 0 { return .idle }
        if actualTotal == expectedAmount { return .match }
        if actualTotal < expectedAmount {
            return .short(expectedAmount - actualTotal)
        }
        return .over(actualTotal - expectedAmount)
    }

    /// 格式化 Actual 金额字符串
    var actualTotalFormatted: String {
        formatCurrency(actualTotal)
    }

    /// 格式化 Expected 金额字符串
    var expectedAmountFormatted: String {
        formatCurrency(expectedAmount)
    }

    // MARK: - Init

    init(expectedAmount: Decimal = 100.00) {
        self.expectedAmount = expectedAmount
    }

    // MARK: - Denomination Actions

    /// 点击面额卡片：开始编辑该面额的数量
    func startEditDenomination(_ id: String) {
        editingDenominationID = id
        if let denom = denominations.first(where: { $0.id == id }) {
            editingQuantityValue = denom.count
        }
    }

    /// 确认面额数量输入
    func confirmDenominationQuantity() {
        guard let id = editingDenominationID,
              let index = denominations.firstIndex(where: { $0.id == id }) else { return }
        denominations[index].count = editingQuantityValue
        editingDenominationID = nil
        editingQuantityValue = 0
    }

    /// 取消编辑（点击外部关闭键盘）
    func dismissDenominationKeypad() {
        editingDenominationID = nil
        editingQuantityValue = 0
    }

    /// 清空所有面额数量
    func clearAll() {
        for i in denominations.indices {
            denominations[i].count = 0
        }
        showClearAllAlert = false
    }

    // MARK: - Flow Actions

    /// 点击 Done：进入处理阶段
    func submitCashCount() async {
        step = .processing
        loadingPhase = .syncData

        // 模拟异步同步数据
        try? await Task.sleep(for: .seconds(2))
        loadingPhase = .getTipOutAmount

        // 模拟获取小费金额
        try? await Task.sleep(for: .seconds(2))

        step = .success
    }

    /// 退出签退流程
    var onExit: (() -> Void)?

    func exitSignOut() {
        onExit?()
    }

    // MARK: - Preview Factory

    static func preview(step: SignOutStep = .cashCounting) -> CashierSignOutViewModel {
        let vm = CashierSignOutViewModel(expectedAmount: 100.00)
        vm.step = step
        if step != .cashCounting {
            // 设置一些示例数据
            if let idx = vm.denominations.firstIndex(where: { $0.id == "20.00" }) {
                vm.denominations[idx].count = 3
            }
            if let idx = vm.denominations.firstIndex(where: { $0.id == "10.00" }) {
                vm.denominations[idx].count = 2
            }
        }
        return vm
    }

    // MARK: - Private

    private func formatCurrency(_ value: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "en_US")
        formatter.currencySymbol = "$"
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        return formatter.string(from: value as NSDecimalNumber) ?? "$0.00"
    }
}

