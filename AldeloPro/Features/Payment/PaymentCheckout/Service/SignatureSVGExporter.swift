import Foundation
import CoreGraphics

// MARK: - 签名 SVG 导出服务
/// 将签名笔画数据转换为 SVG 字符串
/// 逻辑参考原 SVGTool，但使用纯 Foundation 实现
/// ❌ 不导入 SwiftUI
struct SignatureSVGExporter {

    // MARK: - 公开方法

    /// 将笔画路径导出为 Base64 编码的 SVG 字符串
    /// - Parameters:
    ///   - strokes: 所有笔画（每个笔画为一组 CGPoint）
    ///   - canvasSize: 原始画布尺寸
    ///   - targetSize: 目标缩放尺寸（为 nil 则不缩放）
    /// - Returns: Base64 编码的 SVG 字符串（可直接上传服务端）
    static func export(
        strokes: [[CGPoint]],
        canvasSize: CGSize,
        targetSize: CGSize? = nil
    ) -> String {
        guard !strokes.isEmpty else { return "" }

        // 计算缩放比例
        let scaleX: CGFloat
        let scaleY: CGFloat
        if let target = targetSize, canvasSize.width > 0, canvasSize.height > 0 {
            scaleX = target.width / canvasSize.width
            scaleY = target.height / canvasSize.height
        } else {
            scaleX = 1.0
            scaleY = 1.0
        }

        // 生成 SVG path 并计算边界
        var paths: [String] = []
        var minX: CGFloat = .greatestFiniteMagnitude
        var minY: CGFloat = .greatestFiniteMagnitude
        var maxX: CGFloat = 0
        var maxY: CGFloat = 0

        for stroke in strokes {
            guard stroke.count > 1 else { continue }
            var svgPath = ""
            for (index, point) in stroke.enumerated() {
                let x = point.x * scaleX
                let y = point.y * scaleY

                minX = min(minX, x - 5)
                minY = min(minY, y - 5)
                maxX = max(maxX, x + 5)
                maxY = max(maxY, y + 5)

                if index == 0 {
                    svgPath += "M \(Int(x)) \(Int(y)) "
                } else {
                    svgPath += "L \(Int(x)) \(Int(y)) "
                }
            }
            let pathElement = "<path d=\"\(svgPath)\" fill=\"none\" stroke=\"#000000\" stroke-width=\"2.5\" stroke-linecap=\"round\" stroke-linejoin=\"round\"/>"
            paths.append(pathElement)
        }

        guard !paths.isEmpty else { return "" }

        // 组装 SVG
        let width = Int(maxX - minX)
        let height = Int(maxY - minY)
        let viewBox = "\(Int(minX)) \(Int(minY)) \(width) \(height)"

        let svg = """
        <svg xmlns="http://www.w3.org/2000/svg" width="\(width)" height="\(height)" viewBox="\(viewBox)">
        \(paths.joined(separator: "\n"))
        </svg>
        """

        // 转 Base64（实际项目中可加 gzip 压缩）
        guard let data = svg.data(using: .utf8) else { return "" }
        return data.base64EncodedString()
    }
}
