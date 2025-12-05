//
//  ProgressIndicatorView.swift
//  StoryCatch
//
//  Created by Fabio Antonucci on 04/12/25.
//

import SwiftUI

// Progress indicator showing current step
struct ProgressIndicatorView: View {
    let currentStep: StorySpineStep
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                ForEach(1...7, id: \.self) { stepNum in
                    Circle()
                        .fill(stepNum <= currentStep.rawValue ? Color.blue : Color.gray.opacity(0.3))
                        .frame(width: 10, height: 10)
                    
                    if stepNum < 7 {
                        Rectangle()
                            .fill(stepNum < currentStep.rawValue ? Color.blue : Color.gray.opacity(0.3))
                            .frame(height: 2)
                    }
                }
            }
            Text("Step \(currentStep.rawValue) of 7")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}
