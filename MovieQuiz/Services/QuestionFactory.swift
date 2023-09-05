//
//  QuestionFactory.swift
//  MovieQuiz
//
//  Created by Глеб Капустин on 21.08.2023.
//

import Foundation

final class QuestionFactory: QuestionFactoryProtocol {
    private var movies: [MostPopularMovie] = []
    private let moviesLoader: MoviesLoading
    private weak var delegate: QuestionFactoryDelegate?
    init(moviesLoader: MoviesLoading, delegate: QuestionFactoryDelegate) {
        self.moviesLoader = moviesLoader
        self.delegate = delegate
    }
    func moviesIsEmpty() -> Bool {
        return movies.isEmpty
    }
    func requestNextQuestion() {
        DispatchQueue.global().async {[weak self] in
            guard let self else {return}
            let index = (0..<self.movies.count).randomElement() ?? 0

            guard let movie = movies[safe: index] else {
                DispatchQueue.main.async {
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
            
            
            let rating = Float(movie.rating) ?? 0
            let text = "Рейтинг этого фильма больше чем 8.1?"
            let correctAnswer = rating > 8.1
            
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
                    self.movies = mostPopularMovies.items
                    self.delegate?.didLoadDataFromServer()
                case .failure(_):
                    self.delegate?.didFailToLoadData(with: NetworkError.dataLoadError)
                }
            }
        }
    }
    
}
