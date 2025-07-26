import AVFoundation
import UIKit
import Combine

class AudioService: ObservableObject {
    private var audioPlayer: AVAudioPlayer?
    private let musicMetadataService = MusicMetadataService()
    
    // Published properties for UI binding
    @Published var isPlaying: Bool = false
    @Published var currentTrack: MusicTrack?
    @Published var currentProgress: Double = 0.0
    
    // Timer for progress updates
    private var progressUpdateTimer: Timer?
    let progressTimer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
    
    private let bergenSamples = [
        "Bergen1.mp3",
        "Bergen2.mp3", 
        "Bergen3.mp3",
        "Bergen4.m4a",
        "Bergen5.mp3",
        "Bergen6.mp3",
        "Bergen7.m4a"
    ]
    
    // Grieg music files for specific contexts
    private let griegMorning = "grieg-morning"
    private let griegMountainKing = "grieg-mountain-king"
    private let griegAasesDeath = "Classicals.de - Grieg - Peer Gynt Suite No. 1, Op. 46 - II. Aase's Death"
    private let griegAnitrasDream = "Classicals.de - Grieg - Peer Gynt Suite No. 1, Op. 46 - III. Anitra's Dream"
    private let griegMorningPiano = "Classicals.de-Grieg-Morning-Mood-Peer-Gynt-Suite-No.1,-Op.46-Arranged-for-Piano"
    private let griegMountainKingMusicBox = "Classicals.de-Grieg-In-the-Hall-of-the-Mountain-King-Peer-Gynt-Suite-Short-Version-Arranged-for-Music-Box"
    
    init() {
        setupAudioSession()
        setupProgressTracking()
    }
    
    deinit {
        progressUpdateTimer?.invalidate()
    }
    
    private func setupAudioSession() {
        do {
            // Use .ambient category to respect mute switch and mix with other audio
            // This is the proper category for background music and sound effects
            try AVAudioSession.sharedInstance().setCategory(
                .ambient, 
                mode: .default, 
                options: [.mixWithOthers]
            )
            try AVAudioSession.sharedInstance().setActive(true)
            print("✅ Audio session configured to respect mute switch")
        } catch {
            print("❌ Failed to setup audio session: \(error)")
        }
    }
    
    private func setupProgressTracking() {
        progressUpdateTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            self?.updateProgress()
        }
    }
    
    private func updateProgress() {
        guard let player = audioPlayer else {
            currentProgress = 0.0
            return
        }
        
        let progress = player.currentTime / player.duration
        DispatchQueue.main.async {
            self.currentProgress = progress.isNaN ? 0.0 : progress
            
            // Check if playback finished
            if !player.isPlaying && progress >= 1.0 {
                self.isPlaying = false
                self.currentTrack = nil
                self.currentProgress = 0.0
            }
        }
    }
    
    func playRandomBergenSample() {
        guard let randomSample = bergenSamples.randomElement(),
              let url = Bundle.main.url(forResource: randomSample.replacingOccurrences(of: ".mp3", with: "").replacingOccurrences(of: ".m4a", with: ""), withExtension: randomSample.contains(".mp3") ? "mp3" : "m4a") else {
            print("Could not find audio file")
            return
        }
        
        playAudio(from: url)
    }
    
    func playMorningMusic() {
        playGriegMusic(griegMorning)
    }
    
    func playMountainKingMusic() {
        playGriegMusic(griegMountainKing)
    }
    
    func playAasesDeathMusic() {
        playGriegMusic(griegAasesDeath)
    }
    
    func playAnitrasDreamMusic() {
        playGriegMusic(griegAnitrasDream)
    }
    
    func playMorningPianoMusic() {
        playGriegMusic(griegMorningPiano)
    }
    
    func playMountainKingMusicBoxMusic() {
        playGriegMusic(griegMountainKingMusicBox)
    }
    
    private func playGriegMusic(_ musicKey: String) {
        guard let track = musicMetadataService.getMusicTrack(for: musicKey) else {
            print("❌ Could not find metadata for music key: \(musicKey)")
            return
        }
        
        print("🎵 Attempting to play: \(track.fullTitle)")
        
        // Extract filename without extension for Bundle.main.url
        let filename = track.filename.replacingOccurrences(of: ".mp3", with: "").replacingOccurrences(of: ".m4a", with: "")
        let fileExtension = track.filename.contains(".mp3") ? "mp3" : "m4a"
        
        guard let audioUrl = Bundle.main.url(forResource: filename, withExtension: fileExtension) else {
            print("❌ Could not find music file: \(track.filename)")
            return
        }
        
        print("✅ Playing: \(track.title) by \(track.composer)")
        currentTrack = track
        playAudio(from: audioUrl)
    }
    
    private func playAudio(from url: URL) {
        do {
            // Check if we can play audio (respects system audio settings)
            guard AVAudioSession.sharedInstance().isOtherAudioPlaying == false || 
                  AVAudioSession.sharedInstance().category == .ambient else {
                print("ℹ️ Audio session not available for playback")
                return
            }
            
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            
            // Set volume to respect system settings
            audioPlayer?.volume = 1.0 // Let system control the actual volume
            
            let didStart = audioPlayer?.play() ?? false
            
            if didStart {
                DispatchQueue.main.async {
                    self.isPlaying = true
                    self.currentProgress = 0.0
                }
                
                print("🎵 Audio started - will respect mute switch and system volume")
                
                // Add haptic feedback only if audio actually started
                let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                impactFeedback.impactOccurred()
            } else {
                print("ℹ️ Audio playback blocked by system (likely muted)")
                DispatchQueue.main.async {
                    self.isPlaying = false
                    self.currentTrack = nil
                }
            }
            
        } catch {
            print("❌ Error playing audio: \(error)")
            DispatchQueue.main.async {
                self.isPlaying = false
                self.currentTrack = nil
            }
        }
    }
    
    func stopAudio() {
        audioPlayer?.stop()
        DispatchQueue.main.async {
            self.isPlaying = false
            self.currentTrack = nil
            self.currentProgress = 0.0
        }
    }
    
    func togglePlayPause() {
        guard let player = audioPlayer else { return }
        
        if player.isPlaying {
            player.pause()
            DispatchQueue.main.async {
                self.isPlaying = false
            }
        } else {
            player.play()
            DispatchQueue.main.async {
                self.isPlaying = true
            }
        }
    }
    
    // MARK: - Metadata Access
    func getMusicMetadata(for key: String) -> MusicTrack? {
        return musicMetadataService.getMusicTrack(for: key)
    }
    
    func getAllMusicTracks() -> [String: MusicTrack] {
        return musicMetadataService.getAllMusicTracks()
    }
}