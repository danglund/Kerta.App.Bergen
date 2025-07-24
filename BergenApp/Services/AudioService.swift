import AVFoundation
import UIKit

class AudioService: ObservableObject {
    private var audioPlayer: AVAudioPlayer?
    
    private let bergenSamples = [
        "Bergen1.mp3",
        "Bergen2.mp3", 
        "Bergen3.mp3",
        "Bergen4.m4a",
        "Bergen5.mp3",
        "Bergen6.mp3",
        "Bergen7.m4a"
    ]
    
    init() {
        setupAudioSession()
    }
    
    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to setup audio session: \(error)")
        }
    }
    
    func playRandomBergenSample() {
        guard let randomSample = bergenSamples.randomElement(),
              let url = Bundle.main.url(forResource: randomSample.replacingOccurrences(of: ".mp3", with: "").replacingOccurrences(of: ".m4a", with: ""), withExtension: randomSample.contains(".mp3") ? "mp3" : "m4a") else {
            print("Could not find audio file")
            return
        }
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.play()
            
            // Add haptic feedback
            let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
            impactFeedback.impactOccurred()
            
        } catch {
            print("Error playing audio: \(error)")
        }
    }
    
    func stopAudio() {
        audioPlayer?.stop()
    }
}