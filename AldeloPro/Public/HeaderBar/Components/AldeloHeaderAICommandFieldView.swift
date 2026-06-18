//
//  AldeloHeaderAICommandFieldView.swift
//  AldeloPro
//
//  Created by Sen on 2026/06/12.
//

import SwiftUI

// MARK: - AldeloHeaderAICommandFieldView
//
// 【作用】
// A 族「工作台栏」(`AldeloDashboardHeaderView`) 中心的 AI 指令 / 搜索胶囊原子，
// 覆盖 `AICommandState` 四种状态（详见 AldeloHeaderModel）。
//
// 【四种状态】
//   • .idle          占位文案 `Say "Hey Aldelo"...` + 空心 mic
//   • .listening     浅底胶囊 + 蓝色流动声波 + 实心 mic（带渐变光晕背景）
//   • .listeningDark 深底胶囊 + 蓝色流动声波 + 实心 mic（带渐变光晕背景）
//   • .typing        `Type to Search...` 异文案 + 斜杠禁用 mic
//
// ⚠️【关键陷阱】（项目记忆 inputbg-white-on-card-trap）
//   shell 背景是 `AppColors.card`（浅色 = #FFFFFF），而 `AppColors.inputBg` 浅色
//   实测也漂移成 #FFFFFF → 若用 inputBg 当胶囊底，浅色下完全隐形。
//   故 idle/typing 底色统一用 `AppColors.buttonSecondaryBg`（浅 #F8F8F8 / 暗 #373737），
//   在白卡 / 暗卡两态都有对比。listeningDark 用 `numpadPanelBg` 深底。
//
// 【设计要点】
// - 声波用 `TimelineView(.animation)` + `Canvas` 画平滑正弦曲线（确定性时间驱动，无随机数，
//   遵守 body 纯函数原则），渐变描边呈现"水彩蓝流动声波"。
// - mic 在 listening 系带浅蓝→浅紫渐变圆形光晕背景。
// - 宽度由父容器决定（`maxWidth:.infinity`）；Dashboard 通过布局引擎按 391/1440 比例居中限定。
//
// 【使用案例】
// ```swift
// // 1) 默认 idle 态
// AldeloHeaderAICommandFieldView(state: .idle)
//
// // 2) 监听态 + 点击回调
// AldeloHeaderAICommandFieldView(state: .listening) {
//     viewModel.startVoiceCommand()
// }
//
// // 3) 输入态（搜索模式）
// AldeloHeaderAICommandFieldView(state: .typing, onTap: { focusSearchField() })
// ```

struct AldeloHeaderAICommandFieldView: View {

    @Environment(\.horizontalSizeClass) private var hSizeClass

    /// 当前 AI 指令栏状态。
    let state: AICommandState
    /// 点击胶囊回调（进入搜索 / 语音）。
    var onTap: (() -> Void)? = nil

    private var isCompact: Bool { hSizeClass == .compact }

    /// 占位文案：typing 态为搜索提示，其余为语音唤醒提示。
    private var placeholder: String {
        switch state {
        case .typing: return "Type to Search/Perform Action with AI..."
        default:      return "Say \"Hey Aldelo\" to talk with Al.."
        }
    }

