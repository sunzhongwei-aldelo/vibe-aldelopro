//
//  ChangePrepTimeViewModel.swift
//  AldeloPro
//
//  Created by Sen on 2026/06/08.
//

import Foundation

// MARK: - 修改备餐时间视图模型

/// 自定义备餐时间页面的状态管理器
/// 负责管理时间选项列表、选中状态、以及确认/返回回调
@Observable @MainActor
final class ChangePrepTimeViewModel {
    // MARK: - 对外状态

    /// 所有可选的备餐时间选项列表
    private(set) var options: [PrepTimeOption] = PrepTimeOption.allOptions
    /// 当前选中的备餐分钟数（nil 表示未选中）
    var selectedMinutes: Int? = 10
    /// 基准时间（用于计算各选项的目标完成时间）
    private(set) var baseTime: Date

    // MARK: - 回调

    /// 确认按钮回调（传出选中的分钟数）
    var onConfirm: ((Int) -> Void)?
    /// 返回按钮回调
    var onBack: (() -> Void)?

    // MARK: - 初始化

    /// - Parameter baseTime: 基准时间，默认为当前时间
    init(baseTime: Date = Date()) {
        self.baseTime = baseTime
    }

    // MARK: - 操作方法

    /// 选中某个备餐时间选项
    func selectOption(_ option: PrepTimeOption) {
        selectedMinutes = option.minutes
    }

    /// 确认选择，触发回调并传出分钟数
    func confirm() {
        guard let minutes = selectedMinutes else { return }
        onConfirm?(minutes)
    }

    /// 返回上一页
    func goBack() {
        onBack?()
    }

    /// 判断某个选项是否为当前选中状态
    func isSelected(_ option: PrepTimeOption) -> Bool {
        selectedMinutes == option.minutes
    }

    /// 获取某个选项对应的格式化目标时间文本
    func formattedTime(for option: PrepTimeOption) -> String {
        option.formattedChangePrepTargetTime(from: baseTime)
    }
}
