import SwiftUI

struct FaktaView: View {
    @StateObject private var factsService = BergenFactsService()
    @State private var showingWelcome = true
    
    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                VStack(spacing: 0) {
                    if showingWelcome {
                        VStack(spacing: 20) {
                            Image(systemName: "book.circle.fill")
                                .font(.system(size: 80))
                                .foregroundColor(.blue)
                            
                            Text("Bergen Fakta")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                            
                            Text("Trykk hvor som helst for å lære noe nytt om Bergen!")
                                .font(.body)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color(.systemGroupedBackground))
                        .onTapGesture {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                showingWelcome = false
                            }
                        }
                    } else {
                        VStack(spacing: 30) {
                            // Category badge (if available)
                            if let category = factsService.currentFact?.category {
                                Text(category.uppercased())
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(Color.blue)
                                    .clipShape(Capsule())
                            }
                            
                            // Main fact text
                            if let fact = factsService.currentFact {
                                Text(fact.text)
                                    .font(.title2)
                                    .fontWeight(.medium)
                                    .lineSpacing(8)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 20)
                                    .foregroundColor(.primary)
                            }
                            
                            // Instruction text
                            Text("Trykk for neste fakta")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .padding(.top, 20)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color.blue.opacity(0.05),
                                    Color.cyan.opacity(0.05)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .onTapGesture {
                            withAnimation(.easeInOut(duration: 0.5)) {
                                factsService.showRandomFact()
                            }
                        }
                    }
                }
                .navigationTitle("Fakta")
                .navigationBarTitleDisplayMode(.inline)
            }
        }
    }
}

#Preview {
    FaktaView()
}