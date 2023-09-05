//
//  QuestionFactoryProtocol.swift
//  MovieQuiz
//
//  Created by Глеб Капустин on 21.08.2023.
//

import Foundation

protocol QuestionFactoryProtocol {
    func moviesIsEmpty() -> Bool
    func requestNextQuestion()
    func loadData()
}
