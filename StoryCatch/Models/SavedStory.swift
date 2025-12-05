//
//  PersistentStory.swift
//  StoryCatch
//
//  Created by AI on 03/12/25.
//

import Foundation
import SwiftData

/// SwiftData model representing a story saved on device.
@Model
final class SavedStory {
    @Attribute(.unique) var id: UUID
    var title: String
    var createdAt: Date
    var updatedAt: Date
    /// Whether the story has reached the final spine step.
    var isComplete: Bool
    /// Raw value of `StorySpineStep` the user is currently on.
    var currentStepRaw: Int
    
    /// All passages for this story, one per spine step.
    @Relationship(deleteRule: .cascade, inverse: \PersistentPassage.story) // ?
    var passages: [PersistentPassage]
    
    init(
        id: UUID = UUID(),
        title: String = "",
        createdAt: Date = .now,
        updatedAt: Date = .now,
        isComplete: Bool = false,
        currentStepRaw: Int = StorySpineStep.onceUponATime.rawValue,
        passages: [PersistentPassage] = []
    ) {
        self.id = id
        self.title = title
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.isComplete = isComplete
        self.currentStepRaw = currentStepRaw
        self.passages = passages
    }
    
    var currentStep: StorySpineStep {
        get { StorySpineStep(rawValue: currentStepRaw) ?? .onceUponATime }
        set { currentStepRaw = newValue.rawValue }
    }
}

/// SwiftData model representing a single passage in the story spine.
@Model
final class PersistentPassage {
    var stepRaw: Int
    var text: String
    var story: SavedStory?
    
    init(stepRaw: Int, text: String, story: SavedStory? = nil) {
        self.stepRaw = stepRaw
        self.text = text
        self.story = story
    }
    
    var step: StorySpineStep {
        get { StorySpineStep(rawValue: stepRaw) ?? .onceUponATime }
        set { stepRaw = newValue.rawValue }
    }
}

// MARK: - Mapping helpers from in-memory StoryModel

extension SavedStory {
    /// Applies data from an in-memory `StoryModel` into this persistent model.
    func apply(from model: StoryModel) {
        title = model.storyTitle
        isComplete = model.isComplete
        currentStep = model.currentStep
        updatedAt = .now
        
        var existingByStep: [Int: PersistentPassage] = [:]
        for passage in passages {
            existingByStep[passage.stepRaw] = passage
        }
        
        for (rawStep, text) in model.passages {
            guard !text.isEmpty else { continue }
            if let existing = existingByStep[rawStep] {
                existing.text = text
            } else {
                let new = PersistentPassage(stepRaw: rawStep, text: text, story: self)
                passages.append(new)
            }
        }
        
        // Remove any passages that no longer exist in the model.
        passages.removeAll { persistent in
            model.passages[persistent.stepRaw] == nil
        }
    }
    
    /// Rebuilds an in-memory `StoryModel` from this persistent model.
    func toStoryModel() -> StoryModel {
        let model = StoryModel(skipLoadingFromUserDefaults: true)
        model.storyTitle = title
        model.isComplete = isComplete
        model.currentStep = currentStep
        
        var dict: [Int: String] = [:]
        for passage in passages {
            dict[passage.stepRaw] = passage.text
        }
        model.passages = dict
        
        return model
    }
}


