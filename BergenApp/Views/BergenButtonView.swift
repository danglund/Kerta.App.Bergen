import SwiftUI

struct BergenButtonView: View {
    @StateObject private var audioService = AudioService()
    @State private var isPressed = false
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 30) {
                Spacer()
                
                Text("Trykk for å høyra")
                    .font(.title2)
                    .foregroundColor(.secondary)
                
                Button(action: {
                    audioService.playRandomBergenSample()
                }) {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [.blue, .cyan]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: min(geometry.size.width * 0.8, 300))
                            .shadow(color: .blue.opacity(0.3), radius: 20, x: 0, y: 10)
                        
                        VStack(spacing: 8) {
                            Text("BERGEN!")
                                .font(.system(size: 48, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                            
                            Image(systemName: "speaker.wave.3.fill")
                                .font(.title)
                                .foregroundColor(.white.opacity(0.8))
                        }
                    }
                    .scaleEffect(isPressed ? 0.95 : 1.0)
                    .animation(.easeInOut(duration: 0.1), value: isPressed)
                }
                .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
                    isPressed = pressing
                }, perform: {})
                
                Text("🎵 Ekte bergensere! 🎵")
                    .font(.title3)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [Color.blue.opacity(0.1), Color.cyan.opacity(0.1)]),
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .navigationBarHidden(true)
        }
    }
}

#Preview {
    BergenButtonView()
}