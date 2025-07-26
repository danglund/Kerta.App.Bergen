import SwiftUI

struct BergenWordsQuizView: View {
    @EnvironmentObject private var audioService: AudioService
    @EnvironmentObject private var wordsService: BergenWordsService
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Color.green.opacity(0.6), Color.blue.opacity(0.4)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack {
                Text("Bergen ord Quiz")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.white)
                    .padding()
                
                Text("Quiz-modusen kommer snart!")
                    .font(.system(size: 18))
                    .foregroundColor(.white.opacity(0.8))
                    .padding()
                
                Spacer()
                
                Button("Tilbake") {
                    dismiss()
                }
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.white)
                .padding(.horizontal, 32)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.blue)
                )
                .padding(.bottom, 100)
            }
        }
        .onAppear {
            // Play Anitra's Dream for quiz
            audioService.playAnitrasDreamMusic()
        }
    }
}

#Preview {
    BergenWordsQuizView()
        .environmentObject(AudioService())
        .environmentObject(BergenWordsService())
}