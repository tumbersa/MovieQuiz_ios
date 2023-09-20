//
//  NetworkClient.swift
//  MovieQuiz
//
//  Created by Глеб Капустин on 01.09.2023.
//

import Foundation

protocol NetworkRouting {
    func fetch(request: URLRequest, handler: @escaping (Result<Data, Error>) -> Void)
}
/// Отвечает за загрузку данных по URL
struct NetworkClient: NetworkRouting {

    func fetch(request: URLRequest, handler: @escaping (Result<Data, Error>) -> Void) {
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            // Проверяем, пришла ли ошибка
            if error != nil {
                handler(.failure(NetworkError.dataLoadError))
                return
            }
            
            // Проверяем, что нам пришёл успешный код ответа
            if let response = response as? HTTPURLResponse,
                response.statusCode < 200 || response.statusCode >= 300 {
                handler(.failure(NetworkError.codeError))
                return
            }
            // Возвращаем данные
            guard let data else {
                handler(.failure(NetworkError.dataLoadError))
                return
            }
            handler(.success(data))
        }
        
        task.resume()
    }
}
