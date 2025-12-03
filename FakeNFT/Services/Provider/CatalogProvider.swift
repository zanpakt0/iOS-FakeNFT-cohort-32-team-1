import UIKit

typealias CatalogCompletion = (Result<[Catalog], Error>) -> Void

protocol CatalogProviderProtocol {
    func loadCatalog(completion: @escaping CatalogCompletion)
}

final class CatalogProvider: CatalogProviderProtocol {
    
    private let networkClient: NetworkClient
    private let storage: CatalogStorage
    
    init(networkClient: NetworkClient, storage: CatalogStorage) {
        self.storage = storage
        self.networkClient = networkClient
    }
    
    func loadCatalog(completion: @escaping CatalogCompletion) {
        let request = NFTCatalogRequest()
        
        networkClient.send(request: request, type: [Catalog].self) { [weak storage] result in
            switch result {
            case .success(let catalogList):
                storage?.saveCatalog(catalogList)
                completion(.success(catalogList))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}


