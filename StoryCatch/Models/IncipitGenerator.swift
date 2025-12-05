import Foundation
import GoogleGenerativeAI
import SwiftUI

let model = GenerativeModel(name: "gemini-2.5-pro", apiKey: APIKey.default)
let uiImage = UIImage(named: "Image") // loads the image from assets


/// Analyze an image and return a story title and the first passage following Story Spine structure.
/// Step 1: "Once upon a time..." - Sets up the world, characters, and initial situation.
func incipitGenerator(image: UIImage) async throws -> (title: String, passage: String) {
    let prompt = """
    You're a storyteller creating the opening of a story based on the Story Spine framework.
    Look closely at the uploaded image - notice the characters, setting, lighting, mood, and any hints of conflict or emotion.
    Write the "Once upon a time..." part of the story (but don't actually use that phrase).
    Your opening should:

    Introduce the world and characters
    Set the scene and atmosphere
    Hook the reader right away
    Be about 2-3 sentences long
    Tell a story inspired by the image, not just describe what you see
    Use clear, engaging language - keep it simple but captivating

    Format:
    Title: [An interesting title]
    Passage:
    [Your opening paragraph]
    """

    let response = try await model.generateContent(prompt, image)
    guard let text = response.text, !text.isEmpty else {
        throw NSError(domain: "ImageAnalysis", code: -1, userInfo: [NSLocalizedDescriptionKey: "Empty response"])
    }
    
    // Parse title and passage from response
    var title = ""
    var passage = ""
    
    let lines = text.components(separatedBy: .newlines)
    var foundTitle = false
    var foundPassage = false
    var passageLines: [String] = []
    
    for line in lines {
        let trimmed = line.trimmingCharacters(in: .whitespaces)
        if trimmed.isEmpty { continue }
        
        if trimmed.lowercased().hasPrefix("title:") {
            title = String(trimmed.dropFirst(6)).trimmingCharacters(in: .whitespaces)
            foundTitle = true
        } else if trimmed.lowercased().hasPrefix("passage:") {
            foundPassage = true
        } else if foundPassage {
            passageLines.append(trimmed)
        } else if !foundTitle && !foundPassage && title.isEmpty {
            // If no explicit title line, use first line as title
            title = trimmed
            foundTitle = true
        }
    }
    
    passage = passageLines.isEmpty ? text : passageLines.joined(separator: "\n\n")
    
    // Fallback: if parsing fails, use entire response
    if title.isEmpty {
        title = "Untitled Story"
    }
    if passage.isEmpty {
        passage = text
    }
    
    return (title: title, passage: passage)
}

struct IncipitGenerator_Previews: PreviewProvider {
    struct PreviewView: View {
        @State private var titleText: String = "Loading..."
        @State private var passageText: String = ""
        
        var body: some View {
            VStack(alignment: .leading, spacing: 8) {
                Text(titleText)
                    .font(.title2)
                    .fontWeight(.bold)
                Text(passageText)
                    .font(.body)
            }
            .padding()
            .task {
                if let image = UIImage(named: "Image") {
                    do {
                        let result = try await incipitGenerator(image: image)
                        titleText = result.title
                        passageText = result.passage
                    } catch {
                        titleText = "Error"
                        passageText = "Failed to generate incipit: \(error.localizedDescription)"
                    }
                } else {
                    titleText = "Error"
                    passageText = "Image not found."
                }
            }
        }
    }
    
    static var previews: some View {
        PreviewView()
    }
}

