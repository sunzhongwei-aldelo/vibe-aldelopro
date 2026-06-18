//
//  ContentView.swift
//  AldeloPro
//
//  Created by 孙仲伟 on 5/29/26.
//

import SwiftUI
import Combine

struct ContentView: View {
    @State private var text: String = ""
    var body: some View {
        BaseViewContainer {
            CashierBaseView()
//            OrderingPageView()
        }
    }
}

#Preview {
    ContentView()
}

