import Foundation

struct BergenFact: Codable, Identifiable {
    let id: UUID
    let text: String
    let category: String?
    let imageName: String
    
    init(text: String, category: String? = nil, imageName: String? = nil) {
        self.id = UUID()
        self.text = text
        self.category = category
        self.imageName = imageName ?? "bergen-default"
    }
    
    enum CodingKeys: String, CodingKey {
        case text, category, imageName
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = UUID()
        self.text = try container.decode(String.self, forKey: .text)
        self.category = try container.decodeIfPresent(String.self, forKey: .category)
        self.imageName = try container.decodeIfPresent(String.self, forKey: .imageName) ?? "bergen-default"
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(text, forKey: .text)
        try container.encodeIfPresent(category, forKey: .category)
        try container.encode(imageName, forKey: .imageName)
    }
}

class BergenFactsService: ObservableObject {
    @Published var facts: [BergenFact] = []
    @Published var currentFact: BergenFact?
    
    private var recentFacts: [BergenFact] = []
    private let maxRecentFacts = 5
    
    init() {
        loadFacts()
        showRandomFact()
    }
    
    private func loadFacts() {
        guard let url = Bundle.main.url(forResource: "bergen-facts", withExtension: "json"),
              let data = try? Data(contentsOf: url) else {
            print("Could not load bergen-facts.json")
            // Fallback facts if JSON loading fails
            facts = defaultFacts
            return
        }
        
        do {
            let factsData = try JSONDecoder().decode([BergenFact].self, from: data)
            facts = factsData
        } catch {
            print("Error decoding facts: \(error)")
            facts = defaultFacts
        }
    }
    
    func showRandomFact() {
        guard !facts.isEmpty else { return }
        
        // Filter out recently shown facts to avoid repetition
        let availableFacts = facts.filter { fact in
            !recentFacts.contains { $0.text == fact.text }
        }
        
        let factsToChooseFrom = availableFacts.isEmpty ? facts : availableFacts
        
        if let randomFact = factsToChooseFrom.randomElement() {
            currentFact = randomFact
            
            // Add to recent facts
            recentFacts.append(randomFact)
            if recentFacts.count > maxRecentFacts {
                recentFacts.removeFirst()
            }
        }
    }
    
    private var defaultFacts: [BergenFact] {
        [
            BergenFact(text: "Bergen ble grunnlagt omkring år 1070 og var Norges hovedstad på 1200-tallet.", category: "Historie", imageName: "01-grunnlagt-1070"),
            BergenFact(text: "Fisketorget i Bergen har vært en handelsplass i over 800 år.", category: "Historie", imageName: "02-fisketorget-800-aar"),
            BergenFact(text: "Bergen regner i gjennomsnitt 200 dager i året - mer enn noen annen norsk by.", category: "Vær", imageName: "03-regn-200-dager"),
            BergenFact(text: "Bryggen i Bergen er på UNESCOs verdensarvliste siden 1979.", category: "Kultur", imageName: "04-bryggen-unesco"),
            BergenFact(text: "Bergen er omringet av syv fjell, kjent som 'De syv fjell'.", category: "Geografi", imageName: "05-syv-fjell"),
            BergenFact(text: "Universitetet i Bergen ble grunnlagt i 1946 og er Norges nest eldste universitet.", category: "Utdanning", imageName: "06-uib-1946")
        ]
    }
}