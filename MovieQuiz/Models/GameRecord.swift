import Foundation

struct GameRecord: Codable {
    let correct: Int
    let total: Int
    let date: Date
    func compare(to anotherObject: GameRecord) -> Bool {
        return correct > anotherObject.correct
    }
}
