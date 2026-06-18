//
//  CashierSummaryDetailView.swift
//  AldeloPro
//

import SwiftUI

struct CashierSummaryDetailView: View {
    var body: some View {
        ScrollView {
            VStack {
                CashierSummaryView(data: .mock)
                
                TenderSummaryView(data: .mock)
            }
            
        }
        .navigationBarHidden(true)
        .background(SwipeBackGestureEnabler())
    }
}

#Preview {
    CashierSummaryDetailView()
}
