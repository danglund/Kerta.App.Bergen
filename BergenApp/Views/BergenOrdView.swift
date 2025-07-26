import SwiftUI

struct BergenOrdView: View {
    @EnvironmentObject private var audioService: AudioService
    
    var body: some View {
        NavigationStack {
            BergenWordsLandingView()
                .environmentObject(audioService)
        }
    }
}

#Preview {
    BergenOrdView()
        .environmentObject(AudioService())
}