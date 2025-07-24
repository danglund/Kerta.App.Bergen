# PRD: Bergen! Button Feature

## Overview
The core feature of the Bergen! app - a large, prominent button that plays random recordings of people saying "Bergen!" when tapped.

## User Story
As a Bergen enthusiast, I want to tap a big button and hear authentic Bergen voices saying "Bergen!" so that I can share the Bergen spirit anywhere.

## Requirements

### Functional Requirements
- **Primary Button**: Full-screen tappable button with "BERGEN!" text
- **Audio Playback**: Plays random audio sample from collection on each tap
- **Immediate Response**: Audio starts playing immediately when button is tapped
- **No Delay**: Button remains responsive during audio playback
- **Multiple Taps**: Can trigger new audio even if previous is still playing

### Audio Requirements
- **Sample Collection**: 7 Bergen voice recordings provided by user
- **Random Selection**: Each tap selects randomly from available samples
- **Audio Format**: Support both .mp3 and .m4a formats
- **Volume**: Use system volume, respect silent mode settings
- **Interruption Handling**: Handle phone calls and other audio interruptions gracefully

### UI/UX Requirements
- **Button Design**: Large, colorful, exciting button that fills most of screen
- **Visual Feedback**: Button animation/scaling on tap
- **Haptic Feedback**: Light haptic feedback on tap
- **Norwegian Text**: Button text "Trykk for å høyra BERGEN!"
- **Accessibility**: VoiceOver support with appropriate labels

### Technical Requirements
- **Offline First**: All audio samples bundled with app
- **Performance**: Instant audio playback, no loading delays
- **Memory Management**: Efficient audio loading and cleanup
- **Background**: Continue playback if user switches apps briefly

## Success Criteria
- Button responds instantly to taps
- Audio plays immediately without delay
- Random selection feels truly random over multiple uses
- Users smile/laugh when using the feature
- No crashes or audio glitches

## Non-Goals
- No streaming or online audio
- No user-generated audio uploads
- No audio recording functionality
- No audio editing or effects

## Dependencies
- AVFoundation framework for audio playback
- UIKit/SwiftUI for haptic feedback
- User-provided Bergen audio samples (7 files)

## Risks & Mitigations
- **Risk**: Audio files too large for app bundle
  - **Mitigation**: Compress audio files appropriately while maintaining quality
- **Risk**: Audio playback fails on device
  - **Mitigation**: Comprehensive testing on various iOS versions and devices
- **Risk**: Button becomes unresponsive during audio
  - **Mitigation**: Asynchronous audio playback implementation