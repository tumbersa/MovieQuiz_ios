//
//  MoviesLoaderResponceHandler.swift
//  MovieQuiz
//
//  Created by Глеб Капустин on 20.09.2023.
//

import Foundation

protocol MoviesLoaderResponceHandler{
    func handleResponce(apiType: ApiType, data: Data) throws -> [Movie]
}

class MoviesLoaderResponceHandlerImpl: MoviesLoaderResponceHandler {
    func handleResponce(apiType: ApiType, data: Data) throws -> [Movie] {
        switch apiType {
        case .imdb:
            return try JSONDecoder().decode(MostPopularMovies.self, from: data).items
        case .kp:
            return try JSONDecoder().decode(KPMovieResponce.self, from: data).docs
        }
    }
    
    
}