import Foundation

enum NetworkError: String, Error {
    case dataLoadError, imageLoadError = "Data load error"
    case codeError = "Code Error"
    case keyAPIError = "API key Error"
}
