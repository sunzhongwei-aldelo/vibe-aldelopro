//
//  CashierSession.swift
//  AldeloPro
//
//  Created by Sen on 2026/06/04.
//

import Foundation

// MARK: - 收银员会话实体

/// 收银员登录成功后的会话信息
/// 包含员工基本信息和打卡时间
struct CashierSession: Identifiable, Equatable, Sendable {
    /// 唯一标识
    let id: String
    /// 员工姓名
    let employeeName: String
    /// 员工职位
    let employeeRole: String
    /// 头像 URL（可选）
    let avatarURL: String?
    /// 打卡时间
    let clockedInTime: Date
}

// MARK: - 登录方式枚举

/// 收银员登录方式
/// - faceID: AI 面部识别登录
/// - password: 密码登录
enum CashierLoginMethod: String, Sendable {
    /// AI 面部识别
    case faceID
    /// 密码输入
    case password
}

// MARK: - Preview 辅助数据

extension CashierSession {
    /// Preview 用的模拟会话数据
    static let preview = CashierSession(
        id: "preview-001",
        employeeName: "John Smith",
        employeeRole: "Manager",
        avatarURL: nil,
        clockedInTime: .now
    )
}
