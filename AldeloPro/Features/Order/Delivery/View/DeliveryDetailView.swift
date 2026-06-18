//
//  DeliveryDetailView.swift
//  AldeloPro
//
//  Created by Sen on 2026/06/05.
//

import SwiftUI

// MARK: - 配送详情主页面


/// 外卖配送详情的完整页面容器
/// iPad：弹窗模态卡片展示；iPhone：全屏导航压栈
/// 内含地图、信息段落、时间线三大板块
struct DeliveryDetailView: View {

    // MARK: - Environment

    @Environment(\.dismiss) private var dismiss
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.verticalSizeClass) private var verticalSizeClass

    // MARK: - ViewModel

    @State private var viewModel: DeliveryDetailViewModel

    // MARK: - Init

    init(viewModel: DeliveryDetailViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    // MARK: - Computed

    private var isPad: Bool {
        horizontalSizeClass == .regular
    }

    private var isPhonePortrait: Bool {
        horizontalSizeClass == .compact && verticalSizeClass == .regular
    }

    // MARK: - Body

    var body: some View {
        if isPad {
            padLayout
        } else {
            phoneLayout
        }
    }

    // MARK: - iPad Layout (Modal Card)

    private var padLayout: some View {
        ZStack {
            AppColors.mask
                .ignoresSafeArea()
                .onTapGesture { dismiss() }

            VStack(alignment: .leading, spacing: 0) {
                headerSection
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 0) {
                        mapSection
                        statusSummaryWide
                        timelineSection
                        infoSection
                    }
                }
            }
            .padding(Spacing.lg)
            .frame(maxWidth: 900, maxHeight: 700)
            .background(AppColors.card)
            .clipShape(RoundedRectangle(cornerRadius: AppRadius.Tablet.lg))
            .shadow(color: AppColors.black20, radius: 16, x: 0, y: 4)
        }
    }

    // MARK: - iPhone Layout (Full Screen)

    private var phoneLayout: some View {
        VStack(spacing: 0) {
            headerSection
                .padding(.horizontal, Spacing.md)
                .padding(.top, Spacing.sm)

            if isPhonePortrait {
                phonePortraitContent
            } else {
                phoneLandscapeContent
            }
        }
        .background(AppColors.card)
    }

    private var phonePortraitContent: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Map fills remaining space
            DeliveryMapView(
                storeLocation: viewModel.delivery.storeLocation,
                customerLocation: viewModel.delivery.customerLocation,
                driverLocation: viewModel.delivery.driverLocation,
                status: viewModel.delivery.status,
                showCallout: viewModel.showCallout,
                calloutTitle: viewModel.calloutTitle,
                calloutDistance: viewModel.calloutDistance,
                calloutTime: viewModel.calloutTime
            )
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .layoutPriority(1)

            // Bottom content - fixed height
            VStack(alignment: .leading, spacing: Spacing.sm) {
                statusSummaryPhonePortrait
                timelineSection
                infoSection
            }
            .padding(.horizontal, Spacing.md)
            .padding(.bottom, Spacing.md)
        }
    }

    private var phoneLandscapeContent: some View {
        ScrollView(.vertical, showsIndicators: true) {
            VStack(alignment: .leading, spacing: 0) {
                mapSection
                statusSummaryWide
                    .padding(.horizontal, Spacing.md)
                timelineSection
                    .padding(.horizontal, Spacing.md)
                infoSection
                    .padding(.horizontal, Spacing.md)
                Spacer(minLength: Spacing.lg)
            }
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        HStack {
            Text("Delivery Detail")
                .font(AppFont.tabletH1Medium)
                .foregroundStyle(AppColors.textPrimary)

            Spacer()

            Button(action: { dismiss() }) {
                Image(systemName: "xmark")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(AppColors.textPrimary)
                    .frame(width: 32, height: 32)
            }
        }
        .padding(.bottom, Spacing.sm)
    }

    // MARK: - Map Section

    private var mapSection: some View {
        DeliveryMapView(
            storeLocation: viewModel.delivery.storeLocation,
            customerLocation: viewModel.delivery.customerLocation,
            driverLocation: viewModel.delivery.driverLocation,
            status: viewModel.delivery.status,
            showCallout: viewModel.showCallout,
            calloutTitle: viewModel.calloutTitle,
            calloutDistance: viewModel.calloutDistance,
            calloutTime: viewModel.calloutTime
        )
        .frame(minHeight: 320)
        .layoutPriority(1)
        .padding(.bottom, Spacing.md)
    }

    // MARK: - Status Summary (iPad / iPhone Landscape)

    private var statusSummaryWide: some View {
        HStack {
            statusTextRow
            Spacer()
            driverInfoRow
        }
        .padding(.bottom, Spacing.md)
    }

    // MARK: - Status Summary (iPhone Portrait - 2 rows)

    private var statusSummaryPhonePortrait: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            statusTextRow
            HStack {
                Text("Driver: \(viewModel.delivery.driverName)")
                    .font(AppFont.tabletBody3Regular)
                    .foregroundStyle(AppColors.textPrimary)
                    .lineLimit(1)
                Spacer()
                callDriverButton
            }
        }
        .padding(.bottom, Spacing.md)
    }

    private var statusTextRow: some View {
        HStack(spacing: Spacing.xxs) {
            Text(viewModel.statusText)
                .font(AppFont.tabletH3Medium)
                .foregroundStyle(AppColors.textPrimary)
                .lineLimit(1)
            Text(viewModel.statusTimeText)
                .font(AppFont.tabletH3Medium)
                .foregroundStyle(AppColors.theme)
                .lineLimit(1)
        }
    }

    private var driverInfoRow: some View {
        HStack(spacing: Spacing.sm) {
            Text("Driver: \(viewModel.delivery.driverName)")
                .font(AppFont.tabletBody3Regular)
                .foregroundStyle(AppColors.textPrimary)
                .lineLimit(1)
            callDriverButton
        }
    }

    private var callDriverButton: some View {
        Button(action: { viewModel.callDriver() }) {
            HStack(spacing: Spacing.xxs) {
                Image(systemName: "phone.fill")
                    .font(.system(size: 12))
                Text("Call Driver")
                    .font(AppFont.tabletH5Medium)
                    .lineLimit(1)
            }
            .foregroundStyle(AppColors.textPrimary)
            .padding(.horizontal, Spacing.sm)
            .padding(.vertical, Spacing.xs)
            .background(AppColors.card)
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .stroke(AppColors.line, lineWidth: 1)
            )
        }
        .fixedSize()
    }

    // MARK: - Timeline Section

    private var timelineSection: some View {
        DeliveryTimelineView(
            nodes: viewModel.timelineNodes,
            truckProgress: viewModel.truckProgress
        )
        .frame(maxWidth: .infinity)
        .padding(.bottom, Spacing.lg)
    }

    // MARK: - Info Section

    private var infoSection: some View {
        DeliveryInfoSection(
            customerName: viewModel.delivery.customerName,
            customerPhone: viewModel.delivery.customerPhone,
            deliveryAddress: viewModel.delivery.deliveryAddress,
            deliveryRemarks: viewModel.delivery.deliveryRemarks,
            crossStreetInfo: viewModel.delivery.crossStreetInfo
        )
    }
}

// MARK: - Previews

#Preview("On Route - iPad") {
    DeliveryDetailView(viewModel: .preview(status: .onRoute))
}

#Preview("Delivered - iPad") {
    DeliveryDetailView(viewModel: .preview(status: .delivered))
}

#Preview("Arrived - Dark") {
    DeliveryDetailView(viewModel: .preview(status: .arrived))
        .preferredColorScheme(.dark)
}

