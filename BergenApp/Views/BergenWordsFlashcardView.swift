import SwiftUI

struct BergenWordsFlashcardView: View {
    @EnvironmentObject private var audioService: AudioService
    @EnvironmentObject private var wordsService: BergenWordsService
    @Environment(\.dismiss) private var dismiss
    
    @State private var currentWordIndex: Int = 0
    @State private var words: [BergenWordWithCategory] = []
    @State private var showingAnswer: Bool = false
    @State private var iconOpacity: Double = 0.6
    @State private var iconScale: Double = 1.0
    @State private var hintTimer: Timer?
    
    var currentWord: BergenWordWithCategory? {
        guard currentWordIndex < words.count else { return nil }
        return words[currentWordIndex]
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background image
                if let word = currentWord,
                   UIImage(named: word.backgroundImage) != nil {
                    Image(word.backgroundImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .clipped()
                } else {
                    // Fallback gradient
                    LinearGradient(
                        gradient: Gradient(colors: [Color.blue.opacity(0.6), Color.green.opacity(0.4)]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                }
                
                // Back button and progress indicator
                VStack {
                    HStack {
                        Button(action: { dismiss() }) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(.white.opacity(0.7))
                        }
                        
                        Spacer()
                        
                        // Progress indicator
                        Text("\(currentWordIndex + 1) / \(words.count)")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white.opacity(0.8))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(.ultraThinMaterial.opacity(0.6))
                            )
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    
                    Spacer()
                }
                
                // Content card using FactsTextBoxView design
                VStack {
                    if let word = currentWord {
                        // Single stable text box with question and answer
                        VStack(alignment: .trailing, spacing: 16) {
                            // Text box with stable question and answer
                            VStack(spacing: 16) {
                                // Question text (always visible)
                                Text(getQuestionText(for: word))
                                    .font(.system(size: 24, weight: .bold, design: .rounded))
                                    .multilineTextAlignment(.center)
                                    .foregroundColor(.white)
                                
                                // Answer text (appears when showingAnswer is true)
                                if showingAnswer {
                                    VStack(spacing: 8) {
                                        // Divider line
                                        Rectangle()
                                            .fill(.white.opacity(0.3))
                                            .frame(height: 1)
                                            .frame(maxWidth: 120)
                                        
                                        // Answer content
                                        Text(getAnswerText(for: word))
                                            .font(.system(size: 18, weight: .medium, design: .default))
                                            .multilineTextAlignment(.center)
                                            .foregroundColor(.white.opacity(0.9))
                                            .italic()
                                    }
                                    .transition(.opacity.combined(with: .move(edge: .top)))
                                }
                            }
                            .padding(.horizontal, 24)
                            .padding(.vertical, 20)
                            .frame(maxWidth: .infinity, minHeight: 120, alignment: .center)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(.ultraThinMaterial.opacity(0.8))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .fill(Color.black.opacity(0.6))
                                    )
                                    .shadow(color: .black.opacity(0.3), radius: 12, x: 0, y: 4)
                            )
                            
                            // Tap icon with circle below text box, aligned to right edge
                            HStack {
                                Spacer()
                                
                                Image(systemName: showingAnswer ? "arrow.right.circle.fill" : "hand.tap.fill")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.white.opacity(iconOpacity))
                                    .scaleEffect(iconScale)
                                    .frame(width: 44, height: 44)
                                    .background(
                                        Circle()
                                            .fill(.ultraThinMaterial.opacity(0.9))
                                            .overlay(
                                                Circle()
                                                    .fill(Color.black.opacity(0.4))
                                            )
                                            .shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 2)
                                    )
                            }
                        }
                        .onTapGesture {
                            handleTap()
                        }
                        .padding(.horizontal, 16)
                    }
                    
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(.top, geometry.size.height * 0.2)
            }
        }
        .onAppear {
            loadRandomWords()
            startHintTimer()
            // Start Anitra's Dream music for flash cards
            if audioService.currentTrack?.title != "Anitra's Dream" {
                audioService.playAnitrasDreamMusic()
                print("🎵 Started Anitra's Dream music for flash cards")
            } else {
                print("🎵 Anitra's Dream already playing, continuing in flash cards")
            }
        }
        .onDisappear {
            stopHintTimer()
        }
        .ignoresSafeArea(.container, edges: .top)
    }
    
    // MARK: - Helper Methods
    
    private func getQuestionText(for word: BergenWordWithCategory) -> String {
        return word.word.term
    }
    
    private func getAnswerText(for word: BergenWordWithCategory) -> String {
        var answer = word.word.correctOptions.joined(separator: "\n")
        
        // Add explanation if available
        if let explanation = word.word.longExplanation {
            answer += "\n\n" + explanation.joined(separator: "\n")
        }
        
        return answer
    }
    
    private func loadRandomWords() {
        words = wordsService.getRandomWords(count: 20) // Load 20 random words
        currentWordIndex = 0
        showingAnswer = false
        print("📚 Loaded \(words.count) flashcards")
    }
    
    private func handleTap() {
        withAnimation(.easeInOut(duration: 0.3)) {
            if !showingAnswer {
                // Show answer
                showingAnswer = true
            } else {
                // Move to next word
                if currentWordIndex < words.count - 1 {
                    currentWordIndex += 1
                    showingAnswer = false
                } else {
                    // End of flashcards, reload new set
                    loadRandomWords()
                }
            }
        }
        resetHintTimer()
    }
    
    private func startHintTimer() {
        stopHintTimer()
        hintTimer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { _ in
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
}

#Preview {
    BergenWordsFlashcardView()
        .environmentObject(AudioService())
        .environmentObject(BergenWordsService())
}