//
//  QuestionFactory.swift
//  MovieQuiz
//
//  Created by Глеб Капустин on 21.08.2023.
//

import Foundation

final class QuestionFactory: QuestionFactoryProtocol {
    private var movies: [Movie] = []
    private var errorMessage: String = ""
    private let moviesLoader: MoviesLoading
    private weak var delegate: QuestionFactoryDelegate?
    
    init(moviesLoader: MoviesLoading, delegate: QuestionFactoryDelegate) {
        self.moviesLoader = moviesLoader
        self.delegate = delegate
    }
    
    //MARK: -functions
    func requestNextQuestion() {
        DispatchQueue.global().async {[weak self] in
            guard let self else {return}
            let index = (0..<self.movies.count).randomElement() ?? 0

            guard let movie = movies[safe: index] else {
                DispatchQueue.main.async {
                  print(self.errorMessage)
                    self.delegate?.didFailToLoadData(with: NetworkError.keyAPIError)
                }
                return
            }
            
            var imageData = Data()
          
            do {
                imageData = try Data(contentsOf: movie.resizedImageURL)
            } catch {
                DispatchQueue.main.async {
                    self.delegate?.didFailToLoadData(with: NetworkError.imageLoadError)
                }
                return
            }
            
            let rating = Decimal(floatLiteral: Double(movie.rating) ?? 0)
            var text = "Рейтинг этого фильма больше чем 8.1?"
            var correctAnswer = rating > 8.1
            
            let coefficients:[Double] = [-0.1, 0.1]
            let coefficient =  Decimal(floatLiteral:coefficients.randomElement() ?? 0)
            
            if [0,1].randomElement() ?? 0 == 0 {
                text = "Рейтинг этого фильма больше чем \( rating + coefficient)?"
                correctAnswer = rating > rating + coefficient
            } else {
                text = "Рейтинг этого фильма меньше чем \(rating + coefficient)?"
                correctAnswer = rating < rating +  coefficient
            }
           
            
            
            let question = QuizQuestion(image: imageData, text: text, correctAnswer: correctAnswer)
            DispatchQueue.main.async {[weak self] in
                guard let self else {return}
                self.delegate?.didReceiveNextQuestion(question: question)
            }
        }
    }
    
    func loadData() {
            moviesLoader.loadMovies{ [weak self] result in
            DispatchQueue.main.async {
                guard let self else {
                    print("self")
                    return
                }
                switch result {
                case .success(let mostPopularMovies):
                        self.movies = mostPopularMovies
                        self.delegate?.didLoadDataFromServer()
                case .failure(_):
                    self.delegate?.didFailToLoadData(with: NetworkError.dataLoadError)
                }
            }
        }
    }
    
}
