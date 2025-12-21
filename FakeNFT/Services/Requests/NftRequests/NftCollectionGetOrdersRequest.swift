import Foundation

struct NftCollectionGetOrdersRequest: NetworkRequest {
    var endpoint: URL? {
        URL(string: "\(RequestConstants.baseURL)/api/v1/orders/1")
    }
    var httpMethod: HttpMethod { .get }
    var dto: Dto? { nil }
}
