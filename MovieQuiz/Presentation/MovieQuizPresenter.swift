import UIKit

final class MovieQuizPresenter: QuestionFactoryDelegate {
  
    
    let questionsAmount: Int = 10
    private var currentQuestionIndex = 0
    var currentQuestion: QuizQuestion?
    var statisticService: StatisticServiceProtocol?
    weak var viewController: MovieQuizViewController?
    var questionFactory: QuestionFactoryProtocol?
    // переменная со счётчиком правильных ответов, начальное значение закономерно 0
     var correctAnswers = 0
    
    func yesButtonClicked() {
        didAnswer(isYes: true)
    }
    
    func noButtonClicked() {
       didAnswer(isYes: false)
    }
    
    private func didAnswer(isYes: Bool) {
        let givenAnswer = isYes
         guard let currentQuestion else {
             return
         }
         viewController?.showAnswerResult(
             isCorrect: currentQuestion.correctAnswer == givenAnswer)
    }
    
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
        viewController?.enableButtons()
        viewController?.hideLoadingIndicator()
        currentQuestion = question
        let viewModel = convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.viewController?.show(quiz: viewModel)
        }
    }
    
    func showNextQuestionOrResults() {
       if isLastQuestion() { // 1
           // идём в состояние "Результат квиза"
           viewController?.statisticService?.storeAnswersAndImmediatelyUpdateTotalAccuracy(correct: correctAnswers, total: questionsAmount)
           
           let text = makeResultMessage()
           let resultViewModel = QuizResultsViewModel(
               title: "Этот раунд окончен!",
               text: text,
               buttonText: "Сыграть ещё раз")
           
           viewController?.show(quiz: resultViewModel)
       } else { // 2
           switchToNextQuestion()
           questionFactory?.requestNextQuestion()
       }
        viewController?.enableButtons()
   }
    
    func makeResultMessage() -> String {
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
    
    func isLastQuestion() -> Bool {
        return currentQuestionIndex == questionsAmount - 1
    }
    
    func didAnswer(isCorrect: Bool) {
        if isCorrect {
            correctAnswers += 1
        }
    }
    
    func restartGame(){
        currentQuestionIndex = 0
        correctAnswers = 0
        questionFactory?.loadData()
    }
    
    func switchToNextQuestion(){
        currentQuestionIndex += 1
    }
    // метод конвертации, который принимает моковый вопрос и возвращает вью модель для экрана вопроса
    func convert(model: QuizQuestion) -> QuizStepViewModel {
        return QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
    }
}
