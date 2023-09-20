//
//  MoviesLoader.swift
//  MovieQuiz
//
//  Created by Глеб Капустин on 01.09.2023.
//

import Foundation

protocol MoviesLoading {
    func loadMovies(handler: @escaping (Result<[Movie], Error>) -> Void)
}
enum ApiType {
     case imdb,kp
}




class MoviesLoader: MoviesLoading {
    // MARK: - NetworkClient
    private let networkClient:NetworkRouting
    private var apiType: ApiType = .imdb
    
    private lazy var requestFactory: MoviesLoaderRequestFactoryProtocol = MoviesLoaderRequestFactoryImpl()
    
    private lazy var responceHandler: MoviesLoaderResponceHandler = MoviesLoaderResponceHandlerImpl()
    init(networkClient: NetworkRouting = NetworkClient()) {
        self.networkClient = networkClient
    }
    
    // MARK: - URL
        private var mostPopularMoviesUrl: URL {
            guard let url = URL(string: "https://imdb-api.com/en/API/Top250Movies/k_zcuw1ytf") else {
                fatalError("")
            }
            return url
            
        }
    func loadMovies(handler: @escaping (Result<[Movie], Error>) -> Void) {
        switch requestFactory.constructRequest(apiType: apiType) {
        case .success(let request):
            networkClient.fetch(request: request) { [unowned self] result in
                switch result {
                case .success(let data):
                    do {
                        let movies = try responceHandler.handleResponce(apiType: self.apiType, data: data)
                        handler(.success(movies))
                    }
                    catch {
                        handler(.failure(error))
                    }
                case .failure(let error):
                    handler(.failure(error))
                }
            }
        case .failure(let error):
            handler(.failure(error))
        }
       
    }
}
