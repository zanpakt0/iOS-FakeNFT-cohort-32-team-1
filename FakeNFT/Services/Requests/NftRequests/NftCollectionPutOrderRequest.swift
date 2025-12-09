import Foundation

struct NftCollectionPutOrderRequest: NetworkRequest {
    var endpoint: URL? {
        URL(string: "\(RequestConstants.baseURL)/api/v1/orders/1")
    }
    var httpMethod: HttpMethod { .put }
    var dto: Dto?
}
