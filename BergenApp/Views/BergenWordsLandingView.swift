import SwiftUI
import WebKit

// MARK: - YouTube Player
struct YouTubePlayerView: UIViewRepresentable {
    let videoURL: URL
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator
        webView.scrollView.isScrollEnabled = false
        webView.allowsBackForwardNavigationGestures = false
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        let request = URLRequest(url: videoURL)
        uiView.load(request)
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    class Coordinator: NSObject, WKNavigationDelegate {
        func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            decisionHandler(.allow)
        }
    }
}


// MARK: - Landing View
struct BergenWordsLandingView: View {
    @EnvironmentObject private var audioService: AudioService
    @StateObject private var wordsService = BergenWordsService()
    
    private let youtubeURL = URL(string: "https://www.youtube.com/embed/qULmCULJxBs")!
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background gradient
                LinearGradient(
                    gradient: Gradient(colors: [Color.blue.opacity(0.1), Color.green.opacity(0.1)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Title
                        VStack(spacing: 8) {
                            Text("Hallaien! – Lær deg bergensk")
                                .font(.system(size: 32, weight: .bold, design: .rounded))
                                .foregroundColor(.primary)
                                .multilineTextAlignment(.center)
                            
                            Text("Bergensere er stolte av dialekten sin. Noen ganger klør du deg kanskje i hodet og forstår ikke helt hva folk mener. Fortvil ikke, hjelpen er her.")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .lineLimit(nil)
                        }
                        .padding(.top, 20)
                        
                        // YouTube Video
                        YouTubePlayerView(videoURL: youtubeURL)
                            .frame(height: 200)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
                            .padding(.horizontal, 20)
                        
                        // Mode Selection Buttons
                        VStack(spacing: 12) {
                                // Flashcard Button
                                NavigationLink(destination: 
                                    BergenWordsFlashcardView()
                                        .environmentObject(audioService)
                                        .environmentObject(wordsService)
                                ) {
                                    HStack(spacing: 16) {
                                        Image(systemName: "text.below.photo")
                                            .font(.system(size: 24, weight: .medium))
                                            .foregroundColor(.white)
                                        
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text("Flash cards")
                                                .font(.system(size: 18, weight: .semibold))
                                                .foregroundColor(.white)
                                            
                                            Text("Lær ord og uttrykk med bilder")
                                                .font(.system(size: 14))
                                                .foregroundColor(.white.opacity(0.9))
                                        }
                                        
                                        Spacer()
                                        
                                        Image(systemName: "chevron.right")
                                            .font(.system(size: 16, weight: .medium))
                                            .foregroundColor(.white.opacity(0.8))
                                    }
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 16)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(Color.blue)
                                            .shadow(color: .blue.opacity(0.3), radius: 8, x: 0, y: 4)
                                    )
                                }
                                
                                // Quiz Button
                                NavigationLink(destination:
                                    BergenWordsQuizView()
                                        .environmentObject(audioService)
                                        .environmentObject(wordsService)
                                ) {
                                    HStack(spacing: 16) {
                                        Image(systemName: "questionmark.circle")
                                            .font(.system(size: 24, weight: .medium))
                                            .foregroundColor(.white)
                                        
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text("Quiz")
                                                .font(.system(size: 18, weight: .semibold))
                                                .foregroundColor(.white)
                                            
                                            Text("Test kunnskapen din med spørsmål")
                                                .font(.system(size: 14))
                                                .foregroundColor(.white.opacity(0.9))
                                                .lineLimit(1)
                                                .minimumScaleFactor(0.8)
                                        }
                                        
                                        Spacer()
                                        
                                        Image(systemName: "chevron.right")
                                            .font(.system(size: 16, weight: .medium))
                                            .foregroundColor(.white.opacity(0.8))
                                    }
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 16)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(Color.green)
                                            .shadow(color: .green.opacity(0.3), radius: 8, x: 0, y: 4)
                                    )
                                }
                        }
                        .padding(.horizontal, 20)
                        
                        // Content Attribution
                        VStack(spacing: 12) {
                            // Logo linking to Utdanning i Bergen
                            Link(destination: URL(string: "https://www.utdanningibergen.no/")!) {
                                Image("utdanning-i-bergen-logo")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(height: 40)
                            }
                            
                            // Single attribution sentence
                            Text("Innholdet er laget av Utdanning i Bergen, som ikke er tilknyttet denne appen")
                                .font(.system(size: 11, weight: .medium))
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        .padding(.vertical, 16)
                        .padding(.horizontal, 20)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(.ultraThinMaterial)
                        )
                        .padding(.horizontal, 20)
                        
                        // Debug Stats (moved to bottom)
                        if !wordsService.isLoading {
                            VStack(spacing: 4) {
                                Text("Debug: \(wordsService.allWords.count) ord, \(wordsService.categories.count) kategorier")
                                    .font(.system(size: 10))
                                    .foregroundColor(.secondary.opacity(0.7))
                            }
                            .padding(.top, 8)
                        }
                        
                        // Space for tab bar and music player
                        Spacer(minLength: audioService.currentTrack != nil ? 140 : 80)
                    }
                }
            }
        }
        .onAppear {
            // Start Anitra's Dream music for Bergen words section only if not already playing
            if audioService.currentTrack?.title != "Anitra's Dream" {
                audioService.playAnitrasDreamMusic()
                print("🎵 Started Anitra's Dream music for Bergen words")
            } else {
                print("🎵 Anitra's Dream already playing, continuing")
            }
        }
        .onDisappear {
            print("🎵 Stopping Bergen words music")
        }
    }
}

#Preview {
    BergenWordsLandingView()
        .environmentObject(AudioService())
}