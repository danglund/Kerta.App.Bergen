# PRD: Location Distance Feature (Kart Tab)

## Overview
A map-based feature that shows the user's current location and calculates the straight-line distance to Bergen, Norway.

## User Story
As a Bergen enthusiast living elsewhere, I want to see how far I am from Bergen so I can feel connected to my hometown and know the distance home.

## Requirements

### Functional Requirements
- **Location Access**: Request user's current GPS coordinates
- **Distance Calculation**: Calculate straight-line distance to Bergen (60.3913°N, 5.3221°E)
- **Distance Display**: Show distance in kilometers with Norwegian text "Du er X km hjemmefra"
- **Map Display**: Show user's location and Bergen on a map
- **Permission Handling**: Graceful handling when location permission is denied

### Location Requirements
- **Bergen Coordinates**: Latitude: 60.3913, Longitude: 5.3221 (Bergen, Norway)
- **Precision**: Display distance rounded to nearest kilometer
- **Units**: Always use kilometers (Norwegian standard)
- **Updates**: Real-time distance updates as user moves

### Privacy Requirements
- **Permission Request**: Request location permission only when Kart tab is accessed
- **Permission Text**: Norwegian explanation "Bergen! appen trenger tilgang til din lokasjon for å beregne avstanden til Bergen."
- **Graceful Degradation**: Show message if permission denied
- **No Storage**: Don't store or transmit location data

### UI Requirements
- **Map View**: Show interactive map with user location and Bergen marked
- **Distance Text**: Prominent display of distance in Norwegian
- **Loading State**: Show loading indicator while getting location
- **Error States**: Clear messaging for location errors
- **Offline Support**: Work without internet for distance calculation

### Technical Requirements
- **CoreLocation**: Use CLLocationManager for GPS access
- **MapKit**: Use MKMapView for map display
- **Distance Formula**: Haversine formula for accurate distance calculation
- **Performance**: Efficient location updates, not excessive battery drain

## Success Criteria
- User can easily see their distance from Bergen
- Distance updates accurately as user moves
- Map clearly shows both locations
- Permission flow is smooth and understandable
- Works reliably across different iOS versions

## Non-Goals
- No turn-by-turn navigation
- No route planning or directions
- No location history or tracking
- No sharing of location data
- No other cities or destinations

## Dependencies
- CoreLocation framework
- MapKit framework
- Location permission from user
- GPS capability on device

## Risks & Mitigations
- **Risk**: User denies location permission
  - **Mitigation**: Clear explanation and fallback message
- **Risk**: Poor GPS signal or accuracy
  - **Mitigation**: Show accuracy indicator and handle errors gracefully
- **Risk**: Battery drain from location services
  - **Mitigation**: Use appropriate location accuracy and update frequency