//
//  NoteViewModel.swift
//  AldeloPro
//
//  Created by Sen on 2026/06/10.
//

import Foundation

// MARK: - 商品备注视图模型

/// 管理商品自定义备注的状态：文本内容、快捷标签数组、套用数量
/// 通过 @Observable 实现细粒度属性追踪，驱动 View 局部重绘
@Observable
final class NoteViewModel {

    // MARK: - 状态属性

    /// 备注文本框中的实际输入内容
    var noteText: String = ""
    /// 快捷标签套用的商品数量（默认显示 5）
    var quantity: Int = 0
    /// 当前可用的快捷标签选项列表
    let quickChips: [String]

    // MARK: - 初始化

    init(
        initialNote: String = "",
        initialQuantity: Int?,
        quickChips: [String] = ["No Cilantro", "Don't Add Chili Peppers", "Add More Sugar"]
    ) {
        self.noteText = initialNote
        self.quantity = initialQuantity ?? 0
        self.quickChips = quickChips
    }

    // MARK: - 业务方法

    /// 将快捷标签文本追加到备注末尾（自动补空格分隔）
    func appendChip(_ chip: String) {
        if noteText.isEmpty {
            noteText = chip
        } else {
            noteText += " " + chip
        }
    }

    /// 提供 Preview 用的预填实例
    static func previewInstance() -> NoteViewModel {
        NoteViewModel(initialNote: "", initialQuantity: 5)
    }
}
