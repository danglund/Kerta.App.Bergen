import Foundation

struct ComplaintTemplate: Codable, Identifiable {
    let id: String
    let title: String
    let category: String
    let characters: Int
    let length: String
    let topic: String
    let weather: String?
    let sentiment: String
    let text: String
    let placeholders: [String: PlaceholderInfo]
}

struct PlaceholderInfo: Codable {
    let description: String
    let example: String
}

struct Newspaper: Codable, Identifiable {
    let id: String
    let name: String
    let fullName: String
    let type: String
    let email: String
    let website: String
}

struct ComplaintTemplates: Codable {
    let templates: [ComplaintTemplate]
}

struct NewspaperList: Codable {
    let newspapers: [Newspaper]
}

class NewspaperComplaintService: ObservableObject {
    @Published var templates: [ComplaintTemplate] = []
    @Published var newspapers: [Newspaper] = []
    @Published var selectedTemplate: ComplaintTemplate?
    @Published var selectedNewspaper: Newspaper?
    @Published var currentWeather: String = "rainy" // Default to rainy for Bergen
    
    init() {
        loadTemplates()
        loadNewspapers()
    }
    
    private func loadTemplates() {
        guard let url = Bundle.main.url(forResource: "newspaper-complaints", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let complaintData = try? JSONDecoder().decode(ComplaintTemplates.self, from: data) else {
            print("Failed to load newspaper complaint templates")
            return
        }
        
        self.templates = complaintData.templates
        updateSelectedTemplate()
    }
    
    private func loadNewspapers() {
        guard let url = Bundle.main.url(forResource: "newspapers", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let newspaperData = try? JSONDecoder().decode(NewspaperList.self, from: data) else {
            print("Failed to load newspaper list")
            return
        }
        
        self.newspapers = newspaperData.newspapers
        self.selectedNewspaper = newspapers.first
    }
    
    func generateComplaint() -> String {
        guard let template = selectedTemplate,
              let newspaper = selectedNewspaper else {
            return "Ingen mal eller avis valgt"
        }
        
        var complaintText = template.text
        
        // Replace placeholders with actual newspaper name
        for (placeholder, _) in template.placeholders {
            complaintText = complaintText.replacingOccurrences(of: "[\(placeholder)]", with: newspaper.name)
        }
        
        return complaintText
    }
    
    func selectNewspaper(_ newspaper: Newspaper) {
        selectedNewspaper = newspaper
    }
    
    func selectTemplate(_ template: ComplaintTemplate) {
        selectedTemplate = template
    }
    
    func updateWeather(isRainy: Bool) {
        currentWeather = isRainy ? "rainy" : "sunny"
        updateSelectedTemplate()
    }
    
    private func updateSelectedTemplate() {
        // Filter templates based on current weather
        let weatherTemplates = templates.filter { template in
            template.weather == currentWeather
        }
        
        // Select first template that matches current weather, or fallback to first template
        selectedTemplate = weatherTemplates.first ?? templates.first
    }
    
    var availableTemplates: [ComplaintTemplate] {
        return templates.filter { template in
            template.weather == currentWeather
        }
    }
}