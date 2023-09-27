import UIKit


final class MovieQuizViewController: UIViewController {
    // MARK: - Private properties
    private let presenter = MovieQuizPresenter()
     
     var alertPresenter: AlertPresenterProtocol?
     var statisticService: StatisticServiceProtocol?
   
    
    
    
    // MARK: - Private functions
   

   
   
     func showLoadingIndicator() {
        activityIndicator.startAnimating() 
    }
    
     func hideLoadingIndicator(){
        activityIndicator.stopAnimating()
    }
    
     func showNetworkError(message: String) {
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
                    self.presenter.questionFactory?.requestNextQuestion()
                }
            } else {
                self.presenter.restartGame()
                
                
                
            }
        }
        alertPresenter?.show(alertModel: alertError)
    }
    
     func show(quiz step: QuizStepViewModel) {
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 0
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
    }
   
    // приватный метод, который меняет цвет рамки
     func showAnswerResult(isCorrect: Bool) {
         presenter.didAnswer(isCorrect: isCorrect)
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrect ?
        UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        yesButton.isEnabled = false
        noButton.isEnabled = false
        // запускаем задачу через 1 секунду c помощью диспетчера задач
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self else {return}
            self.presenter.showNextQuestionOrResults()
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
                self.presenter.restartGame()
            }
        )
        alertPresenter?.show(alertModel: alertModel)
    }
     func makeResultMessage() -> String {
        guard let statisticService else {
            return ""
        }
         let currentGameResultLine = "Ваш результат \(presenter.correctAnswers)/\(presenter.questionsAmount)"
        let totalPlaysCountLine = "Количество сыгранных квизов: \(statisticService.gamesCount)"
        let bestGameInfoLine = "Рекорд: \(statisticService.bestGame.correct)/\(statisticService.bestGame.total) (\(statisticService.bestGame.date.dateTimeString))"
        let accuracyLine = "Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%"
        
        let components = [currentGameResultLine,totalPlaysCountLine,bestGameInfoLine,accuracyLine]
        let resultMessage = components.joined(separator: "\n")
        return resultMessage
    }
    func enableButtons(){
        yesButton.isEnabled = true
        noButton.isEnabled = true
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
        presenter.yesButtonClicked()
    }
    
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        presenter.noButtonClicked()
    }
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        presenter.viewController = self
        
        activityIndicator.hidesWhenStopped = true
        alertPresenter = AlertPresenter(viewController: self)
        presenter.questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: presenter)
        statisticService = StatisticServiceImplementation()
        
        showLoadingIndicator()
        presenter.questionFactory?.loadData()
    }
}
