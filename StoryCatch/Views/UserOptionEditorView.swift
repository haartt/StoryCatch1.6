//
//  UserOptionEditorView.swift
//  StoryCatch
//
//  Created by Fabio Antonucci on 04/12/25.
//

import SwiftUI

// User option editor view
struct UserOptionEditorView: View {
    let step: StorySpineStep
    @Binding var text: String
    @Binding var isPresented: Bool
    
    var body: some View {
        NavigationStack {
            ZStack {
                BackgroundView()
                
                VStack(alignment: .leading, spacing: 16) {
                    Text(step.title)
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text(step.description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    TextEditor(text: $text)
                        .scrollContentBackground(.hidden)
                        .padding()
                        .background(.thinMaterial)
                        .cornerRadius(16)
                        .frame(minHeight: 200)
                    
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("Write Your Continuation")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        isPresented = false
                    }
                }
            }
        }
    }
}
