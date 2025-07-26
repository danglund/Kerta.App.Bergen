import SwiftUI

struct MusicPlayerPanel: View {
    @ObservedObject var audioService: AudioService
    
    var body: some View {
        HStack(spacing: 12) {
            // Album art placeholder or track info
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

#Preview {
    MusicPlayerPanel(audioService: AudioService())
        .previewLayout(.sizeThatFits)
}