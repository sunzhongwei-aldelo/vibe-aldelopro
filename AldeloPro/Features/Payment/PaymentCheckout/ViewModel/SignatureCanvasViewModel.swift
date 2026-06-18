import Foundation
import CoreGraphics

// MARK: - 签名画布 ViewModel
/// 管理签名绘制的笔画数据
/// 不导入 SwiftUI，保持纯数据逻辑
@Observable
final class SignatureCanvasViewModel {
    // MARK: - 状态

    /// 所有已完成的笔画（每个笔画是一组点）
    private(set) var strokes: [[CGPoint]] = []
    /// 当前正在绘制的笔画
    private(set) var currentStroke: [CGPoint] = []
    /// 画布尺寸（用于导出 SVG 时缩放）
    var canvasSize: CGSize = .zero

    // MARK: - 计算属性

    /// 是否有签名内容
    var hasContent: Bool {
        !strokes.isEmpty || !currentStroke.isEmpty
    }

    // MARK: - 操作

    /// 开始新笔画
    func beginStroke(at point: CGPoint) {
        currentStroke = [point]
    }

    /// 追加点到当前笔画
    func addPoint(_ point: CGPoint) {
        currentStroke.append(point)
    }

    /// 结束当前笔画
    func endStroke() {
        guard currentStroke.count > 1 else {
            currentStroke.removeAll()
            return
        }
        strokes.append(currentStroke)
        currentStroke.removeAll()
    }

    /// 清除所有笔画
    func clear() {
        strokes.removeAll()
        currentStroke.removeAll()
    }
}
