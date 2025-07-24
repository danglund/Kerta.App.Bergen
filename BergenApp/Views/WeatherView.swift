import SwiftUI

struct WeatherView: View {
    @StateObject private var rainProvider = BergenRainStatsProvider()
    @State private var showingShareSheet = false
    @State private var shareText = ""
    
    var body: some View {
        ZStack {
            // Background color based on weather
            (rainProvider.isRainy ? Color.gray : Color.blue)
                .opacity(0.1)
                .ignoresSafeArea()
            
            VStack(spacing: 40) {
                Spacer()
                
                // Weather icon
                Image(systemName: rainProvider.isRainy ? "umbrella.fill" : "sun.max.fill")
                    .font(.system(size: 120))
                    .foregroundColor(rainProvider.isRainy ? .gray : .orange)
                    .scaleEffect(rainProvider.isRainy ? 1.0 : 1.2)
                    .animation(.easeInOut(duration: 0.5), value: rainProvider.isRainy)
                
                // Weather message
                Text(rainProvider.isRainy ? "Ja, det regnar.\nAlt er som vanleg." : "NEI!\nSola skin i Bergen!")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .multilineTextAlignment(.center)
                    .foregroundColor(rainProvider.isRainy ? .secondary : .primary)
                    .animation(.easeInOut(duration: 0.3), value: rainProvider.isRainy)
                
                // Share buttons (only when sunny)
                if !rainProvider.isRainy {
                    VStack(spacing: 16) {
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
                            .background(Color.orange)
                            .cornerRadius(12)
                        }
                        
                        Button(action: {
                            shareText = "Østlendingar brif med sol – men vi har sol vi òg! #BergenSkins"
                            showingShareSheet = true
                        }) {
                            HStack {
                                Image(systemName: "flame.fill")
                                Text("Post på X")
                            }
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.red)
                            .cornerRadius(12)
                        }
                    }
                    .transition(.scale.combined(with: .opacity))
                    .animation(.spring(response: 0.6, dampingFraction: 0.8), value: rainProvider.isRainy)
                }
                
                Spacer()
                
                // Check again button
                Button("Sjekk igjen") {
                    rainProvider.checkWeather()
                }
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.blue)
                .padding(.horizontal, 32)
                .padding(.vertical, 12)
                .background(Color.blue.opacity(0.1))
                .cornerRadius(25)
                
                Spacer()
            }
            .padding()
        }
        .navigationTitle("Bergen Vær")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingShareSheet) {
            ActivityView(activityItems: [shareText])
        }
        .onAppear {
            rainProvider.checkWeather()
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