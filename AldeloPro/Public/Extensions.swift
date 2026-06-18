//
//  Extensions.swift
//  AldeloPro
//
//  Created by wanghui on 2026/06/12.
//

import Foundation

// MARK: - String Validation
//
// 标记为 nonisolated：本工程默认 MainActor 隔离，若不显式声明，这些纯函数会被
// 隐式 main-actor 隔离，从而无法作为非隔离闭包（如 FormTextField.validate）传递。

extension String {

    /// 是否为合法邮箱格式
    nonisolated var isValidEmail: Bool {
        let pattern = #"^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$"#
        return range(of: pattern, options: .regularExpression) != nil
    }

    /// 是否为合法电话号码（允许数字、空格、+、-、括号；纯数字位数 7~15）
    nonisolated var isValidPhoneNumber: Bool {
        let digits = filter(\.isNumber)
        guard (7...15).contains(digits.count) else { return false }
        let pattern = #"^[0-9+\-()\s]+$"#
        return range(of: pattern, options: .regularExpression) != nil
    }
}

// MARK: - Field Validators

/// 表单字段失焦校验器。
/// 返回错误文案；返回 nil 表示通过。空字符串一律视为「可选、通过」，
/// 是否必填由字段自身的 `isRequired` 另行处理。
/// 全部 nonisolated，可作为非隔离闭包传给 View 组件。
enum FieldValidator {

    /// 邮箱校验：非空时必须为合法邮箱格式
    nonisolated static func email(_ text: String) -> String? {
        if text.isEmpty { return nil }
        return text.isValidEmail ? nil : "Please enter a valid email address."
    }

    /// 电话校验：非空时必须为合法电话格式
    nonisolated static func phone(_ text: String) -> String? {
        if text.isEmpty { return nil }
        return text.isValidPhoneNumber ? nil : "Please enter a valid phone number."
    }
}
