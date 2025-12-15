import Foundation

typealias CatalogCompletion = (Result<[Catalog], Error>) -> Void

protocol CatalogProviderProtocol {
    func loadCatalog(completion: @escaping CatalogCompletion)
}

final class CatalogProvider: CatalogProviderProtocol {
    //MARK: - Constants
    private let networkClient: NetworkClient
    private let storage: CatalogStorage
    
    //MARK: - Init
    init(networkClient: NetworkClient, storage: CatalogStorage) {
        self.storage = storage
        self.networkClient = networkClient
    }
    
    //MARK: - Methods
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


