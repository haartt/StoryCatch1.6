//
//  ViewModel.swift
//  StoryCatch
//
//  Created by Fabio Antonucci on 29/11/25.
//

import SwiftUI
import Combine
import SwiftData

struct CatchView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @StateObject private var storyModel: StoryModel
    /// If we are continuing an existing story from the Library, this references it.
    private var existingStory: SavedStory?
    /// Newly created persistent story for a brand‑new session.
    @State private var SavedStory: SavedStory?
    @StateObject private var continuationGenerator = StoryContinuation()
    
    @State private var image: UIImage? = nil
    @State private var isLoadingIncipit = false
    @State private var selectedOption: Int? = nil
    @State private var userOptionText: String = ""
    @State private var showUserOptionEditor = false
    @State private var showingStoryComplete = false
    
    @State private var animateImage = false
    
    // Accept an optional image from the caller (new story)
    // For brand‑new stories we want a completely fresh in‑memory model,
    // so we skip loading any previously saved state from UserDefaults.
    init(image: UIImage? = nil) {
        _storyModel = StateObject(wrappedValue: StoryModel(skipLoadingFromUserDefaults: true))
        self.existingStory = nil
        self._image = State(initialValue: image)
    }

    // Accept an existing persistent story to allow continuation.
    init(existingStory: SavedStory) {
        _storyModel = StateObject(wrappedValue: existingStory.toStoryModel())
        self.existingStory = existingStory
        self._image = State(initialValue: nil)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                BackgroundView()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // IMAGE
                        StoryImageView(image: image)
                            /* // ANIMATE IMAGE .rotationEffect(.degrees(animateImage ? 0.35 : -0.25))
                            .animation(
                                .easeInOut(duration: 10).repeatForever(autoreverses: true),
                                value: animateImage
                            ) */
                        
                        // CURRENT STEP HEADER
                        if storyModel.currentStep != .onceUponATime {
                            VStack(alignment: .leading, spacing: 8) {
                                Text(storyModel.currentStep.title)
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                Text(storyModel.currentStep.description)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                            .background(.thinMaterial)
                            .cornerRadius(16)
                            .padding(.horizontal)
                        }
                        
                        // PROGRESS INDICATOR
                        ProgressIndicatorView(currentStep: storyModel.currentStep)
                            .padding(.horizontal)
                        
                        // DISPLAY ALL PASSAGES SO FAR
                        ForEach(StorySpineStep.allCases.prefix(storyModel.currentStep.rawValue), id: \.rawValue) { step in
                            if let passage = storyModel.passages[step.rawValue], !passage.isEmpty {
                                PassageCardView(step: step, passage: passage)
                            }
                        }
                        
                        // CURRENT STEP EDITOR OR OPTIONS
                        if storyModel.currentStep == .onceUponATime {
                            // Step 1: Incipit generation
                            IncipitView(
                                incipit: Binding(
                                    get: { storyModel.passages[1] ?? "" },
                                    set: { storyModel.passages[1] = $0 }
                                ),
                                onGenerate: {
                                    await generateIncipit()
                                },
                                onSave: {
                                    let passageText = storyModel.passages[1] ?? ""
                                    if !passageText.isEmpty {
                                        storyModel.setPassage(step: .onceUponATime, text: passageText)
                                        saveToSwiftData()
                                        generateContinuationsForCurrentStep()
                                    }
                                }
                            )
                            .padding(.horizontal)
                        } else if storyModel.isComplete {
                            // Story is complete
                            VStack(spacing: 16) {
                                Text("🎉 Story Complete!")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                
                                Text("Your story is finished! You can view it in the Library.")
                                    .multilineTextAlignment(.center)
                                    .foregroundColor(.secondary)
                                    .padding()
                                
                                Button("View Full Story") {
                                    showingStoryComplete = true
                                }
                                .padding()
                                .background(.thinMaterial)
                                .cornerRadius(32)
                            }
                            .padding()
                            .background(.thinMaterial)
                            .cornerRadius(20)
                            .padding(.horizontal)
                        } else {
                            // Steps 2-7: Show options
                            VStack(spacing: 16) {
                                StoryOptionsView(
                                    option1: continuationGenerator.option1,
                                    option2: continuationGenerator.option2,
                                    userOption: userOptionText,
                                    isGenerating: continuationGenerator.isGenerating,
                                    selectedOption: selectedOption,
                                    onOptionSelected: { option in
                                        selectedOption = option
                                        let selectedText = option == 1 ? continuationGenerator.option1 : continuationGenerator.option2
                                        proceedWithOption(selectedText)
                                    },
                                    onUserOptionTapped: {
                                        showUserOptionEditor = true
                                    }
                                )
                                
                                if !userOptionText.isEmpty {
                                    Button("Continue with Your Option") {
                                        proceedWithOption(userOptionText)
                                    }
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(.thinMaterial)
                                    .cornerRadius(32)
                                    .padding(.horizontal)
                                }
                            }
                            .padding(.vertical)
                        }
                        
                        Spacer(minLength: 50)
                    }
                    .padding()
                }
                .frame(maxHeight: .infinity, alignment: .top)
            }
            .onAppear {
                // animateImage = true
                
                if image == nil, let loadedImage = UIImage(named: "Image") {
                    image = loadedImage
                }

                if storyModel.currentStep != .onceUponATime && !storyModel.isComplete {
                    generateContinuationsForCurrentStep()
                }
            }
            .navigationTitle(storyModel.storyTitle.isEmpty ? "New Story" : storyModel.storyTitle)
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        saveToSwiftData()
                        dismiss()
                    } label: {
                        Label("Save", systemImage: "tray.and.arrow.down")
                    }
                    .disabled(storyModel.passages.isEmpty)
                }
            }
            .sheet(isPresented: $showUserOptionEditor) {
                UserOptionEditorView(
                    step: storyModel.currentStep,
                    text: $userOptionText,
                    isPresented: $showUserOptionEditor
                )
            }
            .sheet(isPresented: $showingStoryComplete) {
                StoryCompleteView(storyModel: storyModel)
            }
        }
    }
    
    private func generateIncipit() async {
        guard let img = image else {
            return
        }
        
        isLoadingIncipit = true
        defer { isLoadingIncipit = false }
        
        do {
            let result = try await incipitGenerator(image: img)
            storyModel.storyTitle = result.title
            storyModel.passages[1] = result.passage
        } catch {
            print("Error generating incipit:", error)
        }
    }
    
    private func generateContinuationsForCurrentStep() {
        Task {
            let allPassages = storyModel.getAllPassages()
            do {
                try await continuationGenerator.generateContinuations(
                    currentStory: allPassages,
                    step: storyModel.currentStep
                )
            } catch {
                print("Error generating continuations:", error)
            }
        }
    }
    
    private func proceedWithOption(_ text: String) {
        storyModel.setPassage(step: storyModel.currentStep, text: text)
        saveToSwiftData()
        selectedOption = nil
        userOptionText = ""
        
        if !storyModel.isComplete {
            generateContinuationsForCurrentStep()
        }
    }

    /// Persist the current story into SwiftData.
    private func saveToSwiftData() {
        // 1. If we were passed an existing story from the Library, update it.
        if let existingStory {
            existingStory.apply(from: storyModel)
        }
        // 2. Else, if we already created a persistent story in this session, update it.
        else if let SavedStory {
            SavedStory.apply(from: storyModel)
        }
        // 3. Else, create a brand‑new persistent story and keep a reference.
        else {
            let newStory = StoryCatch.SavedStory(
                title: storyModel.storyTitle,
                createdAt: .now,
                updatedAt: .now,
                isComplete: storyModel.isComplete,
                currentStepRaw: storyModel.currentStep.rawValue
            )
            newStory.apply(from: storyModel)
            modelContext.insert(newStory)
            SavedStory = newStory
        }
        
        do {
            try modelContext.save()
        } catch {
            print("Error saving story to SwiftData: \(error)")
        }
    }
}

#Preview() {
    CatchView()
}


