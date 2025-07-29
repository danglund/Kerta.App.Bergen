import SwiftUI
import MapKit
import CoreLocation

struct KartView: View {
    @EnvironmentObject private var audioService: AudioService
    @StateObject private var locationService = LocationService()
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 60.3913, longitude: 5.3221),
        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
    )
    @State private var simulatedUsers: [MapPointAnnotation] = []
    @State private var showBergenLandmarks = false
    @State private var focusedOnBergen = false
    @State private var hasInitialized = false
    @State private var currentAnnotations: [MapPointAnnotation] = []
    
    private let bergenCoordinate = CLLocationCoordinate2D(latitude: 60.3913, longitude: 5.3221)
    
    // Bergen landmarks and points of interest
    private let bergenLandmarks = [
        MapPointAnnotation(coordinate: CLLocationCoordinate2D(latitude: 60.3913, longitude: 5.3221), title: "Bergen sentrum", isUserLocation: false, isLandmark: true),
        MapPointAnnotation(coordinate: CLLocationCoordinate2D(latitude: 60.3975, longitude: 5.3243), title: "Fløyen", isUserLocation: false, isLandmark: true),
        MapPointAnnotation(coordinate: CLLocationCoordinate2D(latitude: 60.4038, longitude: 5.3249), title: "Ulriken", isUserLocation: false, isLandmark: true),
        MapPointAnnotation(coordinate: CLLocationCoordinate2D(latitude: 60.3946, longitude: 5.3240), title: "Bryggen", isUserLocation: false, isLandmark: true),
        MapPointAnnotation(coordinate: CLLocationCoordinate2D(latitude: 60.3902, longitude: 5.3327), title: "Fisketorget", isUserLocation: false, isLandmark: true),
        MapPointAnnotation(coordinate: CLLocationCoordinate2D(latitude: 60.3867, longitude: 5.3327), title: "Nordnes", isUserLocation: false, isLandmark: true),
        MapPointAnnotation(coordinate: CLLocationCoordinate2D(latitude: 60.4006, longitude: 5.3186), title: "Sandviken", isUserLocation: false, isLandmark: true),
        MapPointAnnotation(coordinate: CLLocationCoordinate2D(latitude: 60.3845, longitude: 5.3389), title: "Nygårdshøyden", isUserLocation: false, isLandmark: true),
        MapPointAnnotation(coordinate: CLLocationCoordinate2D(latitude: 60.3789, longitude: 5.3328), title: "Møhlenpris", isUserLocation: false, isLandmark: true),
        MapPointAnnotation(coordinate: CLLocationCoordinate2D(latitude: 60.3956, longitude: 5.3086), title: "Skuteviken", isUserLocation: false, isLandmark: true),
        MapPointAnnotation(coordinate: CLLocationCoordinate2D(latitude: 60.3978, longitude: 5.3389), title: "Stoltzekleiven", isUserLocation: false, isLandmark: true),
        MapPointAnnotation(coordinate: CLLocationCoordinate2D(latitude: 60.3889, longitude: 5.3178), title: "Vågen", isUserLocation: false, isLandmark: true),
        MapPointAnnotation(coordinate: CLLocationCoordinate2D(latitude: 60.3834, longitude: 5.3456), title: "Puddefjorden", isUserLocation: false, isLandmark: true),
        MapPointAnnotation(coordinate: CLLocationCoordinate2D(latitude: 60.4023, longitude: 5.3356), title: "Bergenhus", isUserLocation: false, isLandmark: true),
        MapPointAnnotation(coordinate: CLLocationCoordinate2D(latitude: 60.3856, longitude: 5.3267), title: "Torgallmenningen", isUserLocation: false, isLandmark: true)
    ]
    
    private func updateAnnotations() {
        var annotations: [MapPointAnnotation] = []
        
        // Add simulated users
        annotations.append(contentsOf: simulatedUsers)
        
        // Add Bergen landmarks if toggled
        if showBergenLandmarks {
            annotations.append(contentsOf: bergenLandmarks)
        }
        
        DispatchQueue.main.async {
            currentAnnotations = annotations
        }
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .topLeading) {
                // Full screen map with dynamic annotations
                Map(coordinateRegion: $region, annotationItems: currentAnnotations) { annotation in
                    MapKit.MapAnnotation(coordinate: annotation.coordinate) {
                        VStack {
                            if annotation.isCluster {
                                // Multi-person cluster icon
                                ZStack {
                                    Image(systemName: "person.2.circle.fill")
                                        .font(.title2)
                                        .foregroundColor(.blue)
                                        .background(Color.white)
                                        .clipShape(Circle())
                                        .shadow(radius: 3)
                                    
                                    // Cluster count badge
                                    Text("\(annotation.clusterCount)")
                                        .font(.caption2)
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)
                                        .frame(width: 16, height: 16)
                                        .background(Color.red)
                                        .clipShape(Circle())
                                        .offset(x: 8, y: -8)
                                }
                            } else {
                                // Single icon (person or landmark)
                                Image(systemName: annotation.isLandmark ? "mappin.circle.fill" : "person.circle.fill")
                                    .font(.title2)
                                    .foregroundColor(annotation.isLandmark ? .red : .blue)
                                    .background(Color.white)
                                    .clipShape(Circle())
                                    .shadow(radius: 3)
                            }
                            
                            // Only show title for non-cluster items
                            if !annotation.isCluster {
                                Text(annotation.title)
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(.ultraThinMaterial)
                                    .cornerRadius(6)
                                    .shadow(radius: 2)
                            }
                        }
                    }
                }
                .ignoresSafeArea(.container, edges: .top)
                .onAppear {
                    // Initialize annotations
                    updateAnnotations()
                    
                    // Stop any currently playing music and start Bergen location audio
                    audioService.stopAudio()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        audioService.playEDuFraBergenMusic()
                        print("🎵 Started Bergen location music")
                    }
                    
                    // Focus on user location by default (unless already in Bergen) - async to avoid state update conflicts
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        if !hasInitialized {
                            initializeMapLocation()
                        }
                    }
                    
                    // Generate simulated users after a delay
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                        generateSimulatedUsers()
                    }
                }
                
                // Top overlay with distance and Bergen toggle button
                VStack(alignment: .leading, spacing: 12) {
                    // Distance display (always show)
                    if locationService.userLocation != nil {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("\(Int(locationService.distanceToBergen)) km")
                                .font(.system(size: 20, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                                .shadow(radius: 2)
                            
                            Text("hemefrå")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.9))
                                .shadow(radius: 1)
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .background(.ultraThinMaterial)
                        .cornerRadius(10)
                        .shadow(radius: 6)
                    }
                    
                    // Bergen toggle button
                    Button(action: {
                        toggleBergenFocus()
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: focusedOnBergen ? "location.fill" : "house.fill")
                                .font(.system(size: 16, weight: .medium))
                            
                            Text(focusedOnBergen ? "Min lokasjon" : "Bergen")
                                .font(.system(size: 14, weight: .semibold))
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(.blue)
                        .cornerRadius(8)
                        .shadow(radius: 4)
                    }
                }
                .padding(.top, geometry.safeAreaInsets.top + 10)
                .padding(.leading, 16)
                
                // Location permission overlay
                if locationService.authorizationStatus == .notDetermined {
                    // Location permission overlay
                    VStack(spacing: 16) {
                        Image(systemName: "location.circle")
                            .font(.system(size: 60))
                            .foregroundColor(.white)
                        
                        Text("Se hvor langt du er fra Bergen")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                        
                        Button("Gi lokasjon tilgang") {
                            locationService.requestLocationPermission()
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .padding(.horizontal, 32)
                    .padding(.vertical, 24)
                    .background(.ultraThinMaterial)
                    .cornerRadius(16)
                    .shadow(radius: 12)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.black.opacity(0.3))
                }
            }
        }
        .onAppear {
            if locationService.authorizationStatus == .authorizedWhenInUse ||
               locationService.authorizationStatus == .authorizedAlways {
                locationService.startLocationUpdates()
            }
        }
        .onDisappear {
            locationService.stopLocationUpdates()
        }
        .onChange(of: locationService.userLocation) { newLocation in
            // When user location becomes available, initialize map focus if not already done
            if !hasInitialized && newLocation != nil {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    initializeMapLocation()
                }
            }
        }
        .onChange(of: simulatedUsers) { _ in
            updateAnnotations()
        }
        .onChange(of: showBergenLandmarks) { _ in
            updateAnnotations()
        }
    }
    
    private func initializeMapLocation() {
        hasInitialized = true
        
        guard let userLocation = locationService.userLocation else {
            // If no user location available yet, don't change anything - keep Bergen as fallback
            print("🗺️ No user location available yet, keeping Bergen as fallback")
            return
        }
        
        // Check if user is already in Bergen (within ~5km)
        let distanceToBergen = CLLocation(latitude: userLocation.coordinate.latitude, longitude: userLocation.coordinate.longitude)
            .distance(from: CLLocation(latitude: bergenCoordinate.latitude, longitude: bergenCoordinate.longitude))
        
        if distanceToBergen < 5000 { // 5km threshold
            // User is in Bergen, show landmarks and focus on Bergen
            showBergenLandmarks = true
            focusedOnBergen = true
            focusOnBergen()
            print("🗺️ User is in Bergen, showing landmarks")
        } else {
            // User is elsewhere, focus on their location (this is the desired default behavior)
            showBergenLandmarks = false
            focusedOnBergen = false
            focusOnUserLocation()
            print("🗺️ User is outside Bergen, focusing on user location")
        }
    }
    
    private func focusOnUserLocation() {
        guard let userLocation = locationService.userLocation else { return }
        
        withAnimation(.easeInOut(duration: 1.0)) {
            region = MKCoordinateRegion(
                center: userLocation.coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            )
            focusedOnBergen = false
        }
    }
    
    private func focusOnBergen() {
        withAnimation(.easeInOut(duration: 1.0)) {
            region = MKCoordinateRegion(
                center: bergenCoordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            )
            focusedOnBergen = true
        }
    }
    
    private func toggleBergenFocus() {
        if focusedOnBergen {
            // Switch to user location and hide Bergen landmarks
            showBergenLandmarks = false
            focusOnUserLocation()
        } else {
            // Switch to Bergen and show landmarks
            showBergenLandmarks = true
            focusOnBergen()
        }
    }
    
    private func generateSimulatedUsers() {
        guard let userLocation = locationService.userLocation else { return }
        guard simulatedUsers.isEmpty else { 
            print("🗺️ Simulated users already generated, skipping")
            return 
        }
        
        var rawUsers: [MapPointAnnotation] = []
        let userNames = ["Erik", "Ingrid", "Lars", "Astrid", "Ola", "Kari", "Bjørn", "Solveig", "Magnus", "Lena", "Torbjørn", "Sigrid", "Gunnar", "Helga", "Sindre"]
        
        // Generate 10-15 random users closer to user location (smaller radius)
        let userCount = Int.random(in: 10...15)
        
        for i in 0..<userCount {
            // Generate coordinates within ~300m radius (much closer)  
            let latOffset = Double.random(in: -0.003...0.003)
            let lonOffset = Double.random(in: -0.003...0.003)
            
            let coordinate = CLLocationCoordinate2D(
                latitude: userLocation.coordinate.latitude + latOffset,
                longitude: userLocation.coordinate.longitude + lonOffset
            )
            
            let user = MapPointAnnotation(
                coordinate: coordinate,
                title: userNames[i % userNames.count],
                isUserLocation: false,
                isLandmark: false
            )
            
            rawUsers.append(user)
        }
        
        // Cluster users that are too close together
        let clusteredUsers = clusterUsers(rawUsers)
        
        simulatedUsers = clusteredUsers
        
        print("🗺️ Generated \(rawUsers.count) simulated users, clustered into \(clusteredUsers.count) annotations")
    }
    
    private func clusterUsers(_ users: [MapPointAnnotation]) -> [MapPointAnnotation] {
        guard !users.isEmpty else { return [] }
        
        var clusteredUsers: [MapPointAnnotation] = []
        var processedUsers: Set<String> = []
        let clusterDistance: Double = 0.001 // ~100m clustering threshold
        
        for user in users {
            if processedUsers.contains(user.id.uuidString) { continue }
            
            // Find nearby users to cluster
            var nearbyUsers: [MapPointAnnotation] = [user]
            processedUsers.insert(user.id.uuidString)
            
            for otherUser in users {
                if processedUsers.contains(otherUser.id.uuidString) { continue }
                
                let distance = sqrt(
                    pow(user.coordinate.latitude - otherUser.coordinate.latitude, 2) +
                    pow(user.coordinate.longitude - otherUser.coordinate.longitude, 2)
                )
                
                if distance < clusterDistance {
                    nearbyUsers.append(otherUser)
                    processedUsers.insert(otherUser.id.uuidString)
                }
            }
            
            if nearbyUsers.count > 1 {
                // Create cluster
                let avgLat = nearbyUsers.map { $0.coordinate.latitude }.reduce(0, +) / Double(nearbyUsers.count)
                let avgLon = nearbyUsers.map { $0.coordinate.longitude }.reduce(0, +) / Double(nearbyUsers.count)
                
                let cluster = MapPointAnnotation(
                    coordinate: CLLocationCoordinate2D(latitude: avgLat, longitude: avgLon),
                    title: "",
                    isUserLocation: false,
                    isLandmark: false,
                    isCluster: true,
                    clusterCount: nearbyUsers.count
                )
                clusteredUsers.append(cluster)
            } else {
                // Single user
                clusteredUsers.append(user)
            }
        }
        
        return clusteredUsers
    }
}

struct MapPointAnnotation: Identifiable, Equatable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
    let title: String
    let isUserLocation: Bool
    let isLandmark: Bool
    let isCluster: Bool
    let clusterCount: Int
    
    init(coordinate: CLLocationCoordinate2D, title: String, isUserLocation: Bool, isLandmark: Bool, isCluster: Bool = false, clusterCount: Int = 1) {
        self.coordinate = coordinate
        self.title = title
        self.isUserLocation = isUserLocation
        self.isLandmark = isLandmark
        self.isCluster = isCluster
        self.clusterCount = clusterCount
    }
    
    static func == (lhs: MapPointAnnotation, rhs: MapPointAnnotation) -> Bool {
        return lhs.id == rhs.id &&
               lhs.coordinate.latitude == rhs.coordinate.latitude &&
               lhs.coordinate.longitude == rhs.coordinate.longitude &&
               lhs.title == rhs.title &&
               lhs.isUserLocation == rhs.isUserLocation &&
               lhs.isLandmark == rhs.isLandmark &&
               lhs.isCluster == rhs.isCluster &&
               lhs.clusterCount == rhs.clusterCount
    }
}

#Preview {
    KartView()
}