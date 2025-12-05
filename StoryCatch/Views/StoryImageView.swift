//
//  StoryImageView.swift
//  StoryCatch
//
//  Created by Fabio Antonucci on 04/12/25.
//

import SwiftUI

struct StoryImageView: View {
    let image: UIImage?

    var body: some View {
        if let image {
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .padding(16) // White frame/border
                .background(Color.white)
                .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
                .rotationEffect(.degrees(Double.random(in: -3...3))) // Slight random tilt
                .frame(maxHeight: 300)
                .padding(.horizontal)
        }
    }
}

#Preview {
    StoryImageView(image: UIImage(named: "Image"))
}
