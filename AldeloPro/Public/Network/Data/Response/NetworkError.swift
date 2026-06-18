//
//  NetworkError.swift
//  AldeloPro
//
//  Created by Sen on 2026/06/16.
//
//  【文件职责】全框架统一的网络异常枚举。
//  设计目标：对工程提供"精确分类"（每种失败一个 case，便于 switch 处理），
//  对 UI 提供"中文友好文案"（实现 LocalizedError，直接 error.localizedDescription 弹窗）。
//

import Foundation

/// 网络异常统一枚举。
///
/// `LocalizedError` 的 `errorDescription` 返回面向收银员的中文提示，可直接展示。
public nonisolated enum NetworkError: Error, LocalizedError, Sendable {
    /// 无网络连接（本地局域网/Wi-Fi 断开）。
    case noNetwork
    /// 请求参数编码失败（JSON 序列化等环节出错）。
    case encodingFailed
    /// 任务被取消（协同取消：视图 dismiss、Task 被 cancel）。
    case taskCanceled
    /// 请求构建非法（如 URL 拼装失败）。
    case invalidRequest
    /// 400：请求参数有误。
    case badRequest
    /// 401：未授权（令牌过期）。
    case unauthorized
    /// 403：禁止访问（无权限）。
    case forbidden
    /// 404：资源不存在。
    case notFound
    /// 5xx 或携带服务端错误回显的失败。`message` 优先用服务端下发的文案。
    case serverError(statusCode: Int, message: String)
    /// 模型反序列化失败。关联值为底层 Decoder 的详细原因（便于排查字段不匹配）。
    case decodingFailed(String)
    /// 底层依赖缺失——目前专指"尚未引入 Alamofire"。
    /// 引入依赖后 `#if canImport(Alamofire)` 真实分支启用，此 case 自然不再触发。
    case dependencyMissing(String)
    /// 兜底未知错误。
    case unknown(String)

    /// 面向 UI 的本地化中文文案。`Text(error.localizedDescription)` 即可展示。
    public var errorDescription: String? {
        switch self {
        case .noNetwork:
            return "收银机硬件网络不通，请检查本地局域网状态"
        case .encodingFailed:
            return "请求参数编码失败"
        case .taskCanceled:
            return "请求任务已安全取消"
        case .invalidRequest:
            return "网络请求构建非法，请检查端点配置"
        case .badRequest:
            return "请求参数有误（400）"
        case .unauthorized:
            return "授权令牌已过期，请重新刷卡登录"
        case .forbidden:
            return "无权限访问该资源（403）"
        case .notFound:
            return "请求的资源不存在（404）"
        case let .serverError(_, message):
            return message                          // 直接透传服务端文案
        case .decodingFailed:
            return "数据反序列化失败"                 // 对用户隐藏技术细节，细节在关联值里供日志用
        case let .dependencyMissing(name):
            return "网络底层依赖未引入：\(name)，请先集成后重试"
        case let .unknown(message):
            return message.isEmpty ? "未知的网络交互异常，请稍后重试" : message
        }
    }
}
