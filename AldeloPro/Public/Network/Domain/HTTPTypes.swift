//
//  HTTPTypes.swift
//  AldeloPro
//
//  Created by Sen on 2026/06/16.
//
//  【文件职责】Domain 层的原生 HTTP 基础类型集合。
//  为什么要自己定义这些类型，而不直接用 Alamofire 的同名类型？
//    1. CLAUDE.md 硬红线：Domain 层禁止 import 任何网络框架（Alamofire/UIKit）。
//    2. 解耦：业务契约不绑定第三方库，将来换底层库（URLSession/其它）时 Domain 层零改动。
//    3. 并发安全：这些类型全部 `Sendable`，可安全跨 actor 传递（Alamofire 旧类型未必满足）。
//

import Foundation

// MARK: - HTTPMethod

/// 原生 HTTP 请求方法枚举。
///
/// `rawValue` 即标准方法名（"GET"/"POST"…），桥接 `URLRequest.httpMethod` 时直接取用。
/// 标记 `nonisolated`：本项目默认 `@MainActor` 隔离，但 HTTP 方法是纯值语义、与 UI 无关，
/// 必须脱离主线程隔离，否则在 `actor NetworkProvider` 内访问会报并发警告。
public nonisolated enum HTTPMethod: String, Sendable, Hashable {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case patch = "PATCH"
    case delete = "DELETE"
    case head = "HEAD"
    case options = "OPTIONS"
}

// MARK: - HTTPHeaders

/// 轻量化、值语义、`Sendable` 的请求头集合。
///
/// 【设计要点】HTTP 规范规定 header field name **大小写不敏感**（`Content-Type` == `content-type`）。
/// 本类型内部以小写 key 归一化存储，避免同一个 header 因大小写不同被重复写入两次。
public nonisolated struct HTTPHeaders: Sendable, Hashable, ExpressibleByDictionaryLiteral {
    /// 归一化存储：key = 小写 field name；value = (保留原始大小写的名字, 值)。
    /// 保留原始名是为了导出 `dictionary` 时还原用户书写的形态（如 `Content-Type`）。
    private var storage: [String: (name: String, value: String)]

    /// 创建空 header 集合。
    public init() {
        self.storage = [:]
    }

    /// 从普通字典创建（自动按小写归一化）。
    public init(_ dictionary: [String: String]) {
        self.storage = [:]
        for (name, value) in dictionary {
            storage[name.lowercased()] = (name, value)
        }
    }

    /// 支持字典字面量语法糖：`["Accept": "application/json"]`。
    public init(dictionaryLiteral elements: (String, String)...) {
        self.storage = [:]
        for (name, value) in elements {
            storage[name.lowercased()] = (name, value)
        }
    }

    /// 原地设置（覆盖）一个 header。
    public mutating func update(name: String, value: String) {
        storage[name.lowercased()] = (name, value)
    }

    /// 不可变更新：返回追加/覆盖指定 header 后的**新副本**，不改动自身。
    /// 遵循 CLAUDE.md 的不可变规范——优先返回新值而非原地 mutate。
    public func updating(name: String, value: String) -> HTTPHeaders {
        var copy = self
        copy.update(name: name, value: value)
        return copy
    }

    /// 读取指定 header 的值（大小写不敏感）。
    public func value(for name: String) -> String? {
        storage[name.lowercased()]?.value
    }

    /// 导出为普通字典（保留原始大小写的 field name），供桥接到 `URLRequest` 使用。
    public var dictionary: [String: String] {
        var result: [String: String] = [:]
        for (_, entry) in storage {
            result[entry.name] = entry.value
        }
        return result
    }

    /// 是否为空。
    public var isEmpty: Bool { storage.isEmpty }

    // MARK: Hashable
    // 相等性/哈希都基于归一化后的 (name, value)，与插入顺序无关——
    // 两个内容相同但书写顺序不同的 header 集合应被视为相等。

    public static func == (lhs: HTTPHeaders, rhs: HTTPHeaders) -> Bool {
        lhs.dictionary == rhs.dictionary
    }

    public func hash(into hasher: inout Hasher) {
        for key in storage.keys.sorted() {       // 先排序，保证哈希与顺序无关
            hasher.combine(key)
            hasher.combine(storage[key]?.value)
        }
    }
}

// MARK: - Parameters

/// 请求参数字典。
///
/// 【关键约束】值类型是 `any Sendable`，而不是 Alamofire `Parameters` 的 `[String: Any]`。
/// 原因：参数会随 `NetworkTask` 一起跨 actor 边界传递，`Any` 不满足 Swift 6 并发安全，
/// 会直接编译报错。常见可放入的值：`String` / `Int` / `Double` / `Bool` /
/// `[any Sendable]` / `[String: any Sendable]`。
public typealias Parameters = [String: any Sendable]

// MARK: - ParameterEncoding

/// 参数编码策略（Foundation 原生实现，覆盖三种主流场景）。
///
/// 【为什么用 enum 而非协议】Alamofire 的 `ParameterEncoding` 是协议类型，
/// 一旦在 `NetworkTask` 关联值里使用就会把 Alamofire 依赖传染进 Domain 层。
/// 用枚举既能 `Sendable`、又能作为关联值携带，彻底切断依赖。
public nonisolated enum ParameterEncoding: Sendable {
    /// JSON Body：参数序列化为 JSON 写入 httpBody，`Content-Type: application/json`。
    case json
    /// URL Query：参数拼接到 URL 的查询串（`?a=1&b=2`），常用于 GET。
    case urlQuery
    /// 表单编码：`application/x-www-form-urlencoded`，参数写入 httpBody。
    case urlForm
}
