//
//  AlertPresenter.swift
//  MovieQuiz
//
//  Created by Глеб Капустин on 22.08.2023.
//

import UIKit

class AlertPresenter{
    weak var controller: MovieQuizViewController?
   
    // приватный метод для показа результатов раунда квиза
    // принимает вью модель QuizResultsViewModel и ничего не возвращает
    func show(quiz result: QuizResultsViewModel) {
        guard let controller else {return}
        let alertModel = AlertModel(
            title: result.title,
            message: result.text,
            buttonText: result.buttonText,
            completion: { _ in
            // код, который сбрасывает игру и показывает первый вопрос
            controller.currentQuestionIndex = 0
            controller.correctAnswers = 0
            controller.questionFactory?.requestNextQuestion()
        })
        
        let alert = UIAlertController(
            title: alertModel.title,
            message: alertModel.message,
            preferredStyle: .alert)
        
        // константа с кнопкой для системного алерта
        let action = UIAlertAction(title: alertModel.buttonText, style: .default) {_ in
            alertModel.completion(controller)}
        alert.addAction(action)
        controller.present(alert, animated: true, completion: nil)
    }
}
