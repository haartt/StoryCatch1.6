//
//  ContinuationCardView.swift
//  StoryCatch
//
//  Created by Fabio Antonucci on 30/11/25.
//

import SwiftUI

struct OptionCardView: View {
    let title: String
    let text: String
    let isSelected: Bool
    let isUserOption: Bool
    let onTap: () -> Void
    
    init(title: String, text: String, isSelected: Bool = false, isUserOption: Bool = false, onTap: @escaping () -> Void = {}) {
        self.title = title
        self.text = text
        self.isSelected = isSelected
        self.isUserOption = isUserOption
        self.onTap = onTap
    }
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(.primary)
                    Spacer()
                    if isUserOption {
                        Image(systemName: "pencil")
                            .foregroundColor(.secondary)
                            .font(.caption)
                    }
                }
                
                if isUserOption && text.isEmpty {
                    Text("Tap to write your own continuation...")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .italic()
                } else {
                    Text(text)
                        .font(.body)
                        .foregroundColor(.secondary)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 32)
                    .fill(isSelected ? Color(.systemGray4) : Color(.systemGray6))
                    .overlay(
                        RoundedRectangle(cornerRadius: 32)
                            .stroke(isSelected ? Color.accentColor : Color.clear, lineWidth: 2)
                    )
                    .shadow(color: Color.black.opacity(0.1), radius: 10)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// View to display all three options together
struct StoryOptionsView: View {
    let option1: String
    let option2: String
    let userOption: String
    let isGenerating: Bool
    let selectedOption: Int? // 1, 2, or 3
    let onOptionSelected: (Int) -> Void
    let onUserOptionTapped: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            // Option 1 (AI)
            OptionCardView(
                title: "Option A",
                text: isGenerating ? "Generating..." : option1,
                isSelected: selectedOption == 1,
                isUserOption: false
            ) {
                if !isGenerating && !option1.isEmpty {
                    onOptionSelected(1)
                }
            }
            .disabled(isGenerating || option1.isEmpty)
            
            // Option 2 (AI)
            OptionCardView(
                title: "Option B",
                text: isGenerating ? "Generating..." : option2,
                isSelected: selectedOption == 2,
                isUserOption: false
            ) {
                if !isGenerating && !option2.isEmpty {
                    onOptionSelected(2)
                }
            }
            .disabled(isGenerating || option2.isEmpty)
            
            // Option 3 (User)
            OptionCardView(
                title: "Option C (Your Turn)",
                text: userOption,
                isSelected: selectedOption == 3,
                isUserOption: true
            ) {
                onUserOptionTapped()
            }
        }
        .padding(.horizontal)
    }
}

struct OptionCardView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            StoryOptionsView(
                option1: "This is the first AI-generated continuation option.",
                option2: "This is the second AI-generated continuation option.",
                userOption: "",
                isGenerating: false,
                selectedOption: nil,
                onOptionSelected: { _ in },
                onUserOptionTapped: {}
            )
        }
        .padding()
        .background(Color(UIColor.systemGroupedBackground))
    }
}
