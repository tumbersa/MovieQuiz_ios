//
//  NetworkError.swift
//  MovieQuiz
//
//  Created by Глеб Капустин on 05.09.2023.
//

import Foundation

enum NetworkError: String, Error {
    case dataLoadError, imageLoadError = "Data load error"
    case codeError = "Code Error"
    case keyAPIError = "API key Error"
}
