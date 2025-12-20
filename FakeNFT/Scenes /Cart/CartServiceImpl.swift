import Foundation

struct OrderFetchRequest: NetworkRequest {
    let endpoint: URL?
    let httpMethod: HttpMethod = .get
    let dto: Dto? = nil
    
    init(orderId: String) {
        self.endpoint = URL(string: "\(RequestConstants.baseURL)/api/v1/orders/1")
    }
}

struct OrderUpdateDTO: Dto {
    let nfts: [String]
    
    func asDictionary() -> [String: String] {
        ["nfts": nfts.joined(separator: ",")]
    }
}

struct OrderUpdateRequest: NetworkRequest {
    let endpoint: URL?
    let httpMethod: HttpMethod = .put
    let dto: Dto?
    
    init(orderId: String, nfts: [String]) {
        self.endpoint = URL(string: "\(RequestConstants.baseURL)/api/v1/orders/1")
        self.dto = OrderUpdateDTO(nfts: nfts)
    }
}

struct OrderResponse: Decodable {
    let id: String
    let nfts: [String]
    let currency: Int?
    let total: Double?
}

protocol CartService {
    func fetchCart(completion: @escaping (Result<OrderResponse, Error>) -> Void)
    func updateCart(nftIds: [String], completion: @escaping (Result<OrderResponse, Error>) -> Void)
    func deleteNFT(
        id: String,
        completion: @escaping (Result<Void, Error>) -> Void
    )
}

final class CartServiceImpl: CartService {
    
    private let client: NetworkClient
    private let orderId = "1"
    
    init(client: NetworkClient) {
        self.client = client
    }
    
    func fetchCart(completion: @escaping (Result<OrderResponse, Error>) -> Void) {
        
        let request = OrderFetchRequest(orderId: orderId)
        
        client.send(request: request, completionQueue: .main) { result in
            switch result {
            case .success(let data):
                do {
                    let decoded = try JSONDecoder().decode(OrderResponse.self, from: data)
                    completion(.success(decoded))
                } catch {
                    completion(.failure(error))
                }
                
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func deleteNFT(
        id: String,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        
        fetchCart { [weak self] result in
            guard let self else { return }
            
            switch result {
            case .success(let order):
                
                let updatedIds = order.nfts.filter { $0 != id }
                
                let request = OrderUpdateRequest(orderId: self.orderId, nfts: updatedIds)
                
                self.client.send(request: request, completionQueue: .main) { result in
                    switch result {
                    case .success:
                        completion(.success(()))
                    case .failure(let error):
                        completion(.failure(error))
                    }
                }
                
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func updateCart(nftIds: [String], completion: @escaping (Result<OrderResponse, Error>) -> Void) {
        
        let request = OrderUpdateRequest(orderId: orderId, nfts: nftIds)
        
        client.send(request: request, completionQueue: .main) { result in
            switch result {
            case .success(let data):
                do {
                    let decoded = try JSONDecoder().decode(OrderResponse.self, from: data)
                    completion(.success(decoded))
                } catch {
                    completion(.failure(error))
                }
                
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