    var body: some View {
        Button {
            onTap?()
        } label: {
            HStack(spacing: Spacing.xs) {
                content
            }
            .padding(.horizontal, Spacing.md)
            .frame(height: fieldHeight)
            .frame(maxWidth: .infinity)
            .background(background)
            .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }

    private var fieldHeight: CGFloat { isCompact ? 36 : 40 }

    // MARK: 内容分态

    @ViewBuilder
    private var content: some View {
        switch state {
        case .idle, .typing:
            placeholderRow
        case .listening, .listeningDark:
            waveformRow
        }
    }

    /// 占位文案行：文案左 + mic 右。
    private var placeholderRow: some View {
        HStack(spacing: Spacing.xs) {
            Text(placeholder)
                .font(isCompact ? AppFont.mobileBody1Regular : AppFont.tabletBody3Regular)
                .foregroundColor(AppColors.textTertiary)
                .lineLimit(1)
            Spacer(minLength: 0)
            micIcon
        }
    }

    /// 声波行：声波在整条胶囊内水平居中并铺开，mic 固定贴右（trailing overlay）。
    private var waveformRow: some View {
        AldeloHeaderAIWaveformView(isDark: state == .listeningDark)
            .frame(maxWidth: .infinity, alignment: .center)
            .overlay(alignment: .trailing) { micIcon }
    }

    // MARK: mic（带渐变圆形背景）

    private var micIcon: some View {
        Image(systemName: micSymbol)
            .font(isCompact ? AppFont.mobileBody1Medium : AppFont.tabletBody4Regular)
            .foregroundColor(micColor)
            .frame(width: micSize, height: micSize)
            .background(micBackground)
            .clipShape(Circle())
    }

    private var micSize: CGFloat { isCompact ? 28 : 32 }

    /// mic 圆形背景：listening 系显示浅蓝→浅紫渐变光晕；idle/typing 透明。
    @ViewBuilder
    private var micBackground: some View {
        if state.isWaveform {
            LinearGradient(
                colors: [AppColors.theme.opacity(0.18), Color.purple.opacity(0.14)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        } else {
            Color.clear
        }
    }

    /// 麦克风符号按态切换：idle 空心 mic、listening 实心 mic.fill、typing 斜杠 mic.slash。
    private var micSymbol: String {
        switch state {
        case .idle:          return "mic"
        case .typing:        return "mic.slash"
        case .listening:     return "mic.fill"
        case .listeningDark: return "mic.fill"
        }
    }

    private var micColor: Color {
        switch state {
        case .idle:          return AppColors.textSecondary
        case .typing:        return AppColors.textTertiary
        case .listening:     return AppColors.theme
        case .listeningDark: return AppColors.theme
        }
    }

    private var background: Color {
        // listeningDark 用深底胶囊；其余用 buttonSecondaryBg（避开 inputBg 白底隐形陷阱）。
        state == .listeningDark ? AppColors.numpadPanelBg : AppColors.buttonSecondaryBg
    }
}

// MARK: - AldeloHeaderAIWaveformView（平滑流动声波）
//
// 语音可视化波形：两条相位略错开的平滑正弦曲线（中间振幅大、两端收窄），
// 用渐变描边呈现设计图的"水彩蓝流动声波"效果。
// 相位用确定性时间驱动（TimelineView），不使用随机数（遵守 body 纯函数原则）。
// 设为 fileprivate：仅供本文件 AICommandField 使用，避免污染全局命名空间。

private struct AldeloHeaderAIWaveformView: View {
    let isDark: Bool

    var body: some View {
        TimelineView(.animation) { timeline in
            Canvas { context, size in
                let phase = timeline.date.timeIntervalSinceReferenceDate
                draw(in: &context, size: size, phase: phase)
            }
        }
        .frame(maxWidth: 360, maxHeight: 24)
    }

    /// 在 Canvas 上画两条相位略错开的正弦波，渐变描边、两端淡出。
    private func draw(in context: inout GraphicsContext, size: CGSize, phase: Double) {
        let midY = size.height / 2
        let width = size.width
        // 包络：两端低、中间高（sin 半周），让波形呈纺锤形
        func amplitude(at x: Double) -> Double {
            let t = x / width
            return sin(t * .pi) * (size.height * 0.34)
        }
        func wavePath(speed: Double, freq: Double, phaseShift: Double) -> Path {
            var path = Path()
            let step: CGFloat = 2
            var x: CGFloat = 0
            while x <= width {
                let amp = amplitude(at: Double(x))
                let y = midY + CGFloat(sin(Double(x) / width * .pi * freq + phase * speed + phaseShift) * amp)
                if x == 0 { path.move(to: CGPoint(x: x, y: y)) }
                else { path.addLine(to: CGPoint(x: x, y: y)) }
                x += step
            }
            return path
        }

        // 横向渐变：两端透明、中间最实，营造淡入淡出
        let gradient = GraphicsContext.Shading.linearGradient(
            Gradient(colors: [
                AppColors.theme.opacity(0.0),
                AppColors.theme.opacity(isDark ? 0.95 : 0.85),
                AppColors.theme.opacity(0.55),
                AppColors.theme.opacity(0.0)
            ]),
            startPoint: CGPoint(x: 0, y: midY),
            endPoint: CGPoint(x: width, y: midY)
        )
        context.stroke(wavePath(speed: 2.2, freq: 3, phaseShift: 0), with: gradient,
                       style: StrokeStyle(lineWidth: 2, lineCap: .round))
        context.stroke(wavePath(speed: 1.6, freq: 4, phaseShift: 1.2),
                       with: gradient,
                       style: StrokeStyle(lineWidth: 1.5, lineCap: .round))
    }
}
