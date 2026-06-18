//
//  NetworkResponsable.swift
//  AldeloPro
//
//  Created by Sen on 2026/06/16.
//
//  【文件职责】响应数据的"柔性变换"契约。把"拿到一坨字节流后怎么解读"
//  抽象成协议：业务层只面向这个协议编程，不关心底层是 Alamofire 还是 stub 返回的数据，
//  从而实现真实网络 ↔ 测试桩的无缝热插拔。
//

import Foundation

/// 响应数据变换契约：同一份字节流，提供四种读取形态。
///
/// 业务 Repository 只依赖本协议（而非具体类型），因此 stub 假数据和真实响应
/// 对业务而言完全一致——这是可测试性的基石。
public nonisolated protocol NetworkResponsable: Sendable {
    /// 原始响应字节流（最底层，其它三个方法都基于它）。
    func toData() -> Data
    /// 转 UTF-8 字符串；非 UTF-8 编码时返回 nil。
    func toString() -> String?
    /// 转松散 JSON 对象（字典/数组/标量）；解析失败返回 nil。适合临时探查结构。
    func toJson() -> Any?
    /// 转强类型模型。失败抛 `NetworkError.decodingFailed`。生产代码首选这个。
    ///
    /// 约束 `T: Decodable & Sendable`：因为本方法常在 `actor` 内被调用，
    /// 解码结果要能安全跨 actor 返回，故要求 `Sendable`。
    func toModel<T: Decodable & Sendable>(_ type: T.Type) throws -> T
}
