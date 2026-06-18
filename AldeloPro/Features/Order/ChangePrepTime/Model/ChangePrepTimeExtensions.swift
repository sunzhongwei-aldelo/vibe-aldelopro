//
//  ChangePrepTimeExtensions.swift
//  AldeloPro
//
//  Created by Sen on 2026/06/08.
//

import Foundation

// MARK: - 备餐时间选项扩展

/// 为 PrepTimeOption 扩展目标时间计算方法
/// 根据基准时间 + 分钟数，生成格式化后的目标完成时间字符串
extension PrepTimeOption {
    /// 根据传入的基准时间计算目标备餐完成时间
    /// - Parameter baseTime: 基准时间（通常为当前时间或订单创建时间）
    /// - Returns: 格式化后的时间字符串，如 "10:30 AM"
    func formattedChangePrepTargetTime(from baseTime: Date) -> String {
        let target = Calendar.current.date(
            byAdding: .minute, value: minutes, to: baseTime
        ) ?? baseTime
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: target)
    }
}
