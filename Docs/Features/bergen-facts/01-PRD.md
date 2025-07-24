# PRD: Bergen Facts Feature (Fakta Tab)

## Overview
A simple, tap-to-reveal feature that displays random interesting facts about Bergen, Norway in Norwegian language.

## User Story
As a Bergen enthusiast, I want to learn and share interesting facts about Bergen so I can deepen my knowledge and have conversation starters about my favorite city.

## Requirements

### Functional Requirements
- **Fact Display**: Show one Bergen fact at a time in large, readable text
- **Random Selection**: Each tap shows a new random fact from the collection
- **Tap Interaction**: Simple tap anywhere to get new fact
- **Fact Collection**: Curated list of interesting Bergen facts in Norwegian
- **No Repetition**: Avoid showing the same fact twice in quick succession

### Content Requirements
- **Language**: All facts in Norwegian (Bokmål)
- **Fact Topics**: History, culture, geography, famous people, traditions, food, weather
- **Fact Length**: 1-3 sentences per fact, easily readable on phone screen
- **Accuracy**: All facts should be verifiable and accurate
- **Tone**: Informative but engaging, celebration of Bergen

### UI Requirements
- **Clean Design**: Simple, minimalist interface focused on the text
- **Readable Text**: Large font size, good contrast, easy to read
- **Tap Target**: Entire screen area is tappable for new fact
- **Loading State**: Smooth transition between facts
- **First Time**: Welcome message explaining how to use

### Technical Requirements
- **Offline Data**: All facts stored locally in JSON file
- **Fast Loading**: Instant fact switching, no delays
- **Random Algorithm**: Proper randomization to avoid repetition
- **Memory Efficient**: Don't load unnecessary data

## Sample Facts (Norwegian)
- "Bergen ble grunnlagt omkring år 1070 og var Norges hovedstad på 1200-tallet."
- "Fisketorget i Bergen har vært en handleplass i over 800 år."
- "Bergen regner i gjennomsnitt 200 dager i året - mer enn noen annen norsk by."
- "Bryggen i Bergen er på UNESCOs verdensarvliste siden 1979."
- "Bergen er omringet av syv fjell, kjent som 'De syv fjell'."
- "Universitetet i Bergen ble grunnlagt i 1946 og er Norges nest eldste universitet."

## Success Criteria
- Users find facts interesting and surprising
- Smooth, responsive tap interaction
- No repeated facts in normal usage
- Facts are accurate and well-written
- Interface is intuitive without instructions

## Non-Goals
- No fact sharing or social features
- No user-submitted facts
- No multimedia (images, videos)
- No fact categories or filtering
- No fact favorites or bookmarks

## Dependencies
- Local JSON file with fact collection
- SwiftUI for interface
- No external APIs or internet required

## Risks & Mitigations
- **Risk**: Facts become stale or inaccurate over time
  - **Mitigation**: Periodic fact verification and updates
- **Risk**: Limited fact collection becomes repetitive
  - **Mitigation**: Start with 50+ facts, plan for expansion
- **Risk**: Norwegian text encoding issues
  - **Mitigation**: Proper UTF-8 encoding and testing