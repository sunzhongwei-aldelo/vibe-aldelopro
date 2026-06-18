//
//  CashierAuthServiceProtocol.swift
//  AldeloPro
//
//  Created by Sen on 2026/06/04.
//

import Foundation

// MARK: - 收银员认证服务协议

/// 收银员登录认证服务的抽象接口
/// 支持面部识别和密码两种登录方式
/// 由 Data 层提供具体实现
protocol CashierAuthServiceProtocol: Sendable {
    /// 通过面部识别数据进行认证
    /// - Parameter imageData: 摄像头捕获的面部图像数据
    /// - Returns: 认证成功后的收银员会话
    /// - Throws: CashierAuthError
    func authenticateWithFaceID(imageData: Data) async throws -> CashierSession

    /// 通过密码进行认证
    /// - Parameter passcode: 用户输入的密码
    /// - Returns: 认证成功后的收银员会话
    /// - Throws: CashierAuthError
    func authenticateWithPassword(passcode: String) async throws -> CashierSession

    /// 设置收银员开班金额
    /// - Parameters:
    ///   - amount: 开班金额（美元）
    ///   - session: 当前收银员会话
    func setCashierStartAmount(_ amount: Decimal, session: CashierSession) async throws
}

// MARK: - 认证错误枚举

/// 收银员认证过程中可能出现的错误
enum CashierAuthError: Error, Equatable {
    /// 面部无法识别
    case faceNotRecognized
    /// 密码错误
    case invalidPasscode
    /// 网络错误
    case networkError(String)
    /// 摄像头不可用
    case cameraUnavailable
}

// MARK: - Mock 实现（Preview 用）

/// 模拟认证服务，用于 Preview 和测试
final class MockCashierAuthService: CashierAuthServiceProtocol, @unchecked Sendable {
    /// 是否模拟认证失败
    var shouldFail: Bool = false

    func authenticateWithFaceID(imageData: Data) async throws -> CashierSession {
        try await Task.sleep(nanoseconds: 500_000_000)
        if shouldFail { throw CashierAuthError.faceNotRecognized }
        return .preview
    }

    func authenticateWithPassword(passcode: String) async throws -> CashierSession {
        try await Task.sleep(nanoseconds: 300_000_000)
        if shouldFail { throw CashierAuthError.invalidPasscode }
        return .preview
    }

    func setCashierStartAmount(_ amount: Decimal, session: CashierSession) async throws {
        try await Task.sleep(nanoseconds: 300_000_000)
        if shouldFail { throw CashierAuthError.networkError("Mock error") }
    }
}
