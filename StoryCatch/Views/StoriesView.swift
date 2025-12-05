//
//  StoriesView.swift
//  StoryCatch
//
//  Created by Fabio Antonucci on 29/11/25.
//

import SwiftUI
import SwiftData

struct StoriesView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \SavedStory.createdAt, order: .reverse)
    private var stories: [SavedStory]
    
    private var inProgressStories: [SavedStory] {
        stories.filter { !$0.isComplete }
    }
    
    private var completedStories: [SavedStory] {
        stories.filter { $0.isComplete }
    }
    
    var body: some View {
        ZStack {
            BackgroundView()
            
            if stories.isEmpty {
                Text("No stories yet.\nStart a new one from the Home tab.")
                    .multilineTextAlignment(.center)
                    .font(.headline)
                    .foregroundStyle(.secondary)
                    .padding()
            } else {
                List {
                    if !inProgressStories.isEmpty {
                        Section(header: Text("To be completed")) {
                            ForEach(inProgressStories) { story in
                                NavigationLink {
                                    StoryDetailView(story: story)
                                } label: {
                                    StoryRowView(story: story)
                                }
                            }
                            .onDelete { offsets in
                                deleteStories(offsets, from: inProgressStories)
                            }
                        }
                    }
                    
                    if !completedStories.isEmpty {
                        Section(header: Text("Completed")) {
                            ForEach(completedStories) { story in
                                NavigationLink {
                                    StoryDetailView(story: story)
                                } label: {
                                    StoryRowView(story: story)
                                }
                            }
                            .onDelete { offsets in
                                deleteStories(offsets, from: completedStories)
                            }
                        }
                    }
                }
                .scrollContentBackground(.hidden)
            }
        }
    }
    
    private func deleteStories(_ offsets: IndexSet, from subset: [SavedStory]) {
        for index in offsets {
            let story = subset[index]
            if let globalIndex = stories.firstIndex(where: { $0.id == story.id }) {
                modelContext.delete(stories[globalIndex])
            } else {
                modelContext.delete(story)
            }
        }
        try? modelContext.save()
    }
}

private struct StoryRowView: View {
    let story: SavedStory
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(story.title.isEmpty ? "Untitled story" : story.title)
                    .font(.headline)
                Text(storySubtitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            if !story.isComplete {
                Label("Continue", systemImage: "clock.badge.exclamationmark")
                    .font(.caption)
                    .padding(6)
                    .background(Color.orange.opacity(0.15))
                    .foregroundStyle(.orange)
                    .cornerRadius(8)
            } else {
                Image(systemName: "checkmark.seal.fill")
                    .foregroundStyle(.green)
            }
        }
        .padding(.vertical, 4)
    }
    
    private var storySubtitle: String {
        if story.isComplete {
            return "Completed • step 7 of 7"
        } else {
            return "In progress • step \(story.currentStepRaw) of 7"
        }
    }
}

private struct StoryDetailView: View {
    @Environment(\.dismiss) private var dismiss
    let story: SavedStory
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text(story.title.isEmpty ? "Untitled story" : story.title)
                    .font(.title)
                    .fontWeight(.bold)
                
                ForEach(StorySpineStep.allCases, id: \.rawValue) { step in
                    if let passageText = story.passages.first(where: { $0.stepRaw == step.rawValue })?.text,
                       !passageText.isEmpty {
                        PassageCardView(step: step, passage: passageText)
                    }
                }
                
                if !story.isComplete {
                    NavigationLink {
                        CatchView(existingStory: story)
                    } label: {
                        Label("Continue this story", systemImage: "play.circle")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(.thinMaterial)
                            .cornerRadius(16)
                    }
                    .padding(.top)
                }
            }
            .padding()
        }
        .background(BackgroundView())
        .navigationTitle("Story")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    StoriesView()
}
