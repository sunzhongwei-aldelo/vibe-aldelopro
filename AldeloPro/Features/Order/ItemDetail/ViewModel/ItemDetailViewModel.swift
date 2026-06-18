//
//  ItemDetailViewModel.swift
//  AldeloPro
//
//  Created by Sen on 2026/06/10.
//

import Foundation

// MARK: - 餐品详情视图模型

/// 餐品详情页状态管理器
/// 负责控制当前主图索引、管理多图切换动画，以及向 View 提供格式化后的展示数据
@Observable
final class ItemDetailViewModel {
    // MARK: - 对外状态（View 绑定）

    /// 当前展示的主图索引（多图模式下，缩略图点击时更新）
    private(set) var currentImageIndex: Int = 0

    // MARK: - 数据源

    /// 餐品名称（如 "Orange Juice"）
    let itemName: String
    /// 餐品价格文本（如 "From $5.00"）
    let itemPrice: String
    /// 餐品图片资源名数组（数量决定单图/多图版式切换）
    let imageURLs: [String]
    /// 商品描述正文段落
    let productDescription: String
    /// 口味与备餐定制化属性列表（bullet list 展示）
    let tastePreparation: [String]
    /// 营销促销信息列表（bullet list 展示）
    let promotions: [String]

    // MARK: - 计算属性

    /// 是否包含多张图片（>=2 触发多图画廊版式）
    var hasMultipleImages: Bool {
        imageURLs.count >= 2
    }

    /// 是否仅包含单张图片（触发全宽大图版式）
    var hasSingleImage: Bool {
        imageURLs.count == 1
    }

    /// 是否存在促销信息（决定 Promotions 段落是否渲染）
    var hasPromotions: Bool {
        !promotions.isEmpty
    }

    // MARK: - 初始化

    init(
        itemName: String,
        itemPrice: String,
        imageURLs: [String],
        productDescription: String,
        tastePreparation: [String],
        promotions: [String]
    ) {
        self.itemName = itemName
        self.itemPrice = itemPrice
        self.imageURLs = imageURLs
        self.productDescription = productDescription
        self.tastePreparation = tastePreparation
        self.promotions = promotions
    }

    // MARK: - 操作方法

    /// 切换当前主图索引（由缩略图点击触发）
    func selectImage(at index: Int) {
        guard index >= 0, index < imageURLs.count else { return }
        currentImageIndex = index
    }
}

// MARK: - Preview 预览辅助

extension ItemDetailViewModel {
    /// 多图预览实例（3 张图，含促销信息）
    static func previewWithMultipleImages() -> ItemDetailViewModel {
        ItemDetailViewModel(
            itemName: "Orange Juice",
            itemPrice: "From $5.00",
            imageURLs: [
                "orange_juice_1",
                "orange_juice_2",
                "orange_juice_3"
            ],
            productDescription: "Made from premium imported oranges, freshly squeezed daily. No added sugar or water \u{2014} just 100% pure juice. Rich in vitamin C and naturally refreshing.",
            tastePreparation: [
                "Flavor Profile: Sweet with a hint of tartness, rich citrus aroma, and smooth texture",
                "Preparation Method: Freshly squeezed to order with pulp and natural fibers retained",
                "Temperature Options: Iced / Room Temperature",
                "Sweetness Levels: No Sugar / Light / Medium"
            ],
            promotions: [
                "Buy 1 Get 2nd at 50% Off (Limited Time)",
                "Members enjoy 2 free juice vouchers monthly",
                "Leave a review to earn reward points for free drinks"
            ]
        )
    }

    /// 单图预览实例（1 张图，无促销）
    static func previewWithSingleImage() -> ItemDetailViewModel {
        ItemDetailViewModel(
            itemName: "Orange Juice",
            itemPrice: "From $5.00",
            imageURLs: ["orange_juice_1"],
            productDescription: "Made from premium imported oranges, freshly squeezed daily. No added sugar or water \u{2014} just 100% pure juice. Rich in vitamin C and naturally refreshing.",
            tastePreparation: [
                "Flavor Profile: Sweet with a hint of tartness, rich citrus aroma, and smooth texture",
                "Preparation Method: Freshly squeezed to order with pulp and natural fibers retained",
                "Temperature Options: Iced / Room Temperature",
                "Sweetness Levels: No Sugar / Light / Medium"
            ],
            promotions: []
        )
    }
}
