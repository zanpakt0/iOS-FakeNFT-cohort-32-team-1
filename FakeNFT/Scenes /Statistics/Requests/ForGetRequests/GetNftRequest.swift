import Foundation

// MARK: - Request for get nft by id
struct GetNftRequest: NetworkRequest {
    
    // MARK: - Endpoint
    var endpoint: URL? {
        var components = URLComponents(string: RequestConstants.baseURL)
        components?.path = "/api/v1/nft/\(id)"
        return components?.url
    }
    
    // MARK: - Http mehod and body
    var httpMethod: HttpMethod { .get }
    var dto: Dto? { nil }
    
    // MARK: - Nft data
    let id: String
}

