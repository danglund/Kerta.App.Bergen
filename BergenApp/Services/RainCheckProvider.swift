import Foundation
import UIKit

// Weather data structure
struct WeatherData {
    let isRainy: Bool
    let currentTemperature: Double
    let tomorrowTemperature: Double
    let sunriseTime: Date
    let sunsetTime: Date
}

// Protocol for different weather providers
protocol RainCheckProvider: ObservableObject {
    var weatherData: WeatherData? { get }
    var isRainy: Bool { get }
    var isRealWeatherProvider: Bool { get } // Distinguish between real and fake providers
    func checkWeather()
}

// MARK: - Fake Weather Provider (Probability-Based)

/// Fake weather provider that uses Bergen's historical rain statistics
/// Always shows rain first, then uses 72.6% probability for rain prediction
class FakeBergenWeatherProvider: RainCheckProvider {
    @Published var weatherData: WeatherData?
    @Published var isRainy: Bool = true
    let isRealWeatherProvider = false // This is a fake provider
    
    // Bergen has approximately 265 rainy days per year (72.6% probability)
    private let bergenRainProbability: Double = 0.726
    
    init() {
        checkWeather()
    }
    
    func checkWeather() {
        // Use Bergen's historical rain statistics for rain prediction
        let randomValue = Double.random(in: 0...1)
        let rainStatus = randomValue < bergenRainProbability
        
        // Generate fake temperatures (Bergen averages: winter 1-4°C, summer 12-18°C)
        let currentTemp = Double.random(in: 2...16)
        let tomorrowTemp = currentTemp + Double.random(in: -3...3)
        
        // Generate fake sunrise/sunset times for Bergen
        let calendar = Calendar.current
        let today = Date()
        
        // Bergen sunrise typically between 5:00-8:00 AM
        var sunriseComponents = calendar.dateComponents([.year, .month, .day], from: today)
        sunriseComponents.hour = Int.random(in: 5...8)
        sunriseComponents.minute = Int.random(in: 0...59)
        
        // Bergen sunset typically between 4:00-10:00 PM depending on season
        var sunsetComponents = calendar.dateComponents([.year, .month, .day], from: today)
        sunsetComponents.hour = Int.random(in: 16...22)
        sunsetComponents.minute = Int.random(in: 0...59)
        
        let sunrise = calendar.date(from: sunriseComponents) ?? today
        let sunset = calendar.date(from: sunsetComponents) ?? today
        
        // Update weather data
        self.weatherData = WeatherData(
            isRainy: rainStatus,
            currentTemperature: currentTemp,
            tomorrowTemperature: tomorrowTemp,
            sunriseTime: sunrise,
            sunsetTime: sunset
        )
        
        self.isRainy = rainStatus
        
        // Add slight delay for better UX
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            // Optional: Add haptic feedback
            let impactFeedback = UIImpactFeedbackGenerator(style: .light)
            impactFeedback.impactOccurred()
        }
    }
}

// MARK: - Real Weather Provider (yr.no API)

/// Real weather provider using Norwegian Meteorological Institute's API (yr.no)
/// Fetches actual current weather data for Bergen from MET Norway
class YrNoWeatherProvider: RainCheckProvider {
    @Published var weatherData: WeatherData?
    @Published var isRainy: Bool = true
    let isRealWeatherProvider = true // This is a real weather provider
    
    // Bergen coordinates
    private let bergenLat = 60.10
    private let bergenLon = 5.23
    
    // User agent as required by MET Norway API
    private let userAgent = "BergenApp/1.0.1 (bergen@kerta.no) Kerta-Consulting"
    
    init() {
        checkWeather()
    }
    
    func checkWeather() {
        Task {
            await fetchWeatherData()
        }
    }
    
    @MainActor
    private func fetchWeatherData() async {
        // Fetch weather forecast and sunrise/sunset data concurrently
        async let weatherTask = fetchLocationForecast()
        async let sunTask = fetchSunriseData()
        
        do {
            let (forecastData, sunData) = try await (weatherTask, sunTask)
            
            // Parse forecast data for current and tomorrow temperature + precipitation
            let currentTemp = parseCurrentTemperature(from: forecastData)
            let tomorrowTemp = parseTomorrowTemperature(from: forecastData)
            let precipitationProbability = parsePrecipitation(from: forecastData)
            
            // Determine if it's rainy (>50% precipitation probability or >0.1mm precipitation)
            let rainStatus = precipitationProbability > 0.5
            
            // Parse sunrise/sunset times
            let (sunrise, sunset) = parseSunTimes(from: sunData)
            
            self.weatherData = WeatherData(
                isRainy: rainStatus,
                currentTemperature: currentTemp,
                tomorrowTemperature: tomorrowTemp,
                sunriseTime: sunrise,
                sunsetTime: sunset
            )
            
            self.isRainy = rainStatus
            
        } catch {
            print("Weather API error: \(error)")
            print("URL: https://api.met.no/weatherapi/locationforecast/2.0/compact?lat=\(bergenLat)&lon=\(bergenLon)")
            print("User-Agent: \(userAgent)")
            // Fallback to reasonable defaults on error
            await fallbackToDefaultData()
        }
    }
    
    private func fetchLocationForecast() async throws -> [String: Any] {
        let url = URL(string: "https://api.met.no/weatherapi/locationforecast/2.0/compact?lat=\(bergenLat)&lon=\(bergenLon)")!
        
        var request = URLRequest(url: url)
        request.setValue(userAgent, forHTTPHeaderField: "User-Agent")
        
        print("Fetching weather from: \(url)")
        print("Setting User-Agent: \(userAgent)")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        if let httpResponse = response as? HTTPURLResponse {
            print("Weather API response status: \(httpResponse.statusCode)")
            if httpResponse.statusCode != 200 {
                throw NSError(domain: "WeatherAPI", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "HTTP \(httpResponse.statusCode)"])
            }
        }
        
        print("Weather API response size: \(data.count) bytes")
        
