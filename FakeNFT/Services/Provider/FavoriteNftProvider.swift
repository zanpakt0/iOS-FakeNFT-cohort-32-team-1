import Foundation

typealias FavoriteNftCompletion = (Result<[String], Error>) -> Void

protocol FavoriteNftProviderProtocol {
    func loadFavorites(completion: @escaping FavoriteNftCompletion)
    func putFavorite(id: String, completion: @escaping FavoriteNftCompletion)
}

final class FavoriteNftProvider: FavoriteNftProviderProtocol {
    private let networkClient: NetworkClient
    private let storage: FavoriteNftStorage
    
    init(networkClient: NetworkClient, storage: FavoriteNftStorage) {
        self.storage = storage
        self.networkClient = networkClient
    }
    
    func loadFavorites(completion: @escaping FavoriteNftCompletion) {
        let request = NftCollectionGetFavoritesRequest()
        
        networkClient.send(request: request, type: [String].self) { [weak storage] result in
            switch result {
            case .success(let favoritesList):
                storage?.saveFavoriteNft(favoritesList)
                completion(.success(favoritesList))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func putFavorite(id: String, completion: @escaping FavoriteNftCompletion) {
        let dto = FavoriteDto(FavoriteId: id)
        let request = NftCollectionPutFavoritesRequest(dto: dto)
        
        networkClient.send(request: request, type: [String].self) { [weak storage] result in
            switch result {
            case .success(let favoritesList):
                storage?.saveFavoriteNft(favoritesList)
                completion(.success(favoritesList))
            case . failure(let error):
                completion(.failure(error))
            }
        }
    }
}
