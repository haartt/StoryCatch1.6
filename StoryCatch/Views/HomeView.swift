//
//  HomeView.swift
//  StoryCatch
//
//  Created by Fabio Antonucci on 30/11/25.
//

import SwiftUI

struct HomeView: View {
    @Binding var selectedImage: UIImage?
    @Binding var isShowingPhotoPicker: Bool
    @Binding var isShowingCamera: Bool
    @Binding var navigateToCatchView: Bool

    var body: some View {
        ZStack {
            BackgroundView()
            VStack(spacing: 20) {
                Spacer()
                
                // Import
                Button("Import") {
                    isShowingPhotoPicker = true
                }
                .padding()
                .background(RoundedRectangle(cornerRadius: 12).fill(Color(.systemBackground)))
                .foregroundColor(.primary)
                .sheet(isPresented: $isShowingPhotoPicker) {
                    PhotoPicker(selectedImage: $selectedImage, isPresented: $isShowingPhotoPicker, navigateToCatchView: $navigateToCatchView)
                }
                
                // Take photo
                Button("Take photo") {
                    isShowingCamera = true
                }
                .padding()
                .background(RoundedRectangle(cornerRadius: 12).fill(Color(.systemBackground)))
                .foregroundColor(.primary)
                .sheet(isPresented: $isShowingCamera) {
                    CameraPicker(selectedImage: $selectedImage, isPresented: $isShowingCamera, navigateToCatchView: $navigateToCatchView)
                }
                
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding()
            // Drive navigation using the Bool with the modern API
            .navigationDestination(isPresented: $navigateToCatchView) {
                CatchView(image: selectedImage)
            }
        }
    }
}

#Preview("Light Mode") {
    HomeView(selectedImage: .constant(nil),
             isShowingPhotoPicker: .constant(false),
             isShowingCamera: .constant(false),
             navigateToCatchView: .constant(false))
        .environment(\.colorScheme, .light)
}

#Preview("Dark Mode") {
    HomeView(selectedImage: .constant(nil),
             isShowingPhotoPicker: .constant(false),
             isShowingCamera: .constant(false),
             navigateToCatchView: .constant(false))
        .environment(\.colorScheme, .dark)
}
