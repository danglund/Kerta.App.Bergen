import SwiftUI

struct WeatherView: View {
    @StateObject private var fakeProvider = FakeBergenWeatherProvider()
    @StateObject private var realProvider = YrNoWeatherProvider()
    @StateObject private var complaintService = NewspaperComplaintService()
    @StateObject private var xComplaintService = XComplaintService()
    @State private var showingShareSheet = false
    @State private var shareText = ""
    @State private var showingRealWeather = false
    @State private var weatherMessage = ""
    @State private var showingComplaintView = false
    @State private var showingXComplaintView = false
    
    // Current weather state (initially from fake provider, then real weather)
    private var currentProvider: any RainCheckProvider {
        showingRealWeather ? realProvider : fakeProvider
    }
    
    private var isRainy: Bool {
        currentProvider.isRainy
    }
    
    var body: some View {
        ZStack {
            // Background color based on weather
            (isRainy ? Color.gray : Color.blue)
                .opacity(0.1)
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 30) {
                    Spacer()
                    
                    // Weather icon (default to rain, then show real weather)
                    Image(systemName: showingRealWeather ? (isRainy ? "umbrella.fill" : "sun.max.fill") : "umbrella.fill")
                        .font(.system(size: 100))
                        .foregroundColor(showingRealWeather ? (isRainy ? .gray : .orange) : .gray)
                    
                    // Weather message (spinner text while loading, then real weather)
                    Text(getWeatherMessage())
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .multilineTextAlignment(.center)
                        .foregroundColor(showingRealWeather ? (isRainy ? .secondary : .primary) : .secondary)
                    
                    // Weather details (show real data when available and showing real weather)
                    if showingRealWeather, let weatherData = realProvider.weatherData {
                        VStack(spacing: 16) {
                            // Temperature info
                            VStack(spacing: 8) {
                                HStack {
                                    Text("I dag:")
                                        .font(.headline)
                                    Spacer()
                                    Text("\(String(format: "%.1f", weatherData.currentTemperature))°C")
                                        .font(.title2)
                                        .fontWeight(.semibold)
                                }
                                
                                HStack {
                                    Text("I måren:")  // Bergen dialect for "tomorrow"
                                        .font(.headline)
                                    Spacer()
                                    Text("\(String(format: "%.1f", weatherData.tomorrowTemperature))°C")
                                        .font(.title2)
                                        .fontWeight(.semibold)
                                }
                            }
                            .padding()
                            .background(Color.secondary.opacity(0.1))
                            .cornerRadius(12)
                            
                            // Sun times - sunrise on left, sunset on right
                            HStack {
                                // Sunrise on left
                                VStack(spacing: 4) {
                                    Image(systemName: "sunrise.fill")
                                        .foregroundColor(.orange)
                                        .font(.title2)
                                    Text(weatherData.sunriseTime, format: .dateTime.hour().minute())
                                        .font(.title2)
                                        .fontWeight(.semibold)
                                }
                                
                                Spacer()
                                
                                // Sunset on right
                                VStack(spacing: 4) {
                                    Image(systemName: "sunset.fill")
                                        .foregroundColor(.red)
                                        .font(.title2)
                                    Text(weatherData.sunsetTime, format: .dateTime.hour().minute())
                                        .font(.title2)
                                        .fontWeight(.semibold)
                                }
                            }
                            .padding()
                            .background(Color.secondary.opacity(0.1))
                            .cornerRadius(12)
                        }
                    }
                    
                    // Action buttons (only when real weather is confirmed)
                    if showingRealWeather {
                        VStack(spacing: 16) {
                            // Complaint button - always first
                            Button(action: {
                                complaintService.updateWeather(isRainy: realProvider.isRainy)
                                showingComplaintView = true
                            }) {
                                HStack {
                                    Image(systemName: "envelope.fill")
                                    Text("Klag til avisen")
                                }
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(realProvider.isRainy ? Color.blue : Color.orange)
                                .cornerRadius(12)
                            }
                            
                            // X/Twitter complaint button - always second
                            Button(action: {
                                xComplaintService.updateWeather(isRainy: realProvider.isRainy)
                                showingXComplaintView = true
                            }) {
                                HStack {
                                    Image(systemName: "bubble.left.and.text.bubble.right")
                                    Text("Klag på X")
                                }
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(realProvider.isRainy ? Color.indigo : Color.red)
                                .cornerRadius(12)
                            }
                            
                            // Share button for sunny weather
                            if !realProvider.isRainy {
                                Button(action: {
                                    shareText = "Sola skin i Bergen i dag. Tenk på det, du!"
                                    showingShareSheet = true
                                }) {
                                    HStack {
                                        Image(systemName: "sun.max.fill")
                                        Text("Del med alle Østlendingar")
                                    }
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(Color.orange)
                                    .cornerRadius(12)
                                }
                            }
                        }
                    }
                    
                    Spacer()
                }
                .padding()
            }
        }
        .navigationTitle("Vêret")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingShareSheet) {
            ActivityView(activityItems: [shareText])
        }
        .sheet(isPresented: $showingComplaintView) {
            ComplaintPreviewView(complaintService: complaintService)
        }
        .sheet(isPresented: $showingXComplaintView) {
            XComplaintPreviewView(xComplaintService: xComplaintService)
        }
        .onAppear {
            startWeatherSequence()
        }
    }
    
    // MARK: - Funny Weather Timing Functions
    
    private func startWeatherSequence() {
        // Reset to show fake weather first
        showingRealWeather = false
        
        // Start the fake provider
        fakeProvider.checkWeather()
        
        // Start real weather fetch in background
        realProvider.checkWeather()
        
        // Wait 3-5 seconds before switching to real weather
        let delay = Double.random(in: 3.0...5.0)
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            withAnimation(.easeInOut(duration: 0.8)) {
                showingRealWeather = true
            }
        }
    }
    
    private func checkWeatherWithFunnyTiming() {
        // Reset to fake weather first for the funny effect
        withAnimation(.easeInOut(duration: 0.5)) {
            showingRealWeather = false
        }
        
        // Check fake weather immediately
        fakeProvider.checkWeather()
        
        // Check real weather in background
        realProvider.checkWeather()
        
        // Wait 3-5 seconds before revealing real weather
        let delay = Double.random(in: 3.0...5.0)
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            withAnimation(.easeInOut(duration: 0.8)) {
                showingRealWeather = true
            }
        }
    }
    
    private func getWeatherMessage() -> String {
        if !showingRealWeather {
            // Simple loading message
            return "Hentar vêrdata..."
        } else {
            // Simple weather status
            if realProvider.isRainy {
                return "Det regnar i Bergen"
            } else {
                return "Sola skin i Bergen!"
            }
        }
    }
}

// Share sheet wrapper
struct ActivityView: UIViewControllerRepresentable {
    let activityItems: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#Preview {
    NavigationView {
        WeatherView()
    }
}