import Foundation

struct Currency: Decodable {
    let title: String
    let name: String
    let image: String
    let id: String
}

struct CreateOrderResponse: Decodable {
    let nfts: [String]
    let id: String
}

struct PayResponse: Decodable {
    let success: Bool
    let orderId: String
    let id: String
}

struct EmptyResponse: Decodable {}

struct EmptyDto: Dto {
    func asDictionary() -> [String: String] { [:] }
}

struct PaymentMethod {
    let id: String
    let title: String
    let name: String
    let image: String
}

struct GetOrdersRequest: NetworkRequest {
    var httpMethod: HttpMethod { .get }
    var dto: Dto? { EmptyDto() }
    
    var endpoint: URL? {
        URL(string: "\(RequestConstants.baseURL)/api/v1/orders/1")
    }
}

struct PutOrdersRequest: NetworkRequest {
    var httpMethod: HttpMethod { .put }
    var dto: Dto? { ChangeOrderDto(nfts: orders) }
    
    var orders: [String]
    
    var endpoint: URL? {
        URL(string: "\(RequestConstants.baseURL)/api/v1/orders/1")
    }
}

struct OrderRequest: NetworkRequest {
    var httpMethod: HttpMethod { .get }
    var dto: Dto? { EmptyDto() }
    
    var endpoint: URL? {
        URL(string: "\(RequestConstants.baseURL)/api/v1/orders/1")
    }
    
    var nfts: [String]?
}

struct CurrenciesRequest: NetworkRequest {
    var httpMethod: HttpMethod { .get }
    var dto: Dto? { EmptyDto() }
    
    var endpoint: URL? {
        URL(string: "\(RequestConstants.baseURL)/api/v1/currencies")
    }
}

struct PayRequest: NetworkRequest {
    var httpMethod: HttpMethod { .get }
    var dto: Dto? { EmptyDto() }
    
    let currencyId: String
    
    var endpoint: URL? {
        URL(string: "\(RequestConstants.baseURL)/api/v1/orders/1/payment/\(currencyId)")
    }
    
    var nfts: [String]?
}

struct ChangeOrderRequest: NetworkRequest {
    var httpMethod: HttpMethod { .put }
    var dto: Dto? { ChangeOrderDto(nfts: nfts ?? []) }
    
    var nfts: [String]?
    
    var endpoint: URL? {
        URL(string: "\(RequestConstants.baseURL)/api/v1/orders/1")
    }
    
    init(nfts: [String]) {
        self.nfts = nfts
    }
}

struct EmptyOrderRequest: NetworkRequest {
    var httpMethod: HttpMethod { .put }
    var dto: Dto? { ChangeOrderDto(nfts: nfts ?? []) }
    
    var nfts: [String]?
    
    var endpoint: URL? {
        URL(string: "\(RequestConstants.baseURL)/api/v1/orders/1")
    }
    
    init(nfts: [String]) {
        self.nfts = nfts
    }
}

struct ChangeOrderDto: Dto {
    let nfts: [String]
    
    func asDictionary() -> [String : String] {
        ["nfts": nfts.joined(separator: ",")]
    }
}
