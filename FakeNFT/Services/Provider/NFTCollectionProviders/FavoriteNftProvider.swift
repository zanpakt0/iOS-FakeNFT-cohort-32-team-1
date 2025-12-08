import Foundation

typealias FavoriteNftCompletion = (Result<[String], Error>) -> Void

protocol FavoriteNftProvider {
    func loadFavorites(completion: @escaping FavoriteNftCompletion)
    func putFavorite(id: String, completion: @escaping FavoriteNftCompletion)
}

final class FavoriteNftProviderImpl: FavoriteNftProvider {
    private let networkClient: NetworkClient
    private let storage: FavoriteNftStorage
    
    init(networkClient: NetworkClient, storage: FavoriteNftStorage) {
        self.storage = storage
        self.networkClient = networkClient
    }
    
    func loadFavorites(completion: @escaping FavoriteNftCompletion) {
        let request = NftCollectionGetFavoritesRequest()
        
        networkClient.send(request: request, type: Favorites.self) { [weak storage] result in
            switch result {
            case .success(let favoritesList):
                storage?.saveFavoriteNft(favoritesList.likes)
                completion(.success(favoritesList.likes))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func putFavorite(id: String, completion: @escaping FavoriteNftCompletion) {
        var current = storage.getFavoriteNft() ?? []
        if current.contains(id) {
            current.removeAll { $0 == id }
        } else {
            current.append(id)
        }
        
        let likeValue = current.joined(separator: ",")
        
        let dto = FavoriteDto(likes: likeValue)
        let request = NftCollectionPutFavoritesRequest(dto: dto)
        
        networkClient.send(request: request, type: Favorites.self) { [weak storage] result in
            switch result {
            case .success(let favoritesList):
                storage?.saveFavoriteNft(favoritesList.likes)
                completion(.success(favoritesList.likes))
            case . failure(let error):
                completion(.failure(error))
            }
        }
    }
}
