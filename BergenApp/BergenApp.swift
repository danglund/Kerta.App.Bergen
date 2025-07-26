import SwiftUI

// MARK: - Simple Music Player Panel for iOS 16 compatibility
struct SimpleMusicPlayerPanel: View {
    @ObservedObject var audioService: AudioService
    
    var body: some View {
        HStack(spacing: 12) {
            // Track info
            if let track = audioService.currentTrack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(track.title)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                        .lineLimit(1)
                    
                    Text(track.composer)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            } else {
                Text("Playing...")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            // Play/Pause button
            Button(action: {
                audioService.togglePlayPause()
            }) {
                Image(systemName: audioService.isPlaying ? "pause.fill" : "play.fill")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.primary)
                    .frame(width: 24, height: 24)
            }
            
            // Stop button
            Button(action: {
                audioService.stopAudio()
            }) {
                Image(systemName: "stop.fill")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.secondary)
                    .frame(width: 24, height: 24)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(.ultraThinMaterial)
                .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
        )
        .padding(.horizontal, 16)
    }
}

@main
struct BergenApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

struct ContentView: View {
    @StateObject private var audioService = AudioService()
    @State private var selectedTab: Int = 0
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottom) {
                // Main TabView - stays in place
                TabView(selection: $selectedTab) {
                    BergenButtonView()
                        .environmentObject(audioService)
                        .tabItem {
                            Label("Bergen!", systemImage: "speaker.wave.3.fill")
                        }
                        .tag(0)
                    
                    KartView()
                        .environmentObject(audioService)
                        .tabItem {
                            Label("Kart", systemImage: "map.fill")
                        }
                        .tag(1)
                    
                    BergenOrdView()
                        .environmentObject(audioService)
                        .tabItem {
                            Label("Bergensk", systemImage: "text.bubble")
                        }
                        .tag(2)
                    
                    FaktaView()
                        .environmentObject(audioService)
                        .tabItem {
                            Label("Fakta", systemImage: "book.fill")
                        }
                        .tag(3)
                    
                    MerView()
                        .environmentObject(audioService)
                        .tabItem {
                            Label("Meir", systemImage: "ellipsis.circle.fill")
                        }
                        .tag(4)
                }
                .accentColor(.blue)
                .onChange(of: selectedTab) { newValue in
                    // Stop music when navigating away from Fakta tab (tab 3)
                    // Note: We check if current playing state and new tab is not Fakta
                    if audioService.isPlaying && newValue != 3 {
                        audioService.stopAudio()
                        print("🎵 Stopped music when leaving Fakta tab")
                    }
                }
                
                // Music player panel - appears directly above tab bar
                if audioService.isPlaying {
                    VStack(spacing: 0) {
                        Spacer()
                        SimpleMusicPlayerPanel(audioService: audioService)
                    }
                    .padding(.bottom, geometry.safeAreaInsets.bottom + 49) // Tab bar height + safe area
                    .transition(.asymmetric(
                        insertion: .move(edge: .bottom).combined(with: .opacity),
                        removal: .move(edge: .bottom).combined(with: .opacity)
                    ))
                    .animation(.spring(response: 0.4, dampingFraction: 0.8), value: audioService.isPlaying)
                    .allowsHitTesting(true)
                }
            }
        }
        .onOpenURL { url in
            handleDeepLink(url)
        }
    }
    
    private func handleDeepLink(_ url: URL) {
        print("🔗 Received deep link: \(url)")
        
        // Handle different URL schemes: bergen://tab/fakta, bergen://tab/kart, etc.
        guard url.scheme == "bergen" else {
            print("❌ Unknown URL scheme: \(url.scheme ?? "nil")")
            return
        }
        
        let path = url.path.lowercased()
        
        switch path {
        case "/bergen", "/button":
            selectedTab = 0
            print("📍 Navigated to Bergen Button")
        case "/kart", "/map":
            selectedTab = 1
            print("📍 Navigated to Kart")
        case "/bergen-ord", "/words":
            selectedTab = 2
            print("📍 Navigated to Bergen ord")
        case "/fakta", "/facts":
            selectedTab = 3
            print("📍 Navigated to Fakta")
        case "/mer", "/more":
            selectedTab = 4
            print("📍 Navigated to Mer")
        default:
            print("❌ Unknown deep link path: \(path)")
        }
    }
}