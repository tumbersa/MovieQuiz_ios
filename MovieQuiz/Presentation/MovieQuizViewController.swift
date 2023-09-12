import UIKit


final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
    // MARK: - Private properties
    private let questionsAmount: Int = 10
    private var questionFactory: QuestionFactoryProtocol?
    private var currentQuestion: QuizQuestion?
    private var alertPresenter: AlertPresenterProtocol?
    private var statisticService: StatisticServiceProtocol?
   
    // переменная с индексом текущего вопроса, начальное значение 0
    // (по этому индексу будем искать вопрос в массиве, где индекс первого элемента 0, а не 1)
    private var currentQuestionIndex = 0
    // переменная со счётчиком правильных ответов, начальное значение закономерно 0
    private var correctAnswers = 0
    
    // MARK: - Private functions
    func didLoadDataFromServer() {
        hideLoadingIndicator()
        questionFactory?.requestNextQuestion()
    }

    func didFailToLoadData(with error: Error) {
        showNetworkError(message: error.localizedDescription) // возьмём в качестве сообщения описание ошибки
        
    }
    // метод конвертации, который принимает моковый вопрос и возвращает вью модель для экрана вопроса
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        return QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
    }
    private func showLoadingIndicator() {
        activityIndicator.startAnimating() // включаем анимацию
    }
    private func hideLoadingIndicator(){
        activityIndicator.stopAnimating()
    }
    private func showNetworkError(message: String) {
        hideLoadingIndicator() // скрываем индикатор загрузки
        var alertMessage: String
        switch message {
        case NetworkError.dataLoadError.localizedDescription,
            NetworkError.imageLoadError.localizedDescription:
            alertMessage = "The Internet connection appears to be offline."
        case  NetworkError.codeError.localizedDescription:
            alertMessage = "Code Error"
        case NetworkError.keyAPIError.localizedDescription:
            alertMessage = "API key Error"
        default:
            alertMessage = message
        }
        let alertError = AlertModel(title: "Ошибка", message: alertMessage, buttonText: "Попробуйте ещё раз") {[weak self] in
            guard let self else {return}
            
            switch message {
            case NetworkError.dataLoadError.localizedDescription,
                NetworkError.codeError.localizedDescription,
                NetworkError.keyAPIError.localizedDescription:
                self.currentQuestionIndex = 0
                self.correctAnswers = 0
                
                self.questionFactory?.loadData()
            case NetworkError.imageLoadError.localizedDescription:
                showLoadingIndicator()
                imageView.image = nil
                imageView.layer.masksToBounds = true
                imageView.layer.borderWidth = 0
                yesButton.isEnabled = false
                noButton.isEnabled = false
                DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                    self.questionFactory?.requestNextQuestion()
                }
            default:
                fatalError(message)
            }
        }
        alertPresenter?.show(alertModel: alertError)
    }
    // приватный метод вывода на экран вопроса, который принимает на вход вью модель вопроса и ничего не возвращает
    private func show(quiz step: QuizStepViewModel) {
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 0
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
    }
   
    // приватный метод, который меняет цвет рамки
    // принимает на вход булевое значение и ничего не возвращает
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
           // код, который мы хотим вызвать через 1 секунду
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
            completion: { [weak self] in
                self?.currentQuestionIndex = 0
                self?.correctAnswers = 0
                self?.questionFactory?.requestNextQuestion()
            }
        )
        alertPresenter?.show(alertModel: alertModel)
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
    // приватный метод, который содержит логику перехода в один из сценариев
    private func showNextQuestionOrResults() {
        if currentQuestionIndex == questionsAmount - 1 { // 1
            // идём в состояние "Результат квиза"
            statisticService?.store(correct: correctAnswers, total: questionsAmount)
            
            let text = makeResultMessage()
            let resultViewModel = QuizResultsViewModel(
                title: "Этот раунд окончен!",
                text: text,
                buttonText: "Сыграть ещё раз")
            
            show(quiz: resultViewModel)
        } else { // 2
            currentQuestionIndex += 1
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
        let viewModel = convert(model: question)
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
