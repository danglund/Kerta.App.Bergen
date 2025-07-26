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
                
                // Close button
                VStack {
                    HStack {
                        Button("Lukk") {
                            dismiss()
                        }
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(.ultraThinMaterial.opacity(0.8))
                        )
                        
                        Spacer()
                        
                        // Progress indicator
                        Text("\(currentWordIndex + 1) / \(words.count)")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(.ultraThinMaterial.opacity(0.8))
                            )
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    
                    Spacer()
                }
                
                // Content card
                VStack {
                    if let word = currentWord {
                        ZStack(alignment: .bottomTrailing) {
                            VStack(spacing: 20) {
                                // Category badge
                                Text(word.category.chapter.chapter)
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(.white.opacity(0.8))
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 4)
                                    .background(
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(Color.black.opacity(0.3))
                                    )
                                
                                if !showingAnswer {
                                    // Question state - show intro and term
                                    VStack(spacing: 16) {
                                        Text("Hva betyr:")
                                            .font(.system(size: 16, weight: .medium))
                                            .foregroundColor(.white.opacity(0.9))
                                        
                                        Text(word.word.term)
                                            .font(.system(size: 28, weight: .bold, design: .rounded))
                                            .foregroundColor(.white)
                                            .multilineTextAlignment(.center)
                                    }
                                } else {
                                    // Answer state - show term and meaning
                                    VStack(spacing: 16) {
                                        Text(word.word.term)
                                            .font(.system(size: 24, weight: .bold, design: .rounded))
                                            .foregroundColor(.white)
                                            .multilineTextAlignment(.center)
                                        
                                        VStack(spacing: 8) {
                                            ForEach(word.word.correctOptions, id: \.self) { option in
                                                Text(option)
                                                    .font(.system(size: 18, weight: .medium))
                                                    .foregroundColor(.white)
                                                    .multilineTextAlignment(.center)
                                            }
                                        }
                                        
                                        // Show explanation if available
                                        if let explanation = word.word.longExplanation {
                                            VStack(spacing: 4) {
                                                ForEach(explanation, id: \.self) { line in
                                                    Text(line)
                                                        .font(.system(size: 14, weight: .regular))
                                                        .foregroundColor(.white.opacity(0.8))
                                                        .multilineTextAlignment(.center)
                                                        .italic()
                                                }
                                            }
                                            .padding(.top, 8)
                                        }
                                    }
                                }
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
                            
                            // Tap hint icon
                            Image(systemName: showingAnswer ? "arrow.right.circle.fill" : "hand.tap.fill")
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
                    }
                    
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(.top, geometry.size.height * 0.2)
            }
        }
        .onTapGesture {
            handleTap()
        }
        .onAppear {
            loadRandomWords()
            startHintTimer()
            // Play Anitra's Dream for flashcards
            audioService.playAnitrasDreamMusic()
        }
        .onDisappear {
            stopHintTimer()
        }
        .ignoresSafeArea(.container, edges: .top)
    }
    
    // MARK: - Helper Methods
    
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