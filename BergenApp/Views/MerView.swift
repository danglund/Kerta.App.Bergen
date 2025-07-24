import SwiftUI

enum FeatureStatus {
    case available
    case experimental
    case comingSoon
    case disabled
}

struct FeatureItem: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let icon: String
    let status: FeatureStatus
}

struct MerView: View {
    private let features: [FeatureItem] = [
        FeatureItem(
            title: "Skann en meny",
            description: "Ta bilde av meny og få den lest opp på bergensk",
            icon: "camera.viewfinder",
            status: .comingSoon
        ),
        FeatureItem(
            title: "Lag ein spilleliste",
            description: "Få forslag til Bergen-musikk på Spotify",
            icon: "music.note.list",
            status: .comingSoon
        ),
        FeatureItem(
            title: "Finn andre bergensere",
            description: "Se andre Bergen-folk i nærheten på kart",
            icon: "map.circle",
            status: .comingSoon
        ),
        FeatureItem(
            title: "Date ein bergenser",
            description: "Møt andre Bergen-entusiaster for dating",
            icon: "heart.circle",
            status: .comingSoon
        ),
        FeatureItem(
            title: "Bergen været",
            description: "Værmelding med ekte bergensk personlighet",
            icon: "cloud.rain",
            status: .comingSoon
        ),
        FeatureItem(
            title: "Bergen ord",
            description: "Lær bergensk dialekt og uttrykk",
            icon: "text.bubble",
            status: .comingSoon
        )
    ]
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Kommende funksjoner")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        Text("Her kommer det flere Bergen-funksjoner etter hvert. Følg med!")
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 8)
                }
                .listRowBackground(Color.clear)
                
                Section("Funksjoner") {
                    ForEach(features) { feature in
                        FeatureRow(feature: feature)
                    }
                }
            }
            .navigationTitle("Mer")
        }
    }
}

struct FeatureRow: View {
    let feature: FeatureItem
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: feature.icon)
                .font(.title2)
                .foregroundColor(iconColor)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(feature.title)
                        .font(.headline)
                        .foregroundColor(textColor)
                    
                    Spacer()
                    
                    statusBadge
                }
                
                Text(feature.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.leading)
            }
            
            if feature.status == .available {
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
        .contentShape(Rectangle())
        .onTapGesture {
            handleFeatureTap()
        }
    }
    
    private var iconColor: Color {
        switch feature.status {
        case .available:
            return .blue
        case .experimental:
            return .orange
        case .comingSoon:
            return .gray
        case .disabled:
            return .red
        }
    }
    
    private var textColor: Color {
        switch feature.status {
        case .available, .experimental:
            return .primary
        case .comingSoon, .disabled:
            return .secondary
        }
    }
    
    @ViewBuilder
    private var statusBadge: some View {
        switch feature.status {
        case .available:
            EmptyView()
        case .experimental:
            Text("BETA")
                .font(.caption2)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(Color.orange)
                .clipShape(Capsule())
        case .comingSoon:
            Text("KOMMER SNART")
                .font(.caption2)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(Color.gray)
                .clipShape(Capsule())
        case .disabled:
            Text("UTILGJENGELIG")
                .font(.caption2)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(Color.red)
                .clipShape(Capsule())
        }
    }
    
    private func handleFeatureTap() {
        switch feature.status {
        case .available:
            // Navigate to feature
            print("Navigate to \(feature.title)")
        case .experimental:
            // Show experimental warning, then navigate
            print("Show experimental warning for \(feature.title)")
        case .comingSoon:
            // Show coming soon message
            print("Show coming soon message for \(feature.title)")
        case .disabled:
            // Show disabled message
            print("Show disabled message for \(feature.title)")
        }
    }
}

#Preview {
    MerView()
}