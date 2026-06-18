//
//  SelectEmployeeFilterModel.swift
//  AldeloPro
//
//  Created by SunZhongwei on 2026/06/18.
//

import Foundation

// MARK: - Filter Chip Option

/// 单个可选筛选项（chip）。
struct FilterChipOption: Identifiable, Equatable {
    let id: String
    let label: String
}

// MARK: - Filter Group

/// 一组筛选项（如 Bank / Source），含分组标题与可选项列表。
struct FilterGroup: Identifiable, Equatable {
    let id: String
    /// 分组标题（如 "Bank"）
    let title: String
    let options: [FilterChipOption]
}

// MARK: - Select Employee Filter Data

/// "Select Employee Filter" 弹窗的数据模型。
struct SelectEmployeeFilterData: Equatable {
    let groups: [FilterGroup]
    /// 默认选中项：分组 id -> 选项 id
    let defaultSelection: [String: String]
}

// MARK: - Mock Data

extension SelectEmployeeFilterData {
    static let mock = SelectEmployeeFilterData(
        groups: [
            FilterGroup(
                id: "bank",
                title: "Bank",
                options: [
                    FilterChipOption(id: "all_banks", label: "All Banks"),
                    FilterChipOption(id: "cashier", label: "Cashier"),
                    FilterChipOption(id: "server_bank", label: "Server bank")
                ]
            ),
            FilterGroup(
                id: "source",
                title: "Source",
                options: [
                    FilterChipOption(id: "all_sources", label: "All sources"),
                    FilterChipOption(id: "masa", label: "Masa online Order"),
                    FilterChipOption(id: "uber_eats", label: "uber eats"),
                    FilterChipOption(id: "doordash", label: "DoorDash")
                ]
            )
        ],
        defaultSelection: [
            "bank": "all_banks",
            "source": "all_sources"
        ]
    )
}
