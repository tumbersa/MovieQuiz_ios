import UIKit

final class MovieQuizPresenter: QuestionFactoryDelegate {
    // MARK: - Private properties
    private let questionsAmount: Int = 10
    private var currentQuestionIndex = 0
    private var currentQuestion: QuizQuestion?
    private var statisticService: StatisticServiceProtocol!
    private weak var viewController: MovieQuizViewControllerProtocol?
    private var questionFactory: QuestionFactoryProtocol?
    private var correctAnswers = 0
    
    init(viewController: MovieQuizViewControllerProtocol) {
        self.viewController = viewController
        
        statisticService = StatisticServiceImplementation()
        
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        questionFactory?.loadData()
        viewController.showLoadingIndicator()
    }
    
    // MARK: - Internal functions
    func imageLoadError() {
        questionFactory?.requestNextQuestion()
    }
   
    func restartGame(){
        currentQuestionIndex = 0
        correctAnswers = 0
        questionFactory?.loadData()
    }
    func yesButtonClicked() {
        didAnswer(isYes: true)
    }
    
    func noButtonClicked() {
       didAnswer(isYes: false)
    }
    
    //MARK: - Private functions
    private func proceedWithAnswer(isCorrect: Bool) {
        if isCorrect {
            correctAnswers += 1
        }
         viewController?.highlightImageBorder(isCorrect: isCorrect)
         viewController?.enableButtons(isYes: false)
        // запускаем задачу через 1 секунду c помощью диспетчера задач
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self else {return}
            self.proceedToNextQuestionOrResults()
        }
    }
    
    private func didAnswer(isYes: Bool) {
        let givenAnswer = isYes
         guard let currentQuestion else {
             return
         }
         proceedWithAnswer(
             isCorrect: currentQuestion.correctAnswer == givenAnswer)
    }
    
    private func makeResultMessage() -> String {
       guard let statisticService else {
           return ""
       }
       let currentGameResultLine = "Ваш результат \(correctAnswers)/\(questionsAmount)"
       let totalPlaysCountLine = "Количество сыгранных квизов: \(statisticService.gamesCount)"
       let bestGameInfoLine = "Рекорд: \(statisticService.bestGame.correct)/\(statisticService.bestGame.total) (\(statisticService.bestGame.date.dateTimeString))"
       let accuracyLine = "Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%"
       
       let components = [currentGameResultLine,totalPlaysCountLine,bestGameInfoLine,accuracyLine]
       let resultMessage = components.joined(separator: "\n")
       return resultMessage
   }
    
    private func proceedToNextQuestionOrResults() {
        if currentQuestionIndex == questionsAmount - 1 { // 1
           // идём в состояние "Результат квиза"
           statisticService?.storeAnswersAndImmediatelyUpdateTotalAccuracy(correct: correctAnswers, total: questionsAmount)
           
           let text = makeResultMessage()
           let resultViewModel = QuizResultsViewModel(
               title: "Этот раунд окончен!",
               text: text,
               buttonText: "Сыграть ещё раз")
           
           viewController?.show(quiz: resultViewModel)
       } else { // 2
           currentQuestionIndex += 1
           questionFactory?.requestNextQuestion()
       }
        viewController?.enableButtons(isYes: true)
   }
   
    func convert(model: QuizQuestion) -> QuizStepViewModel {
        return QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
    }
    
    //MARK: - Question Factory Delegate
    func didLoadDataFromServer() {
        viewController?.hideLoadingIndicator()
        questionFactory?.requestNextQuestion()
    }
    
    func didFailToLoadData(with error: Error) {
        if let error: NetworkError = error as? NetworkError {
            viewController?.showNetworkError(message: error.rawValue)
        }
        viewController?.showNetworkError(message: error.localizedDescription) // возьмём в качестве сообщения описание ошибки
        
    }
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question else {
            return
        }
        viewController?.enableButtons(isYes: true)
        viewController?.hideLoadingIndicator()
        currentQuestion = question
        let viewModel = convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.viewController?.show(quiz: viewModel)
        }
    }
    
}
