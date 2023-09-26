import UIKit

protocol AlertPresenterProtocol {
    func show(alertModel: AlertModel)
}

final class AlertPresenter: AlertPresenterProtocol{
    private weak var viewController: UIViewController?
    init(viewController: UIViewController? = nil) {
        self.viewController = viewController
    }
    func show(alertModel: AlertModel) {
        let alert = UIAlertController(
            title: alertModel.title,
            message: alertModel.message,
            preferredStyle: .alert)
        
        // константа с кнопкой для системного алерта
        let action = UIAlertAction(title: alertModel.buttonText, style: .default) {_ in
            alertModel.completion()
        }
        alert.view.accessibilityIdentifier = alertModel.identifier
        alert.addAction(action)
        viewController?.present(alert, animated: true)
    }
}
