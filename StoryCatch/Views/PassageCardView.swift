//
//  PassageCardView.swift
//  StoryCatch
//
//  Created by Fabio Antonucci on 04/12/25.
//

import SwiftUI

// Card view to display a passage
struct PassageCardView: View {
    let step: StorySpineStep
    let passage: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(step.title)
                .font(.headline)
                .foregroundColor(.primary)
            Text(passage)
                .font(.body)
                .foregroundColor(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.thinMaterial)
        .cornerRadius(16)
        .padding(.horizontal)
    }
}
