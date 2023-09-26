import UIKit


final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
    // MARK: - Private properties
    private let presenter = MovieQuizPresenter()
    private var questionFactory: QuestionFactoryProtocol?
    private var currentQuestion: QuizQuestion?
    private var alertPresenter: AlertPresenterProtocol?
    private var statisticService: StatisticServiceProtocol?
   
    
    // переменная со счётчиком правильных ответов, начальное значение закономерно 0
    private var correctAnswers = 0
    
    // MARK: - Private functions
    func didLoadDataFromServer() {
        hideLoadingIndicator()
        questionFactory?.requestNextQuestion()
    }

    func didFailToLoadData(with error: Error) {
        if let error: NetworkError = error as? NetworkError {
            showNetworkError(message: error.rawValue)
        }
        showNetworkError(message: error.localizedDescription) // возьмём в качестве сообщения описание ошибки
        
    }
   
    private func showLoadingIndicator() {
        activityIndicator.startAnimating() 
    }
    
    private func hideLoadingIndicator(){
        activityIndicator.stopAnimating()
    }
    
    private func showNetworkError(message: String) {
        hideLoadingIndicator()
        let alertMessage: String = message

        let alertError = AlertModel(title: "Ошибка", message: alertMessage, buttonText: "Попробуйте ещё раз",identifier: "Error alert") {[weak self] in
            guard let self else {return}
            if message == NetworkError.imageLoadError.rawValue {
                showLoadingIndicator()
                imageView.image = nil
                imageView.layer.masksToBounds = true
                imageView.layer.borderWidth = 0
                yesButton.isEnabled = false
                noButton.isEnabled = false
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    self.questionFactory?.requestNextQuestion()
                }
            } else {
                self.presenter.resetQuestionIndex()
                self.correctAnswers = 0
                
                self.questionFactory?.loadData()
            }
        }
        alertPresenter?.show(alertModel: alertError)
    }
    
    private func show(quiz step: QuizStepViewModel) {
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 0
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
    }
   
    // приватный метод, который меняет цвет рамки
    private func showAnswerResult(isCorrect: Bool) {
        if isCorrect {
            correctAnswers += 1
        }
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrect ?
        UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        yesButton.isEnabled = false
        noButton.isEnabled = false
        // запускаем задачу через 1 секунду c помощью диспетчера задач
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self else {return}
            self.showNextQuestionOrResults()
        }
    }
    // вызов алерта
    func show(quiz result: QuizResultsViewModel) {
        //TODO: - call alertPresenter
        let alertModel = AlertModel(
            title: result.title,
            message: result.text,
            buttonText: result.buttonText,
            identifier: "Game results",
            completion: { [weak self] in
                guard let self else {return}
                self.presenter.resetQuestionIndex()
                self.correctAnswers = 0
                self.questionFactory?.requestNextQuestion()
            }
        )
        alertPresenter?.show(alertModel: alertModel)
    }
    private func makeResultMessage() -> String {
        guard let statisticService else {
            return ""
        }
        let currentGameResultLine = "Ваш результат \(correctAnswers)/\(presenter.questionsAmount)"
        let totalPlaysCountLine = "Количество сыгранных квизов: \(statisticService.gamesCount)"
        let bestGameInfoLine = "Рекорд: \(statisticService.bestGame.correct)/\(statisticService.bestGame.total) (\(statisticService.bestGame.date.dateTimeString))"
        let accuracyLine = "Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%"
        
        let components = [currentGameResultLine,totalPlaysCountLine,bestGameInfoLine,accuracyLine]
        let resultMessage = components.joined(separator: "\n")
        return resultMessage
    }
    // приватный метод, который содержит логику перехода в один из сценариев
    private func showNextQuestionOrResults() {
        if presenter.isLastQuestion() { // 1
            // идём в состояние "Результат квиза"
            statisticService?.storeAnswersAndImmediatelyUpdateTotalAccuracy(correct: correctAnswers, total: presenter.questionsAmount)
            
            let text = makeResultMessage()
            let resultViewModel = QuizResultsViewModel(
                title: "Этот раунд окончен!",
                text: text,
                buttonText: "Сыграть ещё раз")
            
            show(quiz: resultViewModel)
        } else { // 2
            presenter.switchToNextQuestion()
            questionFactory?.requestNextQuestion()
        }
        yesButton.isEnabled = true
        noButton.isEnabled = true
    }
    
    // MARK: - QuestionFactoryDelegate
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question else {
            return
        }
        yesButton.isEnabled = true
        noButton.isEnabled = true
        hideLoadingIndicator()
        currentQuestion = question
        let viewModel = presenter.convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.show(quiz: viewModel)
        }
    }
    // MARK: - IB Outlets
    //картинка постера фильма
    @IBOutlet private weak var imageView: UIImageView!
    //счетчик вопросов
    @IBOutlet private weak var counterLabel: UILabel!
    //текст вопроса
    @IBOutlet private weak var textLabel: UILabel!
    
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var noButton: UIButton!
    @IBOutlet weak var yesButton: UIButton!
    
    // MARK: - Actions
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        let givenAnswer = true
        guard let currentQuestion else {
            return
        }
        showAnswerResult(
            isCorrect: currentQuestion.correctAnswer == givenAnswer)
    }
    
    @IBAction private func noButtonClicked(_ sender: UIButton) {
       let givenAnswer = false
        guard let currentQuestion else {
            return
        }
        showAnswerResult(
            isCorrect: currentQuestion.correctAnswer == givenAnswer)
    }
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        

        activityIndicator.hidesWhenStopped = true
        alertPresenter = AlertPresenter(viewController: self)
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        statisticService = StatisticServiceImplementation()
        
        showLoadingIndicator()
        questionFactory?.loadData()
    }
}
