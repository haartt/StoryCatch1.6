//
//  StoryModel.swift
//  StoryCatch
//
//  Created by Fabio Antonucci on 30/11/25.
//

import Foundation
import Combine

// Story Spine structure by Kenn Adams
enum StorySpineStep: Int, CaseIterable {
    case onceUponATime = 1  // Step 1: Incipit
    case everyDay = 2       // Step 2: Normal world
    case butOneDay = 3      // Step 3: Inciting incident
    case becauseOfThat = 4  // Step 4: Rising action
    case andBecauseOfThat = 5 // Step 5: More complications
    case untilFinally = 6   // Step 6: Climax
    case everSinceThen = 7  // Step 7: Resolution
    
    var title: String {
        switch self {
        case .onceUponATime: return "Once upon a time..."
        case .everyDay: return "Every day..."
        case .butOneDay: return "But one day..."
        case .becauseOfThat: return "Because of that..."
        case .andBecauseOfThat: return "And because of that..."
        case .untilFinally: return "Until finally..."
        case .everSinceThen: return "And, ever since then..."
        }
    }
    
    var description: String {
        switch self {
        case .onceUponATime: return "Set up the world, characters, and initial situation"
        case .everyDay: return "Establish the normal routine or status quo"
        case .butOneDay: return "Introduce the inciting incident or problem"
        case .becauseOfThat: return "Show the consequences and rising action"
        case .andBecauseOfThat: return "Continue building tension and complications"
        case .untilFinally: return "Reach the climax and turning point"
        case .everSinceThen: return "Show the resolution and new normal"
        }
    }
}

class StoryModel: ObservableObject {
    @Published var storyTitle: String = ""
    @Published var passages: [Int: String] = [:]  // Step number -> passage text
    @Published var currentStep: StorySpineStep = .onceUponATime
    @Published var isComplete: Bool = false
    
    private let saveKey = "SavedStory"
    private let titleKey = "SavedStoryTitle"

    /// Default initializer that loads from UserDefaults to maintain backwards compatibility.
    /// When using SwiftData-backed persistence, use `init(skipLoadingFromUserDefaults:)`.
    init() {
        loadStory()
    }

    /// Initializer used when rebuilding a `StoryModel` from SwiftData.
    /// Skips loading from UserDefaults so we don't overwrite the provided data.
    init(skipLoadingFromUserDefaults: Bool) {
        if !skipLoadingFromUserDefaults {
            loadStory()
        }
    }
    
    func setPassage(step: StorySpineStep, text: String) {
        passages[step.rawValue] = text
        
        // Move to next step
        if step.rawValue < StorySpineStep.allCases.count {
            currentStep = StorySpineStep(rawValue: step.rawValue + 1) ?? .onceUponATime
        } else {
            isComplete = true
        }
        
        saveStory()
    }
    
    func getFullStory() -> String {
        var fullStory = ""
        if !storyTitle.isEmpty {
            fullStory += "\(storyTitle)\n\n"
        }
        
        for step in StorySpineStep.allCases {
            if let passage = passages[step.rawValue], !passage.isEmpty {
                fullStory += "\(step.title)\n\(passage)\n\n"
            }
        }
        
        return fullStory.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    func getAllPassages() -> String {
        return StorySpineStep.allCases
            .compactMap { step in
                guard let passage = passages[step.rawValue], !passage.isEmpty else { return nil }
                return passage
            }
            .joined(separator: "\n\n")
    }
    
    private func saveStory() {
        // Save passages as a dictionary in UserDefaults (convert Int keys to String)
        var passagesDict: [String: String] = [:]
        for (key, value) in passages {
            passagesDict[String(key)] = value
        }
        UserDefaults.standard.set(passagesDict, forKey: saveKey)
        UserDefaults.standard.set(storyTitle, forKey: titleKey)
        UserDefaults.standard.set(currentStep.rawValue, forKey: "CurrentStep")
        UserDefaults.standard.set(isComplete, forKey: "StoryComplete")
    }
    
    private func loadStory() {
        // Load passages (convert String keys back to Int)
        if let savedDict = UserDefaults.standard.dictionary(forKey: saveKey) as? [String: String] {
            passages = [:]
            for (key, value) in savedDict {
                if let intKey = Int(key) {
                    passages[intKey] = value
                }
            }
        }
        
        storyTitle = UserDefaults.standard.string(forKey: titleKey) ?? ""
        
        let savedStep = UserDefaults.standard.integer(forKey: "CurrentStep")
        if let step = StorySpineStep(rawValue: savedStep > 0 ? savedStep : 1) {
            currentStep = step
        }
        
        isComplete = UserDefaults.standard.bool(forKey: "StoryComplete")
    }
    
    func resetStory() {
        storyTitle = ""
        passages = [:]
        currentStep = .onceUponATime
        isComplete = false
        saveStory()
    }
}
