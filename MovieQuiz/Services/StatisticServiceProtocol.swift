//
//  StatisticServiceProtocol.swift
//  MovieQuiz
//
//  Created by Глеб Капустин on 31.08.2023.
//

import Foundation

protocol StatisticServiceProtocol {
    func store(correct count: Int, total amount: Int)
    var totalAccuracy: Double { get }
    var gamesCount: Int { get }
    var bestGame: GameRecord { get }
}
