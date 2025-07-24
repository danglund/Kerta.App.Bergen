import Foundation
import UIKit

// Protocol for different weather providers
protocol RainCheckProvider: ObservableObject {
    var isRainy: Bool { get }
    func checkWeather()
}

// Bergen-specific rain statistics provider
class BergenRainStatsProvider: RainCheckProvider {
    @Published var isRainy: Bool = true
    
    // Bergen has approximately 265 rainy days per year
    // 265/365 = 0.726 (72.6% probability)
    private let bergenRainProbability: Double = 0.726
    
    init() {
        checkWeather()
    }
    
    func checkWeather() {
        // Use Bergen's real rain statistics
        let randomValue = Double.random(in: 0...1)
        isRainy = randomValue < bergenRainProbability
        
        // Add slight delay for better UX
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            // Optional: Add haptic feedback
            let impactFeedback = UIImpactFeedbackGenerator(style: .light)
            impactFeedback.impactOccurred()
        }
    }
}

// Future providers could include:
// - RealWeatherAPIProvider (using actual weather API)
// - MockWeatherProvider (for testing)
// - SeasonalWeatherProvider (adjusted probabilities by season)