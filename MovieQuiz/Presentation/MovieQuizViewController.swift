import UIKit

protocol MovieQuizViewControllerProtocol: AnyObject {
    func show(quiz step: QuizStepViewModel)
    func show(quiz result: QuizResultsViewModel)
    
    func highlightImageBorder(isCorrect: Bool)
    func showLoadingIndicator()
    func hideLoadingIndicator()
    func enableButtons(isYes: Bool)
    
    func showNetworkError(message: String)
}

final class MovieQuizViewController: UIViewController, MovieQuizViewControllerProtocol {
    // MARK: - Private properties
    private var presenter: MovieQuizPresenter?
    
    private var alertPresenter: AlertPresenterProtocol?
    
    // MARK: - Functions
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
                enableButtons(isYes: false)
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    self.presenter?.imageLoadError()
                }
            } else {
                self.presenter?.restartGame()
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
   
    func highlightImageBorder(isCorrect: Bool) {
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrect ?
        UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
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
                self.presenter?.restartGame()
            }
        )
        alertPresenter?.show(alertModel: alertModel)
    }
     
    func enableButtons(isYes: Bool){
        if isYes {
            yesButton.isEnabled = true
            noButton.isEnabled = true
        }
        else {
            yesButton.isEnabled = false
            noButton.isEnabled = false
        }
    }
    
    // MARK: - IB Outlets
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var counterLabel: UILabel!
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet private weak var noButton: UIButton!
    @IBOutlet private weak var yesButton: UIButton!
    
    // MARK: - Actions
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        presenter?.yesButtonClicked()
    }
    
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        presenter?.noButtonClicked()
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        activityIndicator.hidesWhenStopped = true
        
        presenter = MovieQuizPresenter(viewController: self)
        alertPresenter = AlertPresenter(viewController: self)
    }
}
