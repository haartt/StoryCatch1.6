//
//  StoryContinuation.swift
//  StoryCatch
//
//  Created by Fabio Antonucci on 30/11/25.
//

import Foundation
import Combine
import GoogleGenerativeAI

class StoryContinuation: ObservableObject {
    @Published var option1: String = ""
    @Published var option2: String = ""
    @Published var isGenerating: Bool = false
    
    private let model = GenerativeModel(name: "gemini-2.5-pro", apiKey: APIKey.default)
    
    /// Generate two AI continuation options based on the current story and Story Spine step
    func generateContinuations(currentStory: String, step: StorySpineStep) async throws {
        await MainActor.run {
            isGenerating = true
            option1 = ""
            option2 = ""
        }
        
        let prompt = buildPromptForStep(step: step, currentStory: currentStory)
        
        do {
            let response = try await model.generateContent(prompt)
            
            guard let text = response.text, !text.isEmpty else {
                throw NSError(domain: "StoryContinuation", code: -1, userInfo: [NSLocalizedDescriptionKey: "Empty response"])
            }
            
            let (option1, option2) = parseContinuations(from: text)
            
            await MainActor.run {
                self.option1 = option1
                self.option2 = option2
                self.isGenerating = false
            }
        } catch {
            await MainActor.run {
                self.isGenerating = false
            }
            throw error
        }
    }
    
    private func buildPromptForStep(step: StorySpineStep, currentStory: String) -> String {
        let stepGuidance = getStepGuidance(for: step)
        
        return """
        You're continuing a story using the Story Spine framework.
        
        Current story so far:
        \(currentStory)
        
        You need to write the next passage for Step \(step.rawValue): \(step.title)
        
        \(stepGuidance)
        
        What to do:

        - Keep the same tone, style, and characters from the existing story
        - Write about 2-3 sentences
        - Make it flow naturally - no explanations, just story
        - Create two different options that both make sense
        - Each option should take the story in a different direction
        - Stay true to the world and characters you've established
        - Add the right amount of tension or emotion for this part of the story
        
        Output format (plain text only):
        Option 1:
        [Your first continuation - 2-3 sentences]
        
        Option 2:
        [Your second continuation - 2-3 sentences]
        
        Don't literally use phrases like "Every day..." or "But one day..." - just write the story naturally in that style.
        """
    }
    
    private func getStepGuidance(for step: StorySpineStep) -> String {
        switch step {
        case .onceUponATime:
            return "This step sets up the world, characters, and initial situation."
        case .everyDay:
            return """
            This step establishes the normal routine or status quo. Show what life was like before things changed.
            - Establish patterns, routines, or normalcy
            - Build connection with characters' daily life
            - Set up contrast for what's to come
            """
        case .butOneDay:
            return """
            This is the inciting incident - the moment everything changes.
            - Introduce a problem, opportunity, or change
            - Break the normal routine
            - Create the first significant disruption
            """
        case .becauseOfThat:
            return """
            Show the immediate consequences and rising action.
            - Develop the conflict or situation further
            - Show reactions and initial responses
            - Build momentum toward complications
            """
        case .andBecauseOfThat:
            return """
            Continue building tension and adding complications.
            - Escalate the situation
            - Add new obstacles or challenges
            - Push characters further
            """
        case .untilFinally:
            return """
            Reach the climax - the turning point or major resolution moment.
            - Bring the conflict to its peak
            - Show the decisive moment or confrontation
            - Create the dramatic high point
            """
        case .everSinceThen:
            return """
            Show the resolution and new normal.
            - Reveal how things have changed
            - Show the aftermath or consequences
            - Establish the new equilibrium
            """
        }
    }
    
    private func parseContinuations(from text: String) -> (String, String) {
        let lines = text.components(separatedBy: .newlines)
        var option1Lines: [String] = []
        var option2Lines: [String] = []
        var currentOption: Int = 0
        
        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            if trimmed.isEmpty { continue }
            
            let lowercased = trimmed.lowercased()
            if lowercased.hasPrefix("option 1:") || lowercased.hasPrefix("continuation 1:") {
                currentOption = 1
                let content = String(trimmed.dropFirst(currentOption == 1 ? 9 : 14)).trimmingCharacters(in: .whitespaces)
                if !content.isEmpty {
                    option1Lines.append(content)
                }
            } else if lowercased.hasPrefix("option 2:") || lowercased.hasPrefix("continuation 2:") {
                currentOption = 2
                let content = String(trimmed.dropFirst(currentOption == 2 ? 9 : 14)).trimmingCharacters(in: .whitespaces)
                if !content.isEmpty {
                    option2Lines.append(content)
                }
            } else if currentOption == 1 {
                option1Lines.append(trimmed)
            } else if currentOption == 2 {
                option2Lines.append(trimmed)
            } else if currentOption == 0 {
                // First content without explicit label - assume it's option 1
                currentOption = 1
                option1Lines.append(trimmed)
            }
        }
        
        let option1 = option1Lines.isEmpty ? "Failed to generate continuation." : option1Lines.joined(separator: "\n\n")
        let option2 = option2Lines.isEmpty ? "Failed to generate continuation." : option2Lines.joined(separator: "\n\n")
        
        return (option1, option2)
    }
}
