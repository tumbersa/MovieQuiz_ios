//
//  GameRecord.swift
//  MovieQuiz
//
//  Created by Глеб Капустин on 31.08.2023.
//

import Foundation

struct GameRecord: Codable {
    let correct: Int
    let total: Int
    let date: Date
    func compare(to anotherObject: GameRecord) -> Bool {
        return correct > anotherObject.correct
    }
}
