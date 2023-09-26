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
