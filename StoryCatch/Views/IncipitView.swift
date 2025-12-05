//
//  IncipitView.swift
//  StoryCatch
//
//  Created by Fabio Antonucci on 30/11/25.
//

import SwiftUI

struct IncipitView: View {

    @Binding var incipit: String
    var onGenerate: () async -> Void
    var onSave: () -> Void
    
    @State private var showGenerateButton = true

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            
            //Incipit area
            TextEditor(text: $incipit)
                .scrollContentBackground(.hidden) // Rimuove il background di default
                .padding(20)
                .background(.thinMaterial)
                .cornerRadius(30)
                .frame(height: 150)
                .shadow(color: Color.black.opacity(0.1), radius: 10)

            HStack(spacing: 12) {
                Button {
                    onSave()
                    print("Save tapped")
                    showGenerateButton = false
                } label: {
                    Text("Next")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(.thinMaterial)
                        .cornerRadius(32)
                        .shadow(color: Color.black.opacity(0.1), radius: 10)
                }

                if showGenerateButton {
                    Button {
                        Task { await onGenerate() }
                    } label: {
                        Image(systemName: "sparkles")
                            .font(.title2)
                            .frame(width: 50, height: 50)
                            .background(.thinMaterial)
                            .cornerRadius(25)
                            .shadow(color: Color.black.opacity(0.1), radius: 10)
                    }
                }
            }
        }
    }
}

#Preview {
    IncipitView(
        incipit: .constant("Example incipit here..."),
        onGenerate: {}, onSave: {} 
    )
    .padding()
}
