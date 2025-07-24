import SwiftUI

@main
struct BergenApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

struct ContentView: View {
    var body: some View {
        TabView {
            BergenButtonView()
                .tabItem {
                    Label("Bergen!", systemImage: "speaker.wave.3.fill")
                }
            
            KartView()
                .tabItem {
                    Label("Kart", systemImage: "map.fill")
                }
            
            FaktaView()
                .tabItem {
                    Label("Fakta", systemImage: "book.fill")
                }
            
            MerView()
                .tabItem {
                    Label("Mer", systemImage: "ellipsis.circle.fill")
                }
        }
        .accentColor(.blue)
    }
}