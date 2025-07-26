import SwiftUI

struct FaktaView: View {
    @StateObject private var factsService = BergenFactsService()
    @EnvironmentObject private var audioService: AudioService
    @State private var iconOpacity: Double = 0.6
    @State private var iconScale: Double = 1.0
    @State private var hintTimer: Timer?
    
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
                        
                        // Floating text box positioned in top 1/3
                        VStack {
                            if let fact = factsService.currentFact {
                                Text(fact.text)
                                    .font(.system(size: 18, weight: .medium, design: .rounded))
                                    .lineSpacing(6)
                                    .multilineTextAlignment(.center)
                                    .foregroundColor(.white)
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
                                    .padding(.horizontal, 32)
                            }
                            
                            Spacer()
                        }
                        
                        // Fixed position tap icon in top-right corner
                        VStack {
                            HStack {
                                Spacer()
                                Image(systemName: "hand.tap.fill")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.white.opacity(iconOpacity))
                                    .padding(8)
                                    .background(
                                        Circle()
                                            .fill(Color.black.opacity(0.3))
                                    )
                                    .scaleEffect(iconScale)
                                    .padding(.top, 20)
                                    .padding(.trailing, 20)
                            }
                            Spacer()
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .padding(.top, geometry.size.height * 0.2) // More top margin
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
                        withAnimation(.easeInOut(duration: 0.5)) {
                            factsService.showRandomFact()
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