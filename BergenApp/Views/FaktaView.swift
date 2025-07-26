import SwiftUI

struct FaktaView: View {
    @StateObject private var factsService = BergenFactsService()
    @EnvironmentObject private var audioService: AudioService
    @State private var iconOpacity: Double = 0.6
    @State private var iconScale: Double = 1.0
    @State private var hintTimer: Timer?
    @State private var lastTapTime: Date = Date()
    
    private let margin: CGFloat = 10
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                // Full screen layout with overlay text
                ZStack {
                        // Full bleed background image (respecting tab bar safe area)
                        if let fact = factsService.currentFact {
                            if UIImage(named: fact.imageName) != nil {
                                Image(fact.imageName)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: geometry.size.width, height: geometry.size.height - geometry.safeAreaInsets.bottom)
                                    .clipped()
                            } else {
                                // Fallback gradient background
                                LinearGradient(
                                    gradient: Gradient(colors: [Color.blue.opacity(0.6), Color.purple.opacity(0.4)]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                                .frame(width: geometry.size.width, height: geometry.size.height - geometry.safeAreaInsets.bottom)
                            }
                        }
                        
                        // Dynamic height fact box with tap icon below
                        VStack(alignment: .trailing, spacing: 16) {
                            if let fact = factsService.currentFact {
                                // Fact box
                                Text(fact.text)
                                    .font(.system(size: 18, weight: .medium, design: .rounded))
                                    .lineSpacing(6)
                                    .multilineTextAlignment(.center)
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 24)
                                    .padding(.vertical, 20)
                                    .frame(maxWidth: .infinity, minHeight: 90, alignment: .center) // Minimum height for ~3 lines
                                    .background(
                                        RoundedRectangle(cornerRadius: 16)
                                            .fill(.ultraThinMaterial.opacity(0.8))
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 16)
                                                    .fill(Color.black.opacity(0.6))
                                            )
                                            .shadow(color: .black.opacity(0.3), radius: 12, x: 0, y: 4)
                                    )
                                
                                // Tap icon with circle below fact box, aligned to right edge
                                HStack {
                                    Spacer()
                                    
                                    Image(systemName: "hand.tap.fill")
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
                            
                            Spacer()
                        }
                        .padding(.horizontal, margin)
                        .padding(.top, geometry.safeAreaInsets.top + 20) // More top margin to position fact box lower
                        .onAppear {
                            startHintTimer()
                            // Play Grieg's Morning when entering facts
                            audioService.playMorningMusic()
                        }
                        .onDisappear {
                            stopHintTimer()
                        }
                    }
                    .onTapGesture {
                        handleTap()
                    }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .ignoresSafeArea(.container, edges: .top)
        }
    }
    
    // MARK: - Helper Functions
    
    private func handleTap() {
        let now = Date()
        // Prevent multiple taps within 0.6 seconds (slightly longer than animation duration)
        guard now.timeIntervalSince(lastTapTime) > 0.6 else { return }
        
        lastTapTime = now
        withAnimation(.easeInOut(duration: 0.5)) {
            factsService.showRandomFact()
        }
        resetHintTimer()
    }
    
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
        // Perform 3 subtle tap animations
        for i in 0..<3 {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.4) {
                withAnimation(.easeInOut(duration: 0.2)) {
                    iconOpacity = 1.0
                    iconScale = 0.8
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        iconOpacity = 0.6
                        iconScale = 1.0
                    }
                }
            }
        }
    }
}

#Preview {
    FaktaView()
        .environmentObject(AudioService())
}