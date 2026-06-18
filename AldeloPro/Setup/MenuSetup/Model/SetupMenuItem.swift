//
//  SetupMenuItem.swift
//  AldeloPro
//
//  Created by jiangxia on 2026/06/08.
//

import Foundation

/// 菜单项目（如 "Cheese Burger"）
struct SetupMenuItem: Identifiable, Equatable, Sendable {
    let id: UUID
    var name: String
    var groupId: UUID
    var unitPrice: Decimal
    var optionGroups: [OptionGroup]
    var taxClass: TaxClass
    var imageData: [Data]
    /// imageData 中作为封面的下标；nil 表示未指定封面。
    var coverImageIndex: Int?
    var productionFacingName: String
    var attributes: [String]
    var estimatedPrepareTime: Int?
    var nutrition: NutritionInfo
    var sortOrder: Int

    init(
        id: UUID = UUID(),
        name: String,
        groupId: UUID,
        unitPrice: Decimal = 0,
        optionGroups: [OptionGroup] = [],
        taxClass: TaxClass = .standard,
        imageData: [Data] = [],
        coverImageIndex: Int? = nil,
        productionFacingName: String = "",
        attributes: [String] = [],
        estimatedPrepareTime: Int? = nil,
        nutrition: NutritionInfo = NutritionInfo(),
        sortOrder: Int = 0
    ) {
        self.id = id
        self.name = name
        self.groupId = groupId
        self.unitPrice = unitPrice
        self.optionGroups = optionGroups
        self.taxClass = taxClass
        self.imageData = imageData
        self.coverImageIndex = coverImageIndex
        self.productionFacingName = productionFacingName
        self.attributes = attributes
        self.estimatedPrepareTime = estimatedPrepareTime
        self.nutrition = nutrition
        self.sortOrder = sortOrder
    }

    /// 作为封面展示的图片数据：优先 coverImageIndex，否则首张；越界返回首张，无图返回 nil。
    var coverImageData: Data? {
        guard !imageData.isEmpty else { return nil }
        let index = coverImageIndex ?? 0
        guard imageData.indices.contains(index) else { return imageData.first }
        return imageData[index]
    }
}

// MARK: - Tax Class

/// 税率分类
enum TaxClass: String, CaseIterable, Sendable {
    case none = "None"
    case standard = "Standard"
    case exempt = "Exempt"
    case reduced = "Reduced"
    case alcohol = "Alcohol"
    case takeout = "Takeout"
}

// MARK: - Nutrition Info

/// 营养信息
struct NutritionInfo: Equatable, Sendable {
    var calories: Double?
    var fat: Double?
    var carbohydrates: Double?
    var sugar: Double?
    var protein: Double?

    init(
        calories: Double? = nil,
        fat: Double? = nil,
        carbohydrates: Double? = nil,
        sugar: Double? = nil,
        protein: Double? = nil
    ) {
        self.calories = calories
        self.fat = fat
        self.carbohydrates = carbohydrates
        self.sugar = sugar
        self.protein = protein
    }
}
