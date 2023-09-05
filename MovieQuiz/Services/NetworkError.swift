//
//  NetworkError.swift
//  MovieQuiz
//
//  Created by Глеб Капустин on 05.09.2023.
//

import Foundation

enum NetworkError: String, Error {
    case dataLoadError 
    case imageLoadError
    case codeError
    case keyAPIError
}
