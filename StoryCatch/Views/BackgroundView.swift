//
//  BackgroundView.swift
//  StoryCatch
//
//  Created by Fabio Antonucci on 30/11/25.
//

import SwiftUI

struct BackgroundView: View {
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        if colorScheme == .light {
            LinearGradient(colors: [Color(white: 0.95), Color(white: 0.8)],
                           startPoint: .topLeading,
                           endPoint: .bottomTrailing)
                .ignoresSafeArea()
        } else {
            LinearGradient(colors: [Color(white: 0.20), Color(white: 0.10)],
                           startPoint: .topLeading,
                           endPoint: .bottomTrailing)
                .ignoresSafeArea()
        }
    }
}

struct BackgroundView_Previews: PreviewProvider {
    static var previews: some View {
        BackgroundView()
    }
}
