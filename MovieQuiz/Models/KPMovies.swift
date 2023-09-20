//
//  KPMovies.swift
//  MovieQuiz
//
//  Created by Глеб Капустин on 18.09.2023.
//

import Foundation

struct KPMovieResponce: Codable {
    let docs: [KPMovie]
}
// MARK: - KPMovie

struct KPMovie: Codable, Movie {
    let ratings: Rating
    var title: String
    let poster: Poster
    
    enum CodingKeys: String, CodingKey{
        case title = "name"
        case ratings = "rating"
        case poster = "poster"
    }
    
    var rating: String {
        "\(ratings.imdb)"
    }
    
    var imageURL: URL {
        URL(string: poster.previewUrl)!
    }
    
    var resizedImageURL: URL {
        URL(string: poster.previewUrl)!
    }
    
   
}

// MARK: - Poster
struct Poster: Codable {
    let url, previewUrl: String

}

// MARK: - Rating
struct Rating: Codable {
    let kp, imdb: Double
    
}

