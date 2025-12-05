//
//  StoryCompleteView.swift
//  StoryCatch
//
//  Created by Fabio Antonucci on 04/12/25.
//

import SwiftUI

// Story complete view
struct StoryCompleteView: View {
    @ObservedObject var storyModel: StoryModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text(storyModel.storyTitle)
                        .font(.title)
                        .fontWeight(.bold)
                        .padding(.bottom)
                    
                    ForEach(StorySpineStep.allCases, id: \.rawValue) { step in
                        if let passage = storyModel.passages[step.rawValue], !passage.isEmpty {
                            PassageCardView(step: step, passage: passage)
                        }
                    }
                }
                .padding()
            }
            .background(BackgroundView())
            .navigationTitle("Complete Story")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}
