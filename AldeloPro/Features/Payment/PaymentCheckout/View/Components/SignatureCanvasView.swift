import SwiftUI

// MARK: - 签名画布
/// 用 Canvas + DragGesture 实现手写签名
/// 支持 Dark Mode（暗黑下笔画白色）
struct SignatureCanvasView: View {
    /// 签名状态 ViewModel
    @Bindable var viewModel: SignatureCanvasViewModel

    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        Canvas { context, size in
            // 保存画布尺寸（用于 SVG 导出）
            DispatchQueue.main.async {
                viewModel.canvasSize = size
            }

            let strokeColor = signatureColor
            let lineWidth: CGFloat = 2.5

            // 绘制已完成的笔画
            for stroke in viewModel.strokes {
                drawStroke(context: &context, points: stroke, color: strokeColor, width: lineWidth)
            }

            // 绘制当前正在画的笔画
            if !viewModel.currentStroke.isEmpty {
                drawStroke(context: &context, points: viewModel.currentStroke, color: strokeColor, width: lineWidth)
            }
        }
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { value in
                    let point = value.location
                    if value.translation == .zero {
                        viewModel.beginStroke(at: point)
                    } else {
                        viewModel.addPoint(point)
                    }
                }
                .onEnded { _ in
                    viewModel.endStroke()
                }
        )
    }

    // MARK: - 绘制笔画

    private func drawStroke(
        context: inout GraphicsContext,
        points: [CGPoint],
        color: Color,
        width: CGFloat
    ) {
        guard points.count > 1 else { return }
        var path = Path()
        path.move(to: points[0])
        for i in 1..<points.count {
            path.addLine(to: points[i])
        }
        context.stroke(path, with: .color(color), lineWidth: width)
    }

    /// 签名颜色：亮色模式黑色，暗黑模式白色
    private var signatureColor: Color {
        colorScheme == .dark ? AppColors.white100 : AppColors.textEmphasis
    }
}
