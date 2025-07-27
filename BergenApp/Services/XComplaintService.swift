import Foundation

struct XPost: Codable, Identifiable {
    let id: String
    let post: PostContent
}

struct PostContent: Codable {
    let characters: Int
    let length: String
    let topic: String
    let weather: String
    let sentiment: String
    let platform: String
    let text: String
}

struct XComplaintList: Codable {
    let posts: [XPost]
}

class XComplaintService: ObservableObject {
    @Published var posts: [XPost] = []
    @Published var selectedPost: XPost?
    @Published var currentWeather: String = "rainy" // Default to rainy for Bergen
    
    init() {
        loadPosts()
    }
    
    private func loadPosts() {
        guard let url = Bundle.main.url(forResource: "x-complaints", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let xData = try? JSONDecoder().decode(XComplaintList.self, from: data) else {
            print("Failed to load X complaint posts")
            return
        }
        
        self.posts = xData.posts
        updateSelectedPost()
    }
    
    func generatePost() -> String {
        guard let post = selectedPost else {
            return "Ingen innlegg valgt"
        }
        
        return post.post.text
    }
    
    func selectPost(_ post: XPost) {
        selectedPost = post
    }
    
    func updateWeather(isRainy: Bool) {
        currentWeather = isRainy ? "rainy" : "sun"
        updateSelectedPost()
    }
    
    private func updateSelectedPost() {
        // Filter posts based on current weather
        let weatherPosts = posts.filter { post in
            post.post.weather == currentWeather
        }
        
        // Select first post that matches current weather, or fallback to first post
        selectedPost = weatherPosts.first ?? posts.first
    }
    
    var availablePosts: [XPost] {
        return posts.filter { post in
            post.post.weather == currentWeather
        }
    }
}