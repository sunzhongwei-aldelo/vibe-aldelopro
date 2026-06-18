//
//  SettledRevenueSummaryDetailView.swift
//  AldeloPro
//

import SwiftUI

struct SettledRevenueSummaryDetailView: View {
    var body: some View {
        
        VStack {
            CashierReportDetailViewBar(title: "Settled Revenue Summary", dateString: "2026-05-30 12:00 AM")
            ScrollView {
                VStack {
                    HStack {
                        SettledRevenueSummaryView(data: .mock)
                        PerformanceView(data: .mock)
                    }
                    
                    TaxSummaryView(data: .mock)
                }
                
            }
            .cornerRadius(AppRadius.Tablet.lg)
            .navigationBarHidden(true)
            
        }
        .navigationBarHidden(true)
        .background(AppColors.pageBgDeep.ignoresSafeArea())
        
        .background(SwipeBackGestureEnabler())
        
    }
}

#Preview {
    SettledRevenueSummaryDetailView()
}
