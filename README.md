# Bergen! iOS App

A playful iOS app celebrating Bergen, Norway! Built for Bergen enthusiasts worldwide who want to share their love for this amazing city.

## Features

🎵 **Bergen! Button** - Tap the big button to hear authentic Bergen voices saying "Bergen!"  
🗺️ **Kart** - See your distance from Bergen with GPS location  
📖 **Fakta** - Learn interesting facts about Bergen in Norwegian  
⚙️ **Mer** - Expandable framework for future Bergen-themed features

## Technical Details

- **Platform**: iOS 17.0+
- **Language**: Swift + SwiftUI
- **Architecture**: MVVM with ObservableObject
- **Audio**: AVFoundation for Bergen voice samples
- **Location**: CoreLocation + MapKit for distance calculation
- **Offline-first**: All core features work without internet

## Screenshots

*Coming soon - run the app to see Bergen! in action*

## Development

### Requirements
- iOS 17.0+
- Xcode 15.4+
- macOS for development

### Building
```bash
git clone https://github.com/danglund/Kerta.App.Bergen.git
cd Kerta.App.Bergen
open BergenApp.xcodeproj
```
Select iPhone simulator and build (⌘+R)

### Project Structure
```
BergenApp/
├── BergenApp/
│   ├── Views/           # SwiftUI views for each tab
│   ├── Services/        # Audio & location services  
│   ├── Models/          # Data models
│   └── Resources/       # Audio files & data
├── Docs/               # Feature documentation
└── README.md
```

## Features in Development

The **Mer** tab shows upcoming features:
- 📷 **Skann en meny** - OCR menu reading in Bergen dialect
- 🎵 **Lag ein spilleliste** - Bergen music on Spotify
- 👥 **Finn andre bergensere** - Social map for Bergen people
- ❤️ **Date ein bergenser** - Dating for Bergen enthusiasts
- 🌧️ **Bergen været** - Weather with Bergen personality
- 📚 **Bergen ord** - Learn Bergen dialect words

## The Bergen Spirit

This app captures the loud and proud Bergen spirit! People from Bergen are known for mentioning their beloved city wherever they go, and this app lets you do exactly that - anywhere in the world!

*"Eg e fra Bergen!"* 🎉

## License

Copyright (c) 2025 Kerta Consulting. All rights reserved.

---

Made with ❤️ for Bergen by Dan Gøran Lunde