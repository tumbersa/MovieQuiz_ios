//
//  QuestionFactoryDelegate.swift
//  MovieQuiz
//
//  Created by Глеб Капустин on 22.08.2023.
//

import Foundation

protocol QuestionFactoryDelegate: AnyObject {
    func didReceiveNextQuestion(question: QuizQuestion?)
}
