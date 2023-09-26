import Foundation

protocol MoviesLoaderRequestFactoryProtocol {
    func constructRequest(apiType: ApiType) -> Result<URLRequest,NetworkError>
}

class MoviesLoaderRequestFactoryImpl: MoviesLoaderRequestFactoryProtocol {
    func constructRequest(apiType: ApiType) -> Result<URLRequest, NetworkError> {
        switch apiType {
        case .imdb:
            guard let url = URL(string: "https://imdb-api.com/en/API/Top250Movies/k_zcuw1ytf") else {
                return .failure(NetworkError.keyAPIError)
            }
            return .success(URLRequest(url: url))
            
            
        case .kp:
            var components = URLComponents(string: "https://api.kinopoisk.dev/v1.3/movie")!
            components.queryItems = [
                URLQueryItem(name: "selectFields", value: ["id","name","rating","poster"].joined(separator: " ")),
                URLQueryItem(name: "limit", value: "250"),
                URLQueryItem(name: "typeNumber", value: "1"),
                URLQueryItem(name: "top250", value: "!null")
            ]
            var request = URLRequest(url: components.url!)

            request.addValue("KZG6ADH-8EKME3F-HAA2J1M-G7ZGCJM", forHTTPHeaderField: "X-API-KEY")
            return .success(request)
        }
    }
}