        let jsonObject = try JSONSerialization.jsonObject(with: data) as? [String: Any] ?? [:]
        print("Weather API JSON keys: \(jsonObject.keys)")
        return jsonObject
    }
    
    private func fetchSunriseData() async throws -> [String: Any] {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let today = dateFormatter.string(from: Date())
        
        let url = URL(string: "https://api.met.no/weatherapi/sunrise/3.0/sun?lat=\(bergenLat)&lon=\(bergenLon)&date=\(today)&offset=+01:00")!
        
        var request = URLRequest(url: url)
        request.setValue(userAgent, forHTTPHeaderField: "User-Agent")
        
        print("Fetching sunrise from: \(url)")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        if let httpResponse = response as? HTTPURLResponse {
            print("Sunrise API response status: \(httpResponse.statusCode)")
            if httpResponse.statusCode != 200 {
                throw NSError(domain: "SunriseAPI", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "HTTP \(httpResponse.statusCode)"])
            }
        }
        
        let jsonObject = try JSONSerialization.jsonObject(with: data) as? [String: Any] ?? [:]
        return jsonObject
    }
    
    private func parseCurrentTemperature(from data: [String: Any]) -> Double {
        // Navigate: properties.timeseries[0].data.instant.details.air_temperature
        guard let properties = data["properties"] as? [String: Any],
              let timeseries = properties["timeseries"] as? [[String: Any]],
              let firstEntry = timeseries.first,
              let entryData = firstEntry["data"] as? [String: Any],
              let instant = entryData["instant"] as? [String: Any],
              let details = instant["details"] as? [String: Any],
              let temperature = details["air_temperature"] as? Double else {
            return 8.0 // Fallback Bergen average
        }
        return temperature
    }
    
    private func parseTomorrowTemperature(from data: [String: Any]) -> Double {
        // Find entry approximately 24 hours from now
        guard let properties = data["properties"] as? [String: Any],
              let timeseries = properties["timeseries"] as? [[String: Any]] else {
            return 8.0 // Fallback
        }
        
        let calendar = Calendar.current
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: Date()) ?? Date()
        
        // Find closest entry to tomorrow at same time
        for entry in timeseries {
            if let timeString = entry["time"] as? String,
               let time = ISO8601DateFormatter().date(from: timeString),
               calendar.isDate(time, inSameDayAs: tomorrow) {
                
                if let entryData = entry["data"] as? [String: Any],
                   let instant = entryData["instant"] as? [String: Any],
                   let details = instant["details"] as? [String: Any],
                   let temperature = details["air_temperature"] as? Double {
                    return temperature
                }
            }
        }
        
        return 8.0 // Fallback
    }
    
    private func parsePrecipitation(from data: [String: Any]) -> Double {
        // Check next hour precipitation probability
        guard let properties = data["properties"] as? [String: Any],
              let timeseries = properties["timeseries"] as? [[String: Any]],
              let firstEntry = timeseries.first,
              let entryData = firstEntry["data"] as? [String: Any],
              let nextHour = entryData["next_1_hours"] as? [String: Any],
              let details = nextHour["details"] as? [String: Any],
              let precipitation = details["precipitation_amount"] as? Double else {
            return 0.0
        }
        
        // Convert precipitation amount to probability (>0.1mm = likely rain)
        return precipitation > 0.1 ? 0.8 : 0.2
    }
    
    private func parseSunTimes(from data: [String: Any]) -> (Date, Date) {
        let calendar = Calendar.current
        let today = Date()
        
        // Default Bergen sun times as fallback
        var sunriseComponents = calendar.dateComponents([.year, .month, .day], from: today)
        sunriseComponents.hour = 7
        sunriseComponents.minute = 0
        
        var sunsetComponents = calendar.dateComponents([.year, .month, .day], from: today)
        sunsetComponents.hour = 20
        sunsetComponents.minute = 0
        
        let defaultSunrise = calendar.date(from: sunriseComponents) ?? today
        let defaultSunset = calendar.date(from: sunsetComponents) ?? today
        
        // Parse actual sunrise/sunset from API response
        if let properties = data["properties"] as? [String: Any],
           let sun = properties["sun"] as? [String: Any] {
            
            let dateFormatter = ISO8601DateFormatter()
            
            if let sunriseString = sun["sunrise"] as? String,
               let sunsetString = sun["sunset"] as? String {
                
                let sunrise = dateFormatter.date(from: sunriseString) ?? defaultSunrise
                let sunset = dateFormatter.date(from: sunsetString) ?? defaultSunset
                
                return (sunrise, sunset)
            }
        }
        
        return (defaultSunrise, defaultSunset)
    }
    
    @MainActor
    private func fallbackToDefaultData() async {
        // Use reasonable Bergen defaults instead of random data
        let calendar = Calendar.current
        let today = Date()
        
        var sunriseComponents = calendar.dateComponents([.year, .month, .day], from: today)
        sunriseComponents.hour = 7
        sunriseComponents.minute = 0
        
        var sunsetComponents = calendar.dateComponents([.year, .month, .day], from: today)
        sunsetComponents.hour = 20
        sunsetComponents.minute = 0
        
        let defaultSunrise = calendar.date(from: sunriseComponents) ?? today
        let defaultSunset = calendar.date(from: sunsetComponents) ?? today
        
        // Use typical Bergen weather (likely rainy, moderate temperature)
        self.weatherData = WeatherData(
            isRainy: true, // Bergen default
            currentTemperature: 8.0, // Bergen average
            tomorrowTemperature: 8.5, // Slightly warmer
            sunriseTime: defaultSunrise,
            sunsetTime: defaultSunset
        )
        
        self.isRainy = true
        print("Using fallback Bergen weather data")
    }
}