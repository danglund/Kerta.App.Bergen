import Foundation

// MARK: - Music Track Model
struct MusicTrack: Codable, Identifiable {
    let id: String
    let title: String
    let composer: String
    let filename: String
    let duration: TimeInterval?
    let year: Int?
    let description: String?
    
    var fullTitle: String {
        return "\(composer) - \(title)"
    }
}

// MARK: - Music Metadata Service
class MusicMetadataService: ObservableObject {
    private var musicTracks: [String: MusicTrack] = [:]
    
    init() {
        loadMusicMetadata()
    }
    
    private func loadMusicMetadata() {
        guard let path = Bundle.main.path(forResource: "music-metadata", ofType: "json"),
              let data = NSData(contentsOfFile: path) else {
            print("❌ Could not find music-metadata.json")
            return
        }
        
        do {
            let musicData = try JSONDecoder().decode([String: MusicTrack].self, from: data as Data)
            self.musicTracks = musicData
            print("✅ Loaded \(musicTracks.count) music tracks")
        } catch {
            print("❌ Error parsing music metadata: \(error)")
        }
    }
    
    func getMusicTrack(for key: String) -> MusicTrack? {
        return musicTracks[key]
    }
    
    func getAllMusicTracks() -> [String: MusicTrack] {
        return musicTracks
    }
}