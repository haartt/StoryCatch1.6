//
//  StoryCatchApp.swift
//  StoryCatch
//
//  Created by Fabio Antonucci on 29/11/25.
//

import SwiftUI
import SwiftData

@main
struct StoryCatchApp: App {
    @State private var selectedImage: UIImage? = nil
    @State private var isShowingPhotoPicker = false
    @State private var isShowingCamera = false

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [SavedStory.self, PersistentPassage.self])
    }
}
