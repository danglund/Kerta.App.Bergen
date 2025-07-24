# Bergen! App Documentation

## Overview
Bergen! is an iOS app celebrating Bergen, Norway with playful features for Bergen enthusiasts worldwide.

## Project Structure
```
BergenApp/
├── BergenApp.xcodeproj/     # Xcode project files
├── BergenApp/               # Swift source code
│   ├── Views/              # SwiftUI views for each tab
│   ├── Services/           # Audio, location, and other services
│   ├── Models/             # Data models
│   └── Resources/          # Audio files and data
├── Docs/                   # This documentation
└── README.md               # Project overview
```

## Features

### Core Features (MVP)
1. **Bergen! Button** - Main feature: tap to hear Bergen voices
2. **Kart** - Show distance to Bergen from current location
3. **Fakta** - Random Bergen facts in Norwegian
4. **Mer** - Expandable features framework

### Feature Documentation
Each feature has comprehensive documentation in `/Docs/Features/`:
- `01-PRD.md` - Product Requirements Document
- `02-progress.md` - Implementation progress tracking
- `03-lessons-learned.md` - Issues encountered and solutions

## Development Approach
- **SwiftUI** for modern iOS UI development
- **Offline-first** design - all core features work without internet
- **Norwegian language** UI text throughout
- **iOS 17+** minimum deployment target
- **Claude Code** assisted development with comprehensive documentation

## Key Technical Decisions
- Using AVFoundation for audio playback
- CoreLocation + MapKit for location and mapping
- Local JSON for Bergen facts storage
- Bundle resources for audio samples
- No external dependencies or frameworks

## Architecture Principles
- **Modular design** - each feature is self-contained
- **Clean separation** - Views, Services, Models clearly separated
- **Testable code** - services can be tested independently
- **Scalable framework** - easy to add new features in Mer tab

## Getting Started
1. Open `BergenApp.xcodeproj` in Xcode
2. Select iPhone simulator
3. Build and run (⌘+R)
4. Test Bergen! button with audio samples

## Testing Strategy
- **Simulator testing** for UI and basic functionality
- **Device testing** for audio, location, and performance
- **Feature-specific testing** as documented in each feature's progress file

## Quality Assurance
- Each feature has documented success criteria
- Progress tracking ensures nothing is forgotten
- Lessons learned prevent repeating mistakes
- Comprehensive error handling and edge case coverage