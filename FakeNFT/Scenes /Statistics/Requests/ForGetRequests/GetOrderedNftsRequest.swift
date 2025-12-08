import Foundation

// MARK: - Request for get ordered nfts list
struct GetOrderedNftsRequest: NetworkRequest {
    
    // MARK: - Endpoint
    var endpoint: URL? {
        var components = URLComponents(string: RequestConstants.baseURL)
        components?.path = "/api/v1/orders/1"
        return components?.url
    }
    
    // MARK: - Http mehod and body
    var httpMethod: HttpMethod { .get }
    var dto: Dto? { nil }
}
