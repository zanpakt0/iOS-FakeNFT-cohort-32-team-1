import Foundation

// MARK: - Request for change list of ordered nfts
struct PutOrderedNftsRequest: NetworkRequest {
    
    // MARK: - Endpoint
    var endpoint: URL? {
        var components = URLComponents(string: RequestConstants.baseURL)
        components?.path = "/api/v1/orders/1"
        return components?.url
    }
    
    // MARK: - Http mehod and body
    var httpMethod: HttpMethod { .put }
    var dto: Dto?
    
    init(nfts: String) {
        self.dto = PutOrderedDto(nfts: nfts)
    }
}

struct PutOrderedDto: Dto {
    let nfts: String

    func asDictionary() -> [String: String] {
        ["nfts": nfts]
    }
}
