import Foundation

struct NFTCatalogRequest: NetworkRequest {
    var endpoint: URL? {
        URL(string: "\(RequestConstants.baseURL)/api/v1/collections")
    }
    var httpMethod: HttpMethod { .get }
    var dto: Dto? { nil }
}
