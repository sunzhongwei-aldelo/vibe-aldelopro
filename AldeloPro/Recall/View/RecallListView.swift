//
//  RecallListView.swift
//  AldeloPro
//
//  Created by wanghui on 2026/06/08.
//

import SwiftUI

struct RecallListView: View {
    @State private var viewModel = RecallListViewModel()
    @State private var isScrolling = false
    @State private var gradientOpacity: Double = 0
    @State private var lastOffset: CGFloat = 0
    @State private var hideTask: Task<Void, Never>?

    private let columns = [
        GridItem(.flexible(), spacing: Spacing.md),
        GridItem(.flexible(), spacing: Spacing.md)
    ]

    var body: some View {
        ZStack(alignment: .top) {
            ScrollView {
                VStack(spacing: 0) {
                    scrollDetector
                    
                    LazyVGrid(columns: columns, spacing: Spacing.md) {
                        ForEach(viewModel.orders) { order in
                            OrderCardView(
                                order: order,
                                isSelected: viewModel.selectedOrderId == order.id
                            )
                            .frame(height: 200)
                            .onTapGesture {
                                viewModel.selectOrder(order)
                            }
                        }
                    }
                    .padding(Spacing.md)
                }
            }

            LinearGradient(
                stops: [
                    .init(color: Color(hex: "#F4F8FF"), location: 0),
                    .init(color: Color(hex: "#F4F8FF").opacity(0), location: 1)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 60)
            .opacity(gradientOpacity)
            .allowsHitTesting(false)
        }
        .onChange(of: isScrolling) { _, newValue in
            withAnimation(.easeInOut(duration: newValue ? 0.2 : 0.4)) {
                gradientOpacity = newValue ? 1 : 0
            }
        }
        .background(AppColors.pageBg)
        .task {
            viewModel.loadDemoOrders()
        }
    }

    private var scrollDetector: some View {
        GeometryReader { geo in
            Color.clear
                .preference(key: ScrollOffsetKey.self, value: geo.frame(in: .named("scroll")).minY)
        }
        .frame(height: 0)
        .onPreferenceChange(ScrollOffsetKey.self) { value in
            let delta = abs(value - lastOffset)
            lastOffset = value
            guard delta > 0.5 else { return }

            if isScrolling == false {
                isScrolling = true
            }

            hideTask?.cancel()
            hideTask = Task {
                try? await Task.sleep(for: .milliseconds(300))
                if Task.isCancelled == false {
                    isScrolling = false
                }
            }
        }
    }
}

private struct ScrollOffsetKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

#Preview {
    RecallListView().padding(.vertical, 50)
}
