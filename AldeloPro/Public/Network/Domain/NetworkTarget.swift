//
//  NetworkTarget.swift
//  AldeloPro
//
//  Created by Sen on 2026/06/16.
//
//  【文件职责】网络框架最核心的"端点契约"。一个遵循 NetworkTarget 的类型，
//  用声明的方式回答"这个请求长什么样"（URL/方法/参数/超时/假数据），
//  而完全不关心"怎么发出去"（那是 NetworkProvider 引擎的事）。
//  这种"描述与执行分离"的设计借鉴自 Moya，是整个框架灵活性的来源。
//

import Foundation

// MARK: - NetworkValidationType

/// 响应状态码验证策略：决定哪些 HTTP 状态码算"成功"。
public nonisolated enum NetworkValidationType: Sendable {
    /// 不校验状态码（任何响应都进入成功分支，由业务自行判断）。
    case none
    /// 只接受 200...299（最常用，符合 RESTful 语义）。
    case successCodes
    /// 自定义合法区间（如某些老接口用 2xx~3xx）。
    case customCodes(ClosedRange<Int>)
}

// MARK: - NetworkStubBehavior

/// 测试桩行为：让请求在**完全离线**下也能返回预设假数据。
///
/// 这是支撑 SwiftUI Previews 完备性、以及单元测试不依赖真实网络的关键开关。
public nonisolated enum NetworkStubBehavior: Sendable {
    /// 走真实物理网络（生产默认）。
    case never
    /// 立即返回 `target.sampleData`。
    case immediate
    /// 延迟 N 秒后返回 `sampleData`，用于模拟弱网、调试骨架屏/Loading 态。
    case delayed(seconds: TimeInterval)
}

// MARK: - NetworkTask

/// 请求任务类型：描述"请求体怎么构造"。覆盖从最简单到最复杂的全部场景。
///
/// 【并发约束】所有关联值都要求 `Sendable`，保证整个 `NetworkTarget` 能安全跨 actor。
public nonisolated enum NetworkTask: Sendable {
    /// 无 Body 的纯请求（默认补 `Content-Type: application/json`）。最简单。
    case requestPlain
    /// 直接上传一段裸二进制（如日志、图片字节流）。
    case requestData(Data)
    /// 标准 JSON：把一个 `Encodable` 模型自动序列化进 Body。最常用。
    case requestJSONEncodable(any Encodable & Sendable)
    /// 自定义 encoder 的 JSON 序列化。
    /// 【为什么是闭包】encoder 通过 `@Sendable () -> JSONEncoder` 工厂提供，
    /// 而不是直接传 `JSONEncoder` 实例——`JSONEncoder` 非 Sendable，直接传会破坏并发安全。
    case requestCustomJSONEncodable(any Encodable & Sendable, encoderProvider: @Sendable () -> JSONEncoder)
    /// 离线脱机（SAF）高机密加密压缩包。实际加密由插件/工具链完成，这里只标记意图。
    case requestEncryptedJSON(any Encodable & Sendable, encryptKey: String, isGzip: Bool)
    /// 字典参数 + 指定编码方式（JSON / Query / Form）。
    case requestParameters(parameters: Parameters, encoding: ParameterEncoding)
    /// 复合参数：URL Query 与 Body 同时存在（如 GET 带 query、又带 JSON body 的老接口）。最复杂。
    case requestCompositeParameters(bodyParameters: Parameters, bodyEncoding: ParameterEncoding, urlParameters: Parameters)
    /// 本地文件按物理路径直接上传。
    case uploadFile(URL)
}

// MARK: - NetworkTarget

/// 声明式网络端点契约。
///
/// 【典型用法】用一个 `enum` 遵循本协议，每个 case 代表一个 API；在计算属性里用
/// `switch self` 分别返回各 API 的 URL/路径/参数等。参见 `NetworkExample.swift`。
///
/// 【依赖红线】Domain 层契约——只能依赖 Foundation 与本模块原生类型，
/// 严禁 import Alamofire / SwiftUI / UIKit。
public nonisolated protocol NetworkTarget: Sendable {
    /// 基础服务器域名。支持多源分流：不同 case 返回不同集群（Base / TMS / ePay）。
    var baseURL: URL { get }
    /// 微服务路由路径（会拼接到 baseURL 之后）。
    var path: String { get }
    /// HTTP 方法。
    var httpMethod: HTTPMethod { get }
    /// 请求任务类型（决定 Body 怎么构造）。
    var task: NetworkTask { get }
    /// 附加请求头（可选，默认 nil）。
    var headers: HTTPHeaders? { get }
    /// 状态码验证策略（默认 `.successCodes`）。
    var validationType: NetworkValidationType { get }
    /// 动态超时（秒）。不同业务可设不同值：登录 15s、撤销 60s、日志上传 120s…
    var timeoutInterval: TimeInterval { get }
    /// 离线假数据，供 stub / Preview / 测试使用（默认空 Data）。
    var sampleData: Data { get }
}

// MARK: - Default Implementations

/// 协议默认实现：让遵循者只需实现必要的几个属性，其余走默认值，降低样板代码。
/// 注意：协议体与其 extension 的隔离是分开的，二者都要标 `nonisolated`。
public nonisolated extension NetworkTarget {
    var headers: HTTPHeaders? { nil }
    var validationType: NetworkValidationType { .successCodes }
    var timeoutInterval: TimeInterval { 30.0 }          // 全局默认 30 秒
    var sampleData: Data { Data() }

    /// 拼装后的完整请求 URL（baseURL + path）。
    /// path 为空时直接用 baseURL，避免多出一个 "/" 尾巴。
    var requestURL: URL {
        guard !path.isEmpty else { return baseURL }
        return baseURL.appendingPathComponent(path)
    }
}
