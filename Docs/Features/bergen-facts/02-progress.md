# Bergen Facts Feature - Implementation Progress

## Status: Pending

## Completed Tasks
- [ ] Bergen facts JSON data file created
- [ ] BergenFact model implementation
- [ ] FaktaView UI implementation
- [ ] Random fact selection logic
- [ ] Tap gesture handling
- [ ] Fact transition animations
- [ ] Norwegian text encoding verification
- [ ] Testing with sample facts

## Current Task
Not started - pending Bergen! button completion

## Implementation Notes
- Facts stored in local JSON file (Resources/bergen-facts.json)
- Simple model with fact text and optional category
- SwiftUI view with tap gesture covering entire screen
- Random selection with recent fact tracking to avoid repetition

## Next Steps
1. Create bergen-facts.json with initial fact collection
2. Implement BergenFact model struct
3. Create FaktaView with tap-to-reveal interface
4. Add random selection logic
5. Test Norwegian text display
6. Add smooth transition animations

## Technical Decisions
- Using local JSON file for facts storage
- Simple Codable model for easy JSON parsing
- Array shuffle for randomization
- SwiftUI @State for current fact tracking
- No persistence of user progress needed

## Fact Collection Plan
- Start with 30+ facts covering various Bergen topics
- Include mix of historical, cultural, and geographical facts
- All facts in Bokmål Norwegian
- Keep facts to 1-3 sentences for readability

## Known Issues
None yet - feature not started

## Testing Plan
- Verify JSON parsing works correctly
- Test Norwegian character encoding
- Check random selection feels random
- Test tap responsiveness across screen
- Verify fact text fits on various screen sizes
- Test with different font size accessibility settings