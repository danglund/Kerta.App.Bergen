import Foundation

struct BergenWord: Codable, Identifiable {
    let id = UUID()
    let term: String
    let correctOptions: [String]
    let longExplanation: [String]?
    let wrongOptions: [String]
    
    enum CodingKeys: String, CodingKey {
        case term
        case correctOptions = "correct_options"
        case longExplanation = "long_explanation"
        case wrongOptions = "wrong_options"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.term = try container.decode(String.self, forKey: .term)
        self.correctOptions = try container.decode([String].self, forKey: .correctOptions)
        self.wrongOptions = try container.decode([String].self, forKey: .wrongOptions)
        
        // Handle both null and array for long_explanation
        if let explanationArray = try? container.decode([String].self, forKey: .longExplanation) {
            self.longExplanation = explanationArray
        } else {
            self.longExplanation = nil
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(term, forKey: .term)
        try container.encode(correctOptions, forKey: .correctOptions)
        try container.encode(wrongOptions, forKey: .wrongOptions)
        try container.encodeIfPresent(longExplanation, forKey: .longExplanation)
    }
}

struct BergenWordChapter: Codable, Identifiable {
    let id = UUID()
    let chapter: String
    let entries: [BergenWord]
    
    enum CodingKeys: String, CodingKey {
        case chapter, entries
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.chapter = try container.decode(String.self, forKey: .chapter)
        self.entries = try container.decode([BergenWord].self, forKey: .entries)
    }
}

// MARK: - Category with background images
struct BergenWordCategory {
    let chapter: BergenWordChapter
    let backgroundImages: [String]
    
    static let imageMapping: [String: [String]] = [
        "Vanlige bergenske uttrykk": ["11-bergensk-dialekt-uttrykk-2", "19-regnbyen-fjordene", "04-bryggen-unesco-5"],
        "Hva betyr bergenske ord?": ["11-bergensk-dialekt-uttrykk-2", "02-fisketorget-800-aar-5", "18-gamle-bergen-museum-3"],
        "Dialektord om ting og tang": ["02-fisketorget-800-aar-5", "18-gamle-bergen-museum-3", "20-bergenhus-festning-3"],
        "Dialektord om personer": ["02-fisketorget-800-aar-5", "12-festspillene-bergen-2", "19-regnbyen-fjordene"]
    ]
    
    init(chapter: BergenWordChapter) {
        self.chapter = chapter
        self.backgroundImages = Self.imageMapping[chapter.chapter] ?? ["19-regnbyen-fjordene"]
    }
    
    func randomBackgroundImage() -> String {
        return backgroundImages.randomElement() ?? "19-regnbyen-fjordene"
    }
}

// MARK: - Word with context for display
struct BergenWordWithCategory {
    let word: BergenWord
    let category: BergenWordCategory
    let backgroundImage: String
    
    init(word: BergenWord, category: BergenWordCategory) {
        self.word = word
        self.category = category
        self.backgroundImage = category.randomBackgroundImage()
    }
}