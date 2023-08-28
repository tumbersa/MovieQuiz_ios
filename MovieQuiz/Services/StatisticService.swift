//
//  StatisticService.swift
//  MovieQuiz
//
//  Created by Глеб Капустин on 26.08.2023.
//

import Foundation

protocol StatisticService {
    func store(correct count: Int, total amount: Int)
    var totalAccuracy: Double { get }
    var gamesCount: Int { get }
    var bestGame: GameRecord { get }
}
struct GameRecord: Codable {
    let correct: Int
    let total: Int
    let date: Date
    func compare(to anotherObject: GameRecord) -> Bool {
        return correct > anotherObject.correct ? true: false
    }
}
final class StatisticServiceImplementation: StatisticService {
    func store(correct count: Int, total amount: Int) {
        gamesCount = gamesCount + 1
        
        let correct: Int = userDefaults.integer(forKey: Keys.correct.rawValue) + count
        let total: Int = userDefaults.integer(forKey: Keys.total.rawValue) + amount
        userDefaults.set(correct, forKey: Keys.correct.rawValue)
        userDefaults.set(total, forKey: Keys.total.rawValue)
        
        let newGame = GameRecord(correct: count, total: amount, date: Date())
        if newGame.compare(to: bestGame) {
            bestGame = newGame
        }
    }
    
    private let userDefaults = UserDefaults.standard
    
    private enum Keys: String {
        case correct, total, bestGame, gamesCount
    }
    var totalAccuracy: Double {
        get{
            let correct = Double(userDefaults.integer(forKey: Keys.correct.rawValue))
            let total = Double(userDefaults.integer(forKey: Keys.total.rawValue))
            if total != 0 {
                return correct / total * 100
            }
            else {
                return 0
            }
        }
    }
    
    var gamesCount: Int {
        get {
            return userDefaults.integer(forKey: Keys.gamesCount.rawValue)
        }
        set {
            userDefaults.set(newValue, forKey: Keys.gamesCount.rawValue)
        }
    }
    
    var bestGame: GameRecord {
        get {
            guard let data = userDefaults.data(forKey: Keys.bestGame.rawValue),
                  let record = try? JSONDecoder().decode(GameRecord.self, from: data) else {
                return .init(correct: 0, total: 0, date: Date())
            }
            return record
        }
        set {
            guard let data = try? JSONEncoder().encode(newValue) else {
                print("Невозможно сохранить результат")
                   return
            }
            userDefaults.set(data, forKey: Keys.bestGame.rawValue)
        }
    }
}
