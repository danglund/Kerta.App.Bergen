import Foundation

class BergenWordsService: ObservableObject {
    @Published var categories: [BergenWordCategory] = []
    @Published var allWords: [BergenWordWithCategory] = []
    @Published var isLoading: Bool = true
    
    private let jsonFiles = [
        "bergenske-uttrykk",
        "bergenske-ord-betydning", 
        "dialektord-ting-tang",
        "dialektord-personer"
    ]
    
    init() {
        loadAllWords()
    }
    
    private func loadAllWords() {
        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let self = self else { return }
            
            var loadedCategories: [BergenWordCategory] = []
            var loadedWords: [BergenWordWithCategory] = []
            
            for fileName in self.jsonFiles {
                if let category = self.loadWordsFromFile(fileName) {
                    loadedCategories.append(category)
                    
                    // Convert words to BergenWordWithCategory
                    let wordsWithCategory = category.chapter.entries.map { word in
                        BergenWordWithCategory(word: word, category: category)
                    }
                    loadedWords.append(contentsOf: wordsWithCategory)
                }
            }
            
            DispatchQueue.main.async {
                self.categories = loadedCategories
                self.allWords = loadedWords.shuffled() // Pre-shuffle for random selection
                self.isLoading = false
                print("📚 Loaded \(loadedWords.count) Bergen words from \(loadedCategories.count) categories")
            }
        }
    }
    
    private func loadWordsFromFile(_ fileName: String) -> BergenWordCategory? {
        // Try with subdirectory first, then without
        var url: URL?
        
        // First try: with BergenWords subdirectory
        url = Bundle.main.url(forResource: fileName, withExtension: "json", subdirectory: "BergenWords")
        
        // Second try: without subdirectory (in case files are in root)
        if url == nil {
            url = Bundle.main.url(forResource: fileName, withExtension: "json")
        }
        
        guard let fileURL = url,
              let data = try? Data(contentsOf: fileURL) else {
            print("❌ Could not load \(fileName).json from bundle")
            return nil
        }
        
        do {
            let chapter = try JSONDecoder().decode(BergenWordChapter.self, from: data)
            let category = BergenWordCategory(chapter: chapter)
            print("✅ Loaded \(chapter.entries.count) words from \(chapter.chapter)")
            return category
        } catch {
            print("❌ Error decoding \(fileName).json: \(error)")
            return nil
        }
    }
    
    // MARK: - Public methods for getting random words
    
    func getRandomWord() -> BergenWordWithCategory? {
        return allWords.randomElement()
    }
    
    func getRandomWords(count: Int) -> [BergenWordWithCategory] {
        return Array(allWords.shuffled().prefix(count))
    }
    
    func getWordsFromCategory(_ categoryName: String, count: Int? = nil) -> [BergenWordWithCategory] {
        let categoryWords = allWords.filter { $0.category.chapter.chapter == categoryName }
        if let count = count {
            return Array(categoryWords.shuffled().prefix(count))
        }
        return categoryWords.shuffled()
    }
    
    func getCategoryNames() -> [String] {
        return categories.map { $0.chapter.chapter }
    }
}

// MARK: - Quiz specific functionality
extension BergenWordsService {
    func generateQuizQuestion(from wordWithCategory: BergenWordWithCategory) -> QuizQuestion {
        let word = wordWithCategory.word
        
        // Combine correct and wrong options, then shuffle
        var allOptions = word.correctOptions + word.wrongOptions
        allOptions.shuffle()
        
        return QuizQuestion(
            term: word.term,
            options: allOptions,
            correctAnswers: Set(word.correctOptions),
            explanation: word.longExplanation?.joined(separator: " "),
            backgroundImage: wordWithCategory.backgroundImage,
            category: wordWithCategory.category.chapter.chapter
        )
    }
}

// MARK: - Quiz Question model
struct QuizQuestion: Identifiable {
    let id = UUID()
    let term: String
    let options: [String]
    let correctAnswers: Set<String>
    let explanation: String?
    let backgroundImage: String
    let category: String
}

// MARK: - Quiz State
class QuizState: ObservableObject {
    @Published var questions: [QuizQuestion] = []
    @Published var currentQuestionIndex: Int = 0
    @Published var selectedAnswers: Set<String> = []
    @Published var score: Int = 0
    @Published var showingResult: Bool = false
    @Published var isComplete: Bool = false
    
    var currentQuestion: QuizQuestion? {
        guard currentQuestionIndex < questions.count else { return nil }
        return questions[currentQuestionIndex]
    }
    
    var totalQuestions: Int {
        return questions.count
    }
    
    func selectAnswer(_ answer: String) {
        if selectedAnswers.contains(answer) {
            selectedAnswers.remove(answer)
        } else {
            selectedAnswers.insert(answer)
        }
    }
    
    func submitAnswer() {
        guard let question = currentQuestion else { return }
        
        // Check if any selected answer is correct
        let isCorrect = !selectedAnswers.intersection(question.correctAnswers).isEmpty
        
        if isCorrect {
            score += 1
        }
        
        showingResult = true
    }
    
    func nextQuestion() {
        selectedAnswers.removeAll()
        showingResult = false
        
        if currentQuestionIndex < questions.count - 1 {
            currentQuestionIndex += 1
        } else {
            isComplete = true
        }
    }
    
    func resetQuiz() {
        currentQuestionIndex = 0
        selectedAnswers.removeAll()
        score = 0
        showingResult = false
        isComplete = false
    }
}