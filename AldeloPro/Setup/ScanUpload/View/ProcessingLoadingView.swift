//
//  ProcessingLoadingView.swift
//  AldeloPro
//
//  Created by wanghui on 2026/06/08.
//

import SwiftUI

struct ProcessingLoadingView: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    // MARK: - Properties

    var message: String = "Document Processing By AI..."

    // MARK: - State

    @State private var isAnimating = false

    // MARK: - Body

    var body: some View {
        ZStack {
            // Semi-transparent background
            Color.black.opacity(0.4)
                .ignoresSafeArea()

            // Loading card
            VStack(spacing: Spacing.lg) {
                // Dot animation
                DotLoadingAnimation(isAnimating: isAnimating)
                    .frame(width: 80, height: 80)

                Text(message)
                    .font(AppFont.tabletH3Medium)
                    .foregroundColor(AppColors.textPrimary)
            }
            .frame(width: horizontalSizeClass == .compact ? 300 : 450)
            .padding(.vertical, horizontalSizeClass == .compact ? Spacing.md : Spacing.xl)
            .background(AppColors.card)
            .cornerRadius(AppRadius.Tablet.md)
            .shadow(color: Color.black.opacity(0.1), radius: 20, x: 0, y: 4)
        }
        .onAppear {
            isAnimating = true
        }
    }
}

// MARK: - Dot Loading Animation

private struct DotLoadingAnimation: View {

    var isAnimating: Bool

    @State private var rotation: Double = 0

    var body: some View {
        ZStack {
            ForEach(0..<8, id: \.self) { index in
                Circle()
                    .fill(AppColors.primaryNormal)
                    .frame(width: dotSize(for: index), height: dotSize(for: index))
                    .offset(y: -28)
                    .rotationEffect(.degrees(Double(index) * 45))
                    .opacity(dotOpacity(for: index))
            }
        }
        .rotationEffect(.degrees(rotation))
        .onChange(of: isAnimating) { _, newValue in
            if newValue {
                withAnimation(
                    .linear(duration: 1.0)
                    .repeatForever(autoreverses: false)
                ) {
                    rotation = 360
                }
            }
        }
    }

    private func dotSize(for index: Int) -> CGFloat {
        let sizes: [CGFloat] = [10, 9, 8, 7, 6, 5, 5, 5]
        return sizes[index]
    }

    private func dotOpacity(for index: Int) -> Double {
        let opacities: [Double] = [1.0, 0.9, 0.8, 0.7, 0.5, 0.4, 0.3, 0.2]
        return opacities[index]
    }
}

// MARK: - Preview

#Preview {
    ProcessingLoadingView()
}
