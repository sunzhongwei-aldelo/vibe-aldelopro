//
//  BasicSetupViewModel.swift
//  AldeloPro
//
//  Created by wanghui on 2026/06/15.
//

import Foundation

// MARK: - ViewModel

/// Basic Information 注册步骤页的视图模型。
/// 纯 Foundation 实现，状态通过 @Observable 暴露给 View，导航由父级处理。
@Observable
@MainActor
final class BasicSetupViewModel {

    // MARK: - Form Fields

    var storeName: String = "Super delicious flagship store"
    var address1: String = "6701 Koll Center Parkway, Suite 150, Pleasanton, CA 95466"
    var address2: String = ""
    var city: String = "Pleasanton"
    var state: String = "CA"
    var postalCode: String = "95466"

    // MARK: - Options

    /// City 单选下拉的候选项
    let cityOptions: [String] = [
        "Pleasanton",
        "San Francisco",
        "San Jose",
        "Oakland",
        "Fremont",
        "Hayward",
        "Berkeley",
        "Sunnyvale"
    ]

    // MARK: - Validation

    /// 必填项是否全部已填（Store Name / Address 1 / City / State / Postal Code）。
    /// Address 2 为可选，不参与校验。仅去除首尾空白后判断非空。
    var canProceed: Bool {
        let required = [storeName, address1, city, state, postalCode]
        return required.allSatisfy { $0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false }
    }

    // MARK: - Actions

    func previousStep() {
        // Navigation handled by parent
    }

    func nextStep() {
        // Navigation handled by parent
    }
}
