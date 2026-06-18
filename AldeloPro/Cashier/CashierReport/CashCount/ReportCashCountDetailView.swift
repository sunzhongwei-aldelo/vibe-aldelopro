//
//  ReportCashCountDetailView.swift
//  AldeloPro
//

import SwiftUI

struct ReportCashCountDetailView: View {
    var body: some View {
        Text("Cash Count Detail")
            .navigationBarHidden(true)
            .background(SwipeBackGestureEnabler())
    }
}

#Preview {
    ReportCashCountDetailView()
}
