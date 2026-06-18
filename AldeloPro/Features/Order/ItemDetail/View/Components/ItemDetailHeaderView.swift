//
//  ItemDetailHeaderView.swift
//  AldeloPro
//
//  Created by Sen on 2026/06/10.
//

import SwiftUI

// MARK: - 详情头部版式枚举

/// 控制头部标题行的排版策略
/// - singleImage：餐品名 + 价格同行（图97）
/// - multiImage：固定标题 "Details"，餐品名移至画廊右侧（图96）
enum ItemDetailLayoutMode {
    case singleImage
    case multiImage
}

// MARK: - 详情页顶部标题栏

/// 顶级标题头行组件
/// 动态适配单图/多图版式，iPad 端显示关闭 "X" 按钮，iPhone 端隐藏
struct ItemDetailHeaderView: View {
    /// 标题文本（单图模式为餐品名，多图模式为 "Details"）
    let title: String
    /// 价格文本（仅单图模式显示，多图模式为 nil）
    let price: String?
    /// 是否为 iPad 环境
    let isPad: Bool
    /// 当前版式模式
    let layoutMode: ItemDetailLayoutMode
    /// 关闭回调（iPad 有，iPhone 为 nil 则不渲染关闭按钮）
    let onDismiss: (() -> Void)?

    var body: some View {
        HStack(alignment: .center) {
            // 主标题
            Text(title)
                .font(isPad ? AppFont.tabletH1Medium : AppFont.mobileH1Medium)
                .foregroundStyle(AppColors.textPrimary)

            // 价格标签（仅单图模式）
            if let price = price {
                Text(price)
                    .font(isPad ? AppFont.tabletH4Medium : AppFont.mobileH3Medium)
                    .foregroundStyle(AppColors.textSecondary)
                    .opacity(0.7)
            }

            Spacer()

            // 关闭按钮（iPad 弹窗模式显示）
            if let onDismiss = onDismiss {
                Button(action: onDismiss) {
                    Image(systemName: "xmark")
                        .font(.system(size: isPad ? 18 : 14, weight: .bold))
                        .foregroundStyle(AppColors.textPrimary)
                        .frame(width: isPad ? 32 : 28, height: isPad ? 32 : 28)
                }
            }
        }
        .padding(.horizontal, isPad ? Spacing.lg : Spacing.md)
        .padding(.vertical, isPad ? Spacing.md : Spacing.sm)
    }
}
