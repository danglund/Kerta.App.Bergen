import SwiftUI

struct BergenOrdView: View {
    @EnvironmentObject private var audioService: AudioService
    @State private var iconOpacity: Double = 0.6
    @State private var iconScale: Double = 1.0
    @State private var hintTimer: Timer?
    @State private var currentWordIndex: Int = 0
    
    // Placeholder Bergen words and expressions
    private let bergenWords: [BergenWord] = [
        BergenWord(
            word: "Kåtekopp",
            meaning: "Kopp som brukes til kaffe",
            example: "Kan du fylle opp kåtekoppen min?",
            imageName: "11-bergensk-dialekt-uttrykk-2"
        ),
        BergenWord(
            word: "Skravla",
            meaning: "Å snakke mye og høylytt",
            example: "Du skravlar så mye!",
            imageName: "11-bergensk-dialekt-uttrykk-2"
        ),
        BergenWord(
            word: "Regnver",
            meaning: "Regnvær - typisk bergensk",
            example: "Det er regnver igjen i dag.",
            imageName: "14-bergen-nedbør-2"
        )
    ]
    
    var currentWord: BergenWord {
        bergenWords[currentWordIndex]
    }
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                // Full screen layout with overlay text
                ZStack {
                    // Full bleed background image (respecting tab bar safe area)
                    if UIImage(named: currentWord.imageName) != nil {
                        Image(currentWord.imageName)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: geometry.size.width, height: geometry.size.height - geometry.safeAreaInsets.bottom)
                            .clipped()
                    } else {
                        // Fallback gradient background
                        LinearGradient(
                            gradient: Gradient(colors: [Color.green.opacity(0.6), Color.blue.opacity(0.4)]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                        .frame(width: geometry.size.width, height: geometry.size.height - geometry.safeAreaInsets.bottom)
                    }
                    
                    // Floating text box positioned in top 1/3
                    VStack {
                        ZStack(alignment: .bottomTrailing) {
                            VStack(spacing: 16) {
                                // Word title
                                Text(currentWord.word)
                                    .font(.system(size: 32, weight: .bold, design: .rounded))
                                    .foregroundColor(.white)
                                
                                // Meaning
                                Text(currentWord.meaning)
                                    .font(.system(size: 18, weight: .medium, design: .rounded))
                                    .multilineTextAlignment(.center)
                                    .foregroundColor(.white.opacity(0.9))
                                
                                // Example
                                Text("\"" + currentWord.example + "\"")
                                    .font(.system(size: 16, weight: .regular, design: .rounded))
                                    .italic()
                                    .multilineTextAlignment(.center)
                                    .foregroundColor(.white.opacity(0.8))
                            }
                            .padding(.horizontal, 24)
                            .padding(.vertical, 20)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(.ultraThinMaterial.opacity(0.8))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .fill(Color.black.opacity(0.6))
                                    )
                                    .shadow(color: .black.opacity(0.3), radius: 12, x: 0, y: 4)
                            )
                            
                            // Touch icon in lower right corner with subtle animations
                            Image(systemName: "hand.tap.fill")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.white.opacity(iconOpacity))
                                .padding(6)
                                .background(
                                    Circle()
                                        .fill(Color.black.opacity(0.2))
                                )
                                .scaleEffect(iconScale)
                                .offset(x: -6, y: -6)
                        }
                        .padding(.horizontal, 32)
                        
                        Spacer()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(.top, geometry.size.height * 0.2) // More top margin
                    .onAppear {
                        startHintTimer()
                    }
                    .onDisappear {
                        stopHintTimer()
                    }
                }
                .onTapGesture {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        showNextWord()
                    }
                    resetHintTimer()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .ignoresSafeArea(.container, edges: .top)
        }
    }
    
    // MARK: - Helper Functions
    
    private func startHintTimer() {
        stopHintTimer()
        hintTimer = Timer.scheduledTimer(withTimeInterval: 30.0, repeats: true) { _ in
            performHintAnimation()
        }
    }
    
    private func stopHintTimer() {
        hintTimer?.invalidate()
        hintTimer = nil
    }
    
    private func resetHintTimer() {
        stopHintTimer()
        startHintTimer()
    }
    
    private func performHintAnimation() {
        withAnimation(.easeInOut(duration: 1.0)) {
            iconOpacity = 1.0
            iconScale = 1.2
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            withAnimation(.easeInOut(duration: 1.0)) {
                iconOpacity = 0.6
                iconScale = 1.0
            }
        }
    }
    
    private func showNextWord() {
        currentWordIndex = (currentWordIndex + 1) % bergenWords.count
    }
}

// MARK: - Bergen Word Model

struct BergenWord {
    let word: String
    let meaning: String
    let example: String
    let imageName: String
}

#Preview {
    BergenOrdView()
}