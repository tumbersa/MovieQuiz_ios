//
//  StatisticService.swift
//  MovieQuiz
//
//  Created by Глеб Капустин on 26.08.2023.
//

import Foundation

extension Double {
    func decimalCount() -> Int {
        if self == Double(Int(self)) {
            return 0
        }

        let integerString = String(Int(self))
        let doubleString = String(Double(self))
        let decimalCount = doubleString.count - integerString.count - 1

        return decimalCount
    }
}
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
    func reset() {
        gamesCount = 0
        bestGame = GameRecord(correct: 0, total: 0, date: Date())
        totalAccuracy = 0.0
    }
    func store(correct count: Int, total amount: Int) {
        //reset()
        gamesCount = gamesCount + 1
        
        let correct = userDefaults.integer(forKey: Keys.correct.rawValue) + count
        let total = userDefaults.integer(forKey: Keys.total.rawValue) + amount
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
                return correct / total
            }
            else {
                return 0
            }
        }
        set {
            let total: Int = Int(pow(10, Double(newValue.decimalCount())))
            let correct: Int = Int(newValue * Double(total))
            userDefaults.set(correct, forKey: Keys.correct.rawValue)
            if total != 1{
                userDefaults.set(total, forKey: Keys.total.rawValue)
            } else {
                userDefaults.set(0, forKey: Keys.total.rawValue)
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
