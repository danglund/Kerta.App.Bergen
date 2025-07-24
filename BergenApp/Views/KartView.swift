import SwiftUI
import MapKit
import CoreLocation

struct KartView: View {
    @StateObject private var locationService = LocationService()
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 60.3913, longitude: 5.3221),
        span: MKCoordinateSpan(latitudeDelta: 10, longitudeDelta: 10)
    )
    
    private let bergenCoordinate = CLLocationCoordinate2D(latitude: 60.3913, longitude: 5.3221)
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                if let error = locationService.locationError {
                    VStack(spacing: 16) {
                        Image(systemName: "location.slash")
                            .font(.system(size: 50))
                            .foregroundColor(.gray)
                        
                        Text(error)
                            .font(.body)
                            .multilineTextAlignment(.center)
                            .foregroundColor(.secondary)
                            .padding(.horizontal)
                        
                        Button("Prøv igjen") {
                            locationService.requestLocationPermission()
                        }
                        .buttonStyle(.bordered)
                    }
                    .frame(maxHeight: .infinity)
                } else if locationService.authorizationStatus == .notDetermined {
                    VStack(spacing: 20) {
                        Image(systemName: "location.circle")
                            .font(.system(size: 80))
                            .foregroundColor(.blue)
                        
                        Text("Se hvor langt du er fra Bergen")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .multilineTextAlignment(.center)
                        
                        Text("Vi trenger tilgang til din lokasjon for å beregne avstanden til Bergen, Norge.")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        
                        Button("Gi lokasjon tilgang") {
                            locationService.requestLocationPermission()
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .padding()
                } else if locationService.userLocation != nil {
                    VStack(spacing: 16) {
                        Text("Du er")
                            .font(.title3)
                            .foregroundColor(.secondary)
                        
                        Text("\(Int(locationService.distanceToBergen)) km")
                            .font(.system(size: 48, weight: .bold, design: .rounded))
                            .foregroundColor(.blue)
                        
                        Text("hjemmefra")
                            .font(.title3)
                            .foregroundColor(.secondary)
                        
                        Map(coordinateRegion: $region, annotationItems: annotations) { annotation in
                            MapKit.MapAnnotation(coordinate: annotation.coordinate) {
                                VStack {
                                    Image(systemName: annotation.isUserLocation ? "location.fill" : "house.fill")
                                        .font(.title2)
                                        .foregroundColor(annotation.isUserLocation ? .blue : .red)
                                        .background(Color.white)
                                        .clipShape(Circle())
                                        .shadow(radius: 3)
                                    
                                    Text(annotation.title)
                                        .font(.caption)
                                        .fontWeight(.semibold)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(Color.white)
                                        .cornerRadius(8)
                                        .shadow(radius: 2)
                                }
                            }
                        }
                        .frame(height: 300)
                        .cornerRadius(12)
                        .onAppear {
                            updateMapRegion()
                        }
                        .onChange(of: locationService.userLocation) { _ in
                            updateMapRegion()
                        }
                    }
                    .padding()
                } else {
                    VStack(spacing: 20) {
                        ProgressView()
                            .scaleEffect(1.5)
                        
                        Text("Finner din lokasjon...")
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxHeight: .infinity)
                }
                
                Spacer()
            }
            .navigationTitle("Kart")
            .onAppear {
                if locationService.authorizationStatus == .authorizedWhenInUse ||
                   locationService.authorizationStatus == .authorizedAlways {
                    locationService.startLocationUpdates()
                }
            }
            .onDisappear {
                locationService.stopLocationUpdates()
            }
        }
    }
    
    private var annotations: [MapPointAnnotation] {
        var items: [MapPointAnnotation] = [
            MapPointAnnotation(coordinate: bergenCoordinate, title: "Bergen", isUserLocation: false)
        ]
        
        if let userLocation = locationService.userLocation {
            items.append(MapPointAnnotation(coordinate: userLocation.coordinate, title: "Du", isUserLocation: true))
        }
        
        return items
    }
    
    private func updateMapRegion() {
        guard let userLocation = locationService.userLocation else { return }
        
        let userCoord = userLocation.coordinate
        let bergenCoord = bergenCoordinate
        
        let centerLat = (userCoord.latitude + bergenCoord.latitude) / 2
        let centerLon = (userCoord.longitude + bergenCoord.longitude) / 2
        
        let latDelta = abs(userCoord.latitude - bergenCoord.latitude) * 1.5
        let lonDelta = abs(userCoord.longitude - bergenCoord.longitude) * 1.5
        
        region = MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: centerLat, longitude: centerLon),
            span: MKCoordinateSpan(latitudeDelta: max(latDelta, 1), longitudeDelta: max(lonDelta, 1))
        )
    }
}

struct MapPointAnnotation: Identifiable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
    let title: String
    let isUserLocation: Bool
}

#Preview {
    KartView()
}