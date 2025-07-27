import SwiftUI

struct BergenWordsQuizView: View {
    @EnvironmentObject private var audioService: AudioService
    @EnvironmentObject private var wordsService: BergenWordsService
    @Environment(\.dismiss) private var dismiss
    
    @State private var currentQuestionIndex: Int = 0
    @State private var quizQuestions: [QuizQuestion] = []
    @State private var selectedAnswer: String? = nil
    @State private var showingResult: Bool = false
    @State private var score: Int = 0
    @State private var answerOptions: [String] = []
    @State private var showOptions: Bool = false
    @State private var optionAnimationStates: [Bool] = [false, false, false, false]
    @State private var timeRemaining: Double = 15.0
    @State private var timer: Timer?
    @State private var isTimedOut: Bool = false
    @State private var showNextButton: Bool = false
    @State private var quizCompleted: Bool = false
    @State private var totalQuestions: Int = 10
    
    var currentQuestion: QuizQuestion? {
        guard currentQuestionIndex < quizQuestions.count else { return nil }
        return quizQuestions[currentQuestionIndex]
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background image
                if let question = currentQuestion,
                   UIImage(named: question.backgroundImage) != nil {
                    Image(question.backgroundImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .clipped()
                        .blur(radius: showingResult ? 8 : 0)
                        .animation(.easeInOut(duration: 0.3), value: showingResult)
                } else {
                    // Fallback gradient
                    LinearGradient(
                        gradient: Gradient(colors: [Color.blue.opacity(0.6), Color.green.opacity(0.4)]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .blur(radius: showingResult ? 8 : 0)
                    .animation(.easeInOut(duration: 0.3), value: showingResult)
                }
                
                Spacer()
                
                // Content
                VStack(spacing: 24) {
                    if let question = currentQuestion {
                        // Question text box
                        VStack(spacing: 16) {
                            VStack(spacing: 8) {
                                // Question title
                                Text("\(currentQuestionIndex + 1)/\(totalQuestions): KA BETYR")
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundColor(.white.opacity(0.6))
                                    .tracking(1.0)
                                
                                Text(question.term)
                                    .font(.system(size: 24, weight: .bold, design: .rounded))
                                    .multilineTextAlignment(.center)
                                    .foregroundColor(.white)
                            }
                            
                            // Timer bar inside question box
                            if showOptions && !showingResult {
                                GeometryReader { geometry in
                                    ZStack(alignment: .leading) {
                                        RoundedRectangle(cornerRadius: 3)
                                            .fill(.white.opacity(0.2))
                                            .frame(height: 4)
                                        
                                        RoundedRectangle(cornerRadius: 3)
                                            .fill(timeRemaining > 10 ? .white : (timeRemaining > 5 ? .orange : .red))
                                            .frame(width: geometry.size.width * (timeRemaining / 15.0), height: 4)
                                            .animation(.linear(duration: 0.1), value: timeRemaining)
                                    }
                                }
                                .frame(height: 4)
                            }
                            
                            // Show explanation after answer is selected
                            if showingResult, let explanation = question.explanation {
                                VStack(spacing: 8) {
                                    Rectangle()
                                        .fill(.white.opacity(0.3))
                                        .frame(height: 1)
                                        .frame(maxWidth: 120)
                                    
                                    Text(explanation)
                                        .font(.system(size: 16, weight: .medium, design: .default))
                                        .multilineTextAlignment(.center)
                                        .foregroundColor(.white.opacity(0.9))
                                        .italic()
                                }
                                .transition(.opacity.combined(with: .move(edge: .top)))
                            }
                        }
                        .padding(.horizontal, 24)
                        .padding(.vertical, 20)
                        .frame(maxWidth: .infinity, minHeight: 120, alignment: .center)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(.ultraThinMaterial.opacity(0.8))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(Color.black.opacity(0.6))
                                )
                                .shadow(color: .black.opacity(0.3), radius: 12, x: 0, y: 4)
                        )
                        .padding(.horizontal, 16)
                        
                        // Answer options in 2x2 grid with proper spacing
                        if showOptions {
                            VStack(spacing: 12) {
                                HStack(spacing: 12) {
                                    if answerOptions.count > 0 {
                                        QuizOptionButton(
                                            text: answerOptions[0],
                                            isSelected: selectedAnswer == answerOptions[0],
                                            isCorrect: showingResult && question.correctAnswers.contains(answerOptions[0]),
                                            isWrong: showingResult && selectedAnswer == answerOptions[0] && !question.correctAnswers.contains(answerOptions[0]),
                                            showResult: showingResult,
                                            isDisabled: selectedAnswer != nil || isTimedOut
                                        ) {
                                            selectAnswer(answerOptions[0])
                                        }
                                        .opacity(optionAnimationStates[0] ? 1.0 : 0.0)
                                        .scaleEffect(optionAnimationStates[0] ? 1.0 : 0.8)
                                        .animation(.spring(response: 0.4, dampingFraction: 0.6, blendDuration: 0).delay(0.0), value: optionAnimationStates[0])
                                    }
                                    
                                    if answerOptions.count > 1 {
                                        QuizOptionButton(
                                            text: answerOptions[1],
                                            isSelected: selectedAnswer == answerOptions[1],
                                            isCorrect: showingResult && question.correctAnswers.contains(answerOptions[1]),
                                            isWrong: showingResult && selectedAnswer == answerOptions[1] && !question.correctAnswers.contains(answerOptions[1]),
                                            showResult: showingResult,
                                            isDisabled: selectedAnswer != nil || isTimedOut
                                        ) {
                                            selectAnswer(answerOptions[1])
                                        }
                                        .opacity(optionAnimationStates[1] ? 1.0 : 0.0)
                                        .scaleEffect(optionAnimationStates[1] ? 1.0 : 0.8)
                                        .animation(.spring(response: 0.4, dampingFraction: 0.6, blendDuration: 0).delay(0.1), value: optionAnimationStates[1])
                                    }
                                }
                                
                                HStack(spacing: 12) {
                                    if answerOptions.count > 2 {
                                        QuizOptionButton(
                                            text: answerOptions[2],
                                            isSelected: selectedAnswer == answerOptions[2],
                                            isCorrect: showingResult && question.correctAnswers.contains(answerOptions[2]),
                                            isWrong: showingResult && selectedAnswer == answerOptions[2] && !question.correctAnswers.contains(answerOptions[2]),
                                            showResult: showingResult,
                                            isDisabled: selectedAnswer != nil || isTimedOut
                                        ) {
                                            selectAnswer(answerOptions[2])
                                        }
                                        .opacity(optionAnimationStates[2] ? 1.0 : 0.0)
                                        .scaleEffect(optionAnimationStates[2] ? 1.0 : 0.8)
                                        .animation(.spring(response: 0.4, dampingFraction: 0.6, blendDuration: 0).delay(0.2), value: optionAnimationStates[2])
                                    }
                                    
                                    if answerOptions.count > 3 {
                                        QuizOptionButton(
                                            text: answerOptions[3],
                                            isSelected: selectedAnswer == answerOptions[3],
                                            isCorrect: showingResult && question.correctAnswers.contains(answerOptions[3]),
                                            isWrong: showingResult && selectedAnswer == answerOptions[3] && !question.correctAnswers.contains(answerOptions[3]),
                                            showResult: showingResult,
                                            isDisabled: selectedAnswer != nil || isTimedOut
                                        ) {
                                            selectAnswer(answerOptions[3])
                                        }
                                        .opacity(optionAnimationStates[3] ? 1.0 : 0.0)
                                        .scaleEffect(optionAnimationStates[3] ? 1.0 : 0.8)
                                        .animation(.spring(response: 0.4, dampingFraction: 0.6, blendDuration: 0).delay(0.3), value: optionAnimationStates[3])
                                    }
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.top, 32)
                        }
                        
                        // Score display
                        if showOptions {
                            Text("\(score) / \(totalQuestions)")
                                .font(.system(size: 32, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                                .padding(.horizontal, 24)
                                .padding(.vertical, 12)
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(.ultraThinMaterial.opacity(0.8))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 16)
                                                .fill(Color.black.opacity(0.3))
                                        )
                                        .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
                                )
                                .padding(.top, 24)
                        }
                        
                        // Next button for timeout scenarios
                        if showNextButton {
                            VStack(spacing: 12) {
                                Button(action: {
                                    nextQuestion()
                                }) {
                                    Text("Neste")
                                        .font(.system(size: 18, weight: .semibold))
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 40)
                                        .padding(.vertical, 14)
                                        .background(
                                            RoundedRectangle(cornerRadius: 12)
                                                .fill(.blue.opacity(0.8))
                                                .shadow(color: .black.opacity(0.2), radius: 6, x: 0, y: 2)
                                        )
                                }
                                
                                Button(action: {
                                    showQuizComplete()
                                }) {
                                    Text("Avslutt quiz")
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(.white.opacity(0.8))
                                        .padding(.horizontal, 24)
                                        .padding(.vertical, 10)
                                        .background(
                                            RoundedRectangle(cornerRadius: 8)
                                                .fill(.black.opacity(0.3))
                                        )
                                }
                            }
                            .padding(.top, 20)
                        }
                    }
                    
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(.top, geometry.size.height * 0.15)
            }
            
            // Quiz completion overlay
            if quizCompleted {
                ZStack {
                    Color.black.opacity(0.8)
                        .ignoresSafeArea()
                    
                    VStack(spacing: 32) {
                        VStack(spacing: 16) {
                            Text("Quiz fullført!")
                                .font(.system(size: 32, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                            
                            Text("Din poengsum:")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(.white.opacity(0.8))
                            
                            Text("\(score) / \(totalQuestions)")
                                .font(.system(size: 48, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                            
                            let percentage = Int((Double(score) / Double(totalQuestions)) * 100)
                            Text("\(percentage)%")
                                .font(.system(size: 24, weight: .semibold))
                                .foregroundColor(.white.opacity(0.9))
                        }
                        
                        VStack(spacing: 16) {
                            Button(action: {
                                restartQuiz()
                            }) {
                                Text("Start ny quiz")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 40)
                                    .padding(.vertical, 16)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(.blue.opacity(0.8))
                                            .shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 4)
                                    )
                            }
                            
                            Button(action: {
                                dismiss()
                            }) {
                                Text("Tilbake til meny")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.white.opacity(0.8))
                                    .padding(.horizontal, 32)
                                    .padding(.vertical, 12)
                                    .background(
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(.black.opacity(0.3))
                                    )
                            }
                        }
                    }
                    .padding(.horizontal, 40)
                }
                .transition(.opacity.combined(with: .scale))
            }
        }
        .onAppear {
            loadQuizQuestions()
            // Music continues from Bergensk landing page - don't restart
        }
        .onDisappear {
            stopTimer()
        }
        .ignoresSafeArea(.container, edges: .top)
    }
    
    // MARK: - Helper Methods
    
    private func loadQuizQuestions() {
        let randomWords = wordsService.getRandomWords(count: totalQuestions)
        quizQuestions = randomWords.map { wordWithCategory in
            generateQuizQuestion(from: wordWithCategory)
        }
        currentQuestionIndex = 0
        score = 0
        quizCompleted = false
        loadCurrentQuestionOptions()
    }
    
    private func restartQuiz() {
        withAnimation(.easeInOut(duration: 0.3)) {
            quizCompleted = false
        }
        loadQuizQuestions()
    }
    
    private func generateQuizQuestion(from wordWithCategory: BergenWordWithCategory) -> QuizQuestion {
        let word = wordWithCategory.word
        
        return QuizQuestion(
            term: word.term,
            options: word.correctOptions + word.wrongOptions,
            correctAnswers: Set(word.correctOptions),
            explanation: word.longExplanation?.joined(separator: " "),
            backgroundImage: wordWithCategory.backgroundImage,
            category: wordWithCategory.category.chapter.chapter
        )
    }
    
    private func loadCurrentQuestionOptions() {
        guard let question = currentQuestion else { return }
        
        // Stop any existing timer
        timer?.invalidate()
        timer = nil
        
        // Get 1 correct answer and 3 random wrong options
        let correctAnswer = question.correctAnswers.randomElement() ?? ""
        let wrongOptions = Array(question.options.filter { !question.correctAnswers.contains($0) }.shuffled().prefix(3))
        
        // Combine and shuffle
        answerOptions = ([correctAnswer] + wrongOptions).shuffled()
        selectedAnswer = nil
        showingResult = false
        showOptions = false
        optionAnimationStates = [false, false, false, false]
        timeRemaining = 15.0
        isTimedOut = false
        showNextButton = false
        
        // Show options with delay and sequential animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            withAnimation(.easeInOut(duration: 0.3)) {
                showOptions = true
            }
            
            // Animate options sequentially
            for index in 0..<optionAnimationStates.count {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2 + Double(index) * 0.1) {
                    optionAnimationStates[index] = true
                }
            }
            
            // Start the timer after all options are shown
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                startTimer()
            }
        }
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            if timeRemaining > 0 {
                timeRemaining -= 0.1
            } else {
                handleTimeout()
            }
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    private func handleTimeout() {
        stopTimer()
        isTimedOut = true
        
        // Show result without selecting an answer
        withAnimation(.easeInOut(duration: 0.3)) {
            showingResult = true
            showNextButton = true
        }
    }
    
    private func selectAnswer(_ answer: String) {
        guard selectedAnswer == nil && !isTimedOut else { return } // Prevent multiple selections and disable after timeout
        
        // Stop the timer
        stopTimer()
        
        selectedAnswer = answer
        
        // Check if correct
        if let question = currentQuestion, question.correctAnswers.contains(answer) {
            score += 1
        }
        
        // Show result after a slightly longer delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            withAnimation(.easeInOut(duration: 0.3)) {
                showingResult = true
            }
            
            // Move to next question after showing result (only if not timed out)
            if !isTimedOut {
                DispatchQueue.main.asyncAfter(deadline: .now() + 4.5) {
                    nextQuestion()
                }
            }
        }
    }
    
    private func nextQuestion() {
        if currentQuestionIndex < quizQuestions.count - 1 {
            withAnimation(.easeInOut(duration: 0.3)) {
                currentQuestionIndex += 1
                loadCurrentQuestionOptions()
            }
        } else {
            // Quiz completed
            showQuizComplete()
        }
    }
    
    private func showQuizComplete() {
        stopTimer()
        withAnimation(.easeInOut(duration: 0.4)) {
            quizCompleted = true
        }
    }
}

struct QuizOptionButton: View {
    let text: String
    let isSelected: Bool
    let isCorrect: Bool
    let isWrong: Bool
    let showResult: Bool
    let isDisabled: Bool
    let action: () -> Void
    
    var backgroundColor: Color {
        if showResult {
            if isCorrect {
                return .green.opacity(0.8)
            } else if isWrong {
                return .red.opacity(0.8)
            } else {
                return .gray.opacity(0.6)
            }
        } else if isSelected {
            return .blue.opacity(0.8)
        } else {
            return .black.opacity(0.7)
        }
    }
    
    var textColor: Color {
        return .white
    }
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Text(text)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(textColor)
                    .multilineTextAlignment(.center)
                    .lineLimit(4)
                    .minimumScaleFactor(0.8)
                
                if showResult && isCorrect {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.white)
                        .font(.system(size: 18))
                } else if showResult && isWrong {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.white)
                        .font(.system(size: 18))
                } else if showResult {
                    // Empty space to maintain consistent height
                    Image(systemName: "circle")
                        .foregroundColor(.clear)
                        .font(.system(size: 18))
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 16)
            .frame(maxWidth: .infinity, minHeight: 80)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(backgroundColor)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.black.opacity(0.3))
                    )
                    .shadow(color: .black.opacity(0.2), radius: 6, x: 0, y: 2)
            )
        }
        .disabled(showResult || isDisabled)
        .opacity(isDisabled && !showResult ? 0.6 : 1.0)
        .scaleEffect(isSelected && !showResult ? 0.98 : 1.0)
        .animation(.easeInOut(duration: 0.1), value: isSelected)
    }
}

#Preview {
    BergenWordsQuizView()
        .environmentObject(AudioService())
        .environmentObject(BergenWordsService())
}