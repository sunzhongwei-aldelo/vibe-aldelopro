//
//  CashierReportView.swift
//  AldeloPro
//
//  Created by 孙仲伟 on 6/9/26.
//

import SwiftUI

/// スクロール方向。フィルターバーの自動表示/非表示制御に使用する。
enum ScrollDirection {
    case up, down, none
}

/// ScrollView コンテンツ最上部の Y オフセットを伝搬する PreferenceKey。
private struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

enum CashierReportDestination: Hashable {
    case settledRevenueSummary
    case cashierSummary
    case cashCount
    case paymentActivities
    case gratuityPayable
    case gratuitySummary
    case giftCardSold
    case storeCreditSold
    case discountActivities
    case voidActivities
}

struct CashierReportView: View {
    let data: CashierReportData
    @State private var path = NavigationPath()

    @State private var lastScrollOffset: CGFloat = 0

    @State private var isFilterBarVisible: Bool = true

 
    private let scrollThreshold: CGFloat = 8

    var body: some View {
        NavigationStack(path: $path) {
            ZStack {
                AppColors.pageBgDeep.edgesIgnoringSafeArea(.all)
                
                VStack(spacing: Spacing.md) {
                    if isFilterBarVisible {
                        CashierReportFilterBarView(data: data.filterBarData)
                            .transition(.move(edge: .top).combined(with: .opacity))
                    }
                    ScrollView {
                  
                        
                        VStack {
                            HStack {
                                Text("Cashier Report")
                                    .font(AppFont.tabletH3Medium)
                                    .padding(.leading, Spacing.md)
                                Spacer()
                                Text("Generated")
                                    .font(AppFont.tabletH6Medium)
                                    .foregroundStyle(AppColors.textSecondary)
                                Text(data.generatedAt)
                                    .font(AppFont.tabletH6Medium)
                                    .padding(.trailing, Spacing.md)
                            }
                            
                            
                            
                            ReportHeaderView(data: data.reportHeaderData)
                            HStack(alignment: .top) {
                                SettledRevenueSummaryView(data: data.settledRevenueSummaryData, onViewMore: {
                                    path.append(CashierReportDestination.settledRevenueSummary)
                                })
                                VStack {
                                    CashierSummaryView(data: data.cashierSummaryData, onViewMoreTapped: {
                                        path.append(CashierReportDestination.cashierSummary)
                                    })
                                    ReportCashCountView(data: data.cashCountData, onViewMore: {
                                        path.append(CashierReportDestination.cashCount)
                                    })
                                }
                            }
                            
                            PaymentActivitiesView(data: data.paymentActivitiesData, onViewMoreTapped: {
                                path.append(CashierReportDestination.paymentActivities)
                            })
                            
                            GratuityPayableView(data: data.gratuityPayableData, onViewMoreTapped: {
                                path.append(CashierReportDestination.gratuityPayable)
                            })
                            
                            GratuitySummaryView(data: data.gratuitySummaryData, onViewMoreTapped: {
                                path.append(CashierReportDestination.gratuitySummary)
                            })
                            
                            GiftCardSoldView(data: data.giftCardSoldData, onViewMoreTapped: {
                                path.append(CashierReportDestination.giftCardSold)
                            })
                            
                            StoreCreditSoldView(data: data.storeCreditSoldData, onViewMoreTapped: {
                                path.append(CashierReportDestination.storeCreditSold)
                            })
                            
                            DiscountActivitiesView(data: data.discountActivitiesData, onViewMoreTapped: {
                                path.append(CashierReportDestination.discountActivities)
                            })
                            
                            VoidActivitiesView(data: data.voidActivitiesData, onViewMoreTapped: {
                                path.append(CashierReportDestination.voidActivities)
                            })
                            
                        }

                    }
                    
                    //auto hide search bar
//                    .onScrollGeometryChange(for: CGFloat.self, of: { geometry in
//                        return -geometry.contentOffset.y
//                    }, action: { oldValue, newValue in
//                        handleScroll(offset: newValue)
//                    })
                    
//                    .coordinateSpace(name: "scrollViewContent")
//                    .onPreferenceChange(ScrollOffsetPreferenceKey.self) { offset in
//                        handleScroll(offset: offset)
//                    }
                }
                .navigationDestination(for: CashierReportDestination.self) { destination in
                    switch destination {
                    case .settledRevenueSummary:
                        SettledRevenueSummaryDetailView()
                    case .cashierSummary:
                        CashierSummaryDetailView()
                    case .cashCount:
                        ReportCashCountDetailView()
                    case .paymentActivities:
                        PaymentActivitiesDetailView(data: data.paymentActivitiesData)
                    case .gratuityPayable:
                        GratuityPayableDetailView()
                    case .gratuitySummary:
                        GratuitySummaryDetailView(data: data.gratuitySummaryData)
                    case .giftCardSold:
                        GiftCardSoldDetailView(data: data.giftCardSoldData)
                    case .storeCreditSold:
                        StoreCreditSoldDetailView(data: data.storeCreditSoldData)
                    case .discountActivities:
                        DiscountActivitiesDetailView(data: data.discountActivitiesData)
                    case .voidActivities:
                        VoidActivitiesDetailView()
                    }
                }
            }
        }
    }


    private func handleScroll(offset: CGFloat) {
        let delta = offset - lastScrollOffset

      
        guard abs(delta) > scrollThreshold else { return }

        
        let direction: ScrollDirection
        if offset >= -scrollThreshold {
            direction = .down
        } else if delta < 0 {
            
            direction = .up
        } else {
            
            direction = .down
        }

        let shouldShow = (direction == .down)
        if shouldShow != isFilterBarVisible {
            withAnimation(.easeInOut(duration: 0.25)) {
                isFilterBarVisible = shouldShow
            }
        }

        lastScrollOffset = offset
    }
}

#Preview {
    ZStack {
        CashierReportView(data: .mock)
    }
}
