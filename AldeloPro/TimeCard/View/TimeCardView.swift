//
//  TimeCardView.swift
//  AldeloExpressPro
//
//  Created by jiangxia on 2026/06/05.
//

import SwiftUI

// MARK: - TimeCardView

struct TimeCardView: View {
    // MARK: - Properties

    @State private var viewModel: TimeCardViewModel

    // MARK: - Init

    init(
        employeeName: String,
        employeeRole: String,
        loggedInUserName: String,
        loggedInClockTime: String?,
        onBack: @escaping () -> Void
    ) {
        _viewModel = State(initialValue: TimeCardViewModel(
            employeeName: employeeName,
            employeeRole: employeeRole,
            loggedInUserName: loggedInUserName,
            loggedInClockTime: loggedInClockTime,
            onBack: onBack
        ))
    }

    // MARK: - Body

    var body: some View {
        ZStack {
            AppColors.pageBg
                .ignoresSafeArea()

            VStack(spacing: 0) {
                headerBar
                HStack(spacing: 0) {
                    if viewModel.flowState.hasSidebar {
                        sidebar
                    }
                    TimeCardContentView(viewModel: viewModel)
                }
            }

            if viewModel.showCountdown {
                countdownBadge
            }
        }
        .onAppear { viewModel.onAppear() }
        .onDisappear { viewModel.onDisappear() }
    }

    // MARK: - Header Bar

    private var headerBar: some View {
        HStack(spacing: 0) {
            HStack(spacing: Spacing.xs) {
                Image(systemName: "calendar")
                    .font(.system(size: 24, weight: .medium))
                    .foregroundColor(AppColors.textPrimary)
                Text("Time Card")
                    .font(AppFont.tabletH1Medium)
                    .foregroundColor(AppColors.textPrimary)
            }

            Spacer()

            HStack(spacing: Spacing.md) {
                userInfoSection
                backButton
            }
        }
        .padding(.horizontal, Spacing.lg)
        .frame(height: 80)
        .background(AppColors.pageBgDeep.opacity(0.5))
        .overlay(
            Rectangle()
                .frame(height: 1)
                .foregroundColor(AppColors.line),
            alignment: .bottom
        )
    }

    private var userInfoSection: some View {
        HStack(spacing: Spacing.sm) {
            ZStack {
                Circle()
                    .fill(AppColors.primaryNormal)
                    .frame(width: 40, height: 40)
                Text(String(viewModel.loggedInUserName.prefix(1)))
                    .font(AppFont.tabletH3Medium)
                    .foregroundColor(AppColors.white100)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(viewModel.loggedInUserName)
                    .font(AppFont.tabletH6Medium)
                    .foregroundColor(AppColors.textPrimary)
                if let clockTime = viewModel.loggedInClockTime {
                    Text("Clocked In \(clockTime)")
                        .font(AppFont.tabletBody5Regular)
                        .foregroundColor(AppColors.textSecondary)
                }
            }
        }
    }

    private var backButton: some View {
        Button(action: { viewModel.requestBack() }) {
            Text("Back")
                .font(AppFont.tabletH3Medium)
                .foregroundColor(AppColors.textPrimary)
                .frame(width: 134, height: 48)
                .background(AppColors.buttonSecondaryBg)
                .cornerRadius(AppRadius.Tablet.lg)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Sidebar

    private var sidebar: some View {
        VStack(spacing: Spacing.md) {
            ForEach(TimeCardMenuItem.allCases) { item in
                sidebarItem(item)
            }
            Spacer()
        }
        .padding(Spacing.md)
        .frame(width: 170)
        .frame(maxHeight: .infinity)
        .background(
            RoundedRectangle(cornerRadius: AppRadius.Tablet.lg)
                .fill(AppColors.card.opacity(0.5))
        )
        .padding(.leading, Spacing.md)
        .padding(.vertical, Spacing.md)
    }

    private func sidebarItem(_ item: TimeCardMenuItem) -> some View {
        let isSelected = item == viewModel.flowState.selectedMenuItem
        return Button {
            viewModel.handleSidebarTap(item)
        } label: {
            VStack(spacing: Spacing.xs) {
                Image(systemName: item.iconName)
                    .font(.system(size: 22, weight: .medium))
                    .foregroundColor(AppColors.textPrimary)
                Text(item.rawValue)
                    .font(AppFont.tabletH5Medium)
                    .foregroundColor(AppColors.textPrimary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .frame(maxWidth: .infinity)
        .frame(height: 100)
        .background(
            RoundedRectangle(cornerRadius: AppRadius.Tablet.sm)
                .fill(AppColors.card)
        )
        .overlay(
            RoundedRectangle(cornerRadius: AppRadius.Tablet.sm)
                .stroke(isSelected ? AppColors.primaryNormal : AppColors.buttonStrokeLine, lineWidth: isSelected ? 2 : 1)
        )
    }

    // MARK: - Countdown Badge

    private var countdownBadge: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                CountdownBadge(
                    seconds: viewModel.countdownSeconds,
                    isPaused: viewModel.isPaused,
                    onTogglePause: { viewModel.isPaused.toggle() }
                )
                .padding(.trailing, Spacing.xl)
                .padding(.bottom, Spacing.xl)
            }
        }
    }
}

// MARK: - Preview

#Preview("TimeCard Flow") {
    TimeCardView(
        employeeName: "John Doe",
        employeeRole: "Server",
        loggedInUserName: "Zhang San",
        loggedInClockTime: "12:25 PM",
        onBack: {}
    )
}
