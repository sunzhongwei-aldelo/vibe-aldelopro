//
//  CountdownBadge.swift
//  AldeloPro
//
//  Created by Sen on 2026/06/05.
//

import SwiftUI

// MARK: - 倒计时胶囊
/// 通用倒计时指示器（Public 组件）
/// 白底圆角胶囊 + 计时器图标 + 秒数
/// 点击可暂停/恢复倒计时
///
/// 支持两种模式：
/// 1. 外部驱动：传入 seconds/isPaused/onTogglePause（父级 ViewModel 管理计时器）
/// 2. 自驱动：传入 totalSeconds + onExpire，组件内部管理 Timer
struct CountdownBadge: View {
    /// 剩余秒数（外部驱动模式）
    let seconds: Int
    /// 是否已暂停
    let isPaused: Bool
    /// 点击切换暂停/恢复
    let onTogglePause: () -> Void

    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        Button(action: onTogglePause) {
            HStack(spacing: Spacing.xxs) {
                Image(systemName: isPaused ? "play.circle" : "timer")
                    .font(.system(size: 14, weight: .medium))
                Text("\(seconds)s")
                    .font(AppFont.tabletCaption1Regular)
            }
            .foregroundColor(textColor)
            .padding(.horizontal, Spacing.sm)
            .padding(.vertical, Spacing.xs)
            .background(bgColor)
            .clipShape(Capsule())
            .overlay(
                Capsule().stroke(AppColors.line, lineWidth: 0.5)
            )
        }
        .buttonStyle(.plain)
    }

    private var textColor: Color {
        colorScheme == .dark ? AppColors.white100 : AppColors.textPrimary
    }

    private var bgColor: Color {
        colorScheme == .dark ? AppColors.card : AppColors.white100
    }
}

// MARK: - Self-Driving Countdown Badge

/// 自驱动倒计时胶囊 — 内部管理 Timer，归零时触发 onExpire
/// 适用于 SignOut Success 等不需要外部 ViewModel 管理计时的场景
struct SelfDrivingCountdownBadge: View {
    let totalSeconds: Int
    let onExpire: () -> Void

    @State private var remaining: Int
    @State private var isPaused: Bool = false
    @State private var timer: Timer?

    init(totalSeconds: Int = 10, onExpire: @escaping () -> Void) {
        self.totalSeconds = totalSeconds
        self.onExpire = onExpire
        _remaining = State(initialValue: totalSeconds)
    }

    var body: some View {
        CountdownBadge(
            seconds: remaining,
            isPaused: isPaused,
            onTogglePause: togglePause
        )
        .onAppear { startTimer() }
        .onDisappear { stopTimer() }
    }

    private func togglePause() {
        if isPaused {
            isPaused = false
            startTimer()
        } else {
            isPaused = true
            stopTimer()
        }
    }

    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            Task { @MainActor in
                guard !isPaused else { return }
                if remaining > 0 {
                    remaining -= 1
                }
                if remaining <= 0 {
                    stopTimer()
                    onExpire()
                }
            }
        }
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
}
