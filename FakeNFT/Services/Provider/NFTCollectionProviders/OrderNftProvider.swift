import Foundation

typealias OrderNftCompletion = (Result <[String], Error>) -> Void

protocol OrderNftProvider {
    func loadOrders(completion: @escaping OrderNftCompletion)
    func putOrder(id: String, completion: @escaping OrderNftCompletion)
}

final class OrderNftProviderImpl: OrderNftProvider {
    //MARK: - Constants
    private let networkClient: NetworkClient
    private let storage: OrdersNftStorage
    
    //MARK: - Init
    init(networkClient: NetworkClient, storage: OrdersNftStorage) {
        self.networkClient = networkClient
        self.storage = storage
    }
    
    //MARK: - Methods
    func loadOrders(completion: @escaping OrderNftCompletion) {
        let request = NftCollectionGetOrdersRequest()
        
        networkClient.send(request: request, type: Orders.self) { [weak storage] result in
            switch result {
            case .success(let orderList):
                storage?.saveNftOrder(orderList.nfts)
                completion(.success(orderList.nfts))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func putOrder(id: String, completion: @escaping OrderNftCompletion) {
        var current = storage.getNftOrder() ?? []
        if current.contains(id) {
            current.removeAll { $0 == id }
        } else {
            current.append(id)
        }
        
        let orderValue = current.joined(separator: ",")
        
        let dto = OrderDto(order: orderValue)
        let request = NftCollectionPutOrderRequest(dto: dto)
        
        networkClient.send(request: request, type: Orders.self) { [weak storage] result in
            switch result {
            case .success(let orderList):
                storage?.saveNftOrder(orderList.nfts)
                completion(.success(orderList.nfts))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
}
