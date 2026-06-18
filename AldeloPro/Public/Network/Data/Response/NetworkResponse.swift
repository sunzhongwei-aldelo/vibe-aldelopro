//
//  NetworkResponse.swift
//  AldeloPro
//
//  Created by Sen on 2026/06/16.
//
//  【文件职责】NetworkResponsable 协议的具体实现。一个只包裹 Data 的轻量值类型，
//  把四种读取形态落地。真实请求和 stub 都产出这个类型，对业务完全透明。
//

import Foundation

/// 响应数据的轻量实现：内部仅持有一段 `Data`，按需变换。
public nonisolated struct NetworkResponse: NetworkResponsable {
    /// 原始字节流（不可变，值语义安全）。
    private let data: Data

    public init(data: Data) {
        self.data = data
    }

    public func toData() -> Data { data }

    public func toString() -> String? {
        String(data: data, encoding: .utf8)
    }

    public func toJson() -> Any? {
        // `.fragmentsAllowed` 允许顶层是标量/字符串（不止字典/数组），兼容更多接口。
        try? JSONSerialization.jsonObject(with: data, options: .fragmentsAllowed)
    }

    public func toModel<T: Decodable & Sendable>(_ type: T.Type) throws -> T {
        let decoder = JSONDecoder()
        // 【关键】自动把服务端 snake_case 字段（order_id）映射到 Swift camelCase 属性（orderId）。
        // 这样模型里写惯用的 camelCase 即可，无需逐字段写 CodingKeys。
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            // 把底层解码错误包装成业务错误，并保留详细原因供日志排查。
            throw NetworkError.decodingFailed(error.localizedDescription)
        }
    }
}
