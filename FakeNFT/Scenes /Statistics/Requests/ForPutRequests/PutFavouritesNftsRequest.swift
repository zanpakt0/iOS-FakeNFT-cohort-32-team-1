import Foundation

// MARK: - Request for change list of favourite nfts
struct PutFavouritesNftsRequest: NetworkRequest {
    
    // MARK: - Endpoint
    var endpoint: URL? {
        var components = URLComponents(string: RequestConstants.baseURL)
        components?.path = "/api/v1/profile/1"
        return components?.url
    }
    
    // MARK: - Http mehod and body
    var httpMethod: HttpMethod { .put }
    var dto: Dto?
    
    init(likes: String) {
        self.dto = PutFavouritesDto(likes: likes)
    }
}

struct PutFavouritesDto: Dto {
    let likes: String

    func asDictionary() -> [String: String] {
        ["likes": likes]
    }
}
