# Expandable Features (Mer Tab) - Implementation Progress

## Status: Pending

## Completed Tasks
- [ ] Feature registry system design
- [ ] MerView base UI implementation
- [ ] Feature state enum (Available, Coming Soon, Experimental, Disabled)
- [ ] Feature list UI with different states
- [ ] Placeholder features added
- [ ] Feature navigation handling
- [ ] Testing with sample features

## Current Task
Not started - pending core features completion

## Implementation Notes
- Simple list-based UI showing planned features
- Feature enum to handle different availability states
- NavigationStack for feature-specific views
- Norwegian text for all feature names and descriptions

## Next Steps
1. Create FeatureItem model and registry
2. Implement MerView with feature list
3. Add placeholder entries for planned features
4. Create navigation handling for available features
5. Add feature state visual indicators
6. Test feature addition/removal flow

## Technical Decisions
- Using SwiftUI List for feature display
- Simple enum-based feature state management
- NavigationStack for feature-specific screens
- Local feature registry (no server-side management needed)

## Planned Initial Features
- "Skann en meny" (Coming Soon) - OCR menu reading
- "Lag ein spilleliste" (Coming Soon) - Spotify Bergen music
- "Finn andre bergensere" (Coming Soon) - Social map feature
- "Date ein bergenser" (Coming Soon) - Dating feature
- "Bergen været" (Coming Soon) - Weather with personality
- "Bergen ord" (Coming Soon) - Dialect learning

## Known Issues
None yet - feature not started

## Testing Plan
- Test feature list display and scrolling
- Verify different feature states show correctly
- Test navigation to placeholder features
- Check Norwegian text displays properly
- Test adding/removing features from registry