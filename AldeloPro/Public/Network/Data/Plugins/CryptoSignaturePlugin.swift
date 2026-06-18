//
//  CryptoSignaturePlugin.swift
//  AldeloPro
//
//  Created by Sen on 2026/06/16.
//
//  【文件职责】第二个 AOP 插件示例：对请求体做防篡改签名。
//  演示插件如何读取"前一个插件已加工过的 httpBody"——因为 NetworkProvider 是
//  按数组顺序依次调用插件的 prepare，所以本插件能拿到 DeviceFingerprintPlugin 等
//  之前插件处理后的最新请求状态。这就是 AOP 管道的"链式"价值。
//

import Foundation
#if canImport(CryptoKit)
import CryptoKit
#endif

/// 签名插件：对 httpBody 计算摘要并装配 `pk` / `sign` / `rid` 安全头。
///
/// 兼容旧框架 `body.sign()` 规则：即便 httpBody 为空（如 GET 请求），
/// 也对空 `Data()` 计算签名，保证服务端始终能拿到一致的签名字段。
public nonisolated final class CryptoSignaturePlugin: NetworkPlugin {

    private let publicKeyToken: String

    /// - Parameter publicKeyToken: 本地公钥令牌，随签名一起上送，供服务端验签。
    public init(publicKeyToken: String = "ALDELO_LOCAL_PUBLIC_KEY_TOKEN") {
        self.publicKeyToken = publicKeyToken
    }

    /// 起飞前钩子：取当前 body → 算签名 → 写入安全头。
    public func prepare(_ request: URLRequest, target: any NetworkTarget) -> URLRequest {
        var mutableRequest = request

        let bodyData = mutableRequest.httpBody ?? Data()   // body 为空也照常签名（对空 Data）
        let signature = Self.sign(bodyData)
        let requestID = UUID().uuidString.lowercased()      // 每请求唯一 ID，便于链路追踪/幂等

        mutableRequest.setValue(publicKeyToken, forHTTPHeaderField: "pk")    // public key
        mutableRequest.setValue(signature, forHTTPHeaderField: "sign")      // 签名摘要
        mutableRequest.setValue(requestID, forHTTPHeaderField: "rid")       // request id

        return mutableRequest
    }

    /// 生成防篡改指纹签名。
    ///
    /// 默认用 CryptoKit 的 SHA-256（密码学强度）；万一目标平台无 CryptoKit，
    /// 用 `#if` 降级为 base64（仅占位，非密码学强度）——保证框架在任何平台都能编译。
    private static func sign(_ data: Data) -> String {
        #if canImport(CryptoKit)
        let digest = SHA256.hash(data: data)
        return digest.map { String(format: "%02x", $0) }.joined()   // 转十六进制串
        #else
        return data.base64EncodedString()
        #endif
    }
}
