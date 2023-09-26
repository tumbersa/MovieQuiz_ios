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
        guard let imageUrl = URL(string: poster.previewUrl) else {
            fatalError("imageUrl")
        }
        return imageUrl
    }
    
    var resizedImageURL: URL {
        guard let imageUrl = URL(string: poster.previewUrl) else {
            fatalError("resizedUrl")
        }
        return imageUrl
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

