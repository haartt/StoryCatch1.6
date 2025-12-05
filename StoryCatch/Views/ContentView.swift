import SwiftUI
import SwiftUI
import SwiftData

struct ContentView: View {
    @State private var selectedImage: UIImage?
    @State private var isShowingPhotoPicker = false
    @State private var isShowingCamera = false
    @State private var navigateToCatchView = false

    var body: some View {
        TabView {
            NavigationStack {
                HomeView(selectedImage: $selectedImage,
                         isShowingPhotoPicker: $isShowingPhotoPicker,
                         isShowingCamera: $isShowingCamera,
                         navigateToCatchView: $navigateToCatchView)
                    .navigationTitle("Home")
            }
            .tabItem {
                Label("Home", systemImage: "house")
            }
            
            NavigationStack {
                StoriesView()
                    .navigationTitle("Library")
            }
            .tabItem {
                Label("Library", systemImage: "books.vertical")
            }
        }
        .background(BackgroundView())
    }
}

#Preview {
    ContentView()
}
