import Foundation

typealias NftCompletion = (Result<Nft, Error>) -> Void

protocol NftService {
    func loadNft(id: String, completion: @escaping NftCompletion)
    
    func getUsers(page: Int, size: Int, completion: @escaping (Result<[User], Error>) -> Void) -> NetworkTask?
    func getUserCard(id: String, completion: @escaping (Result<User, Error>) -> Void) -> NetworkTask?
    func getNft(id: String, completion: @escaping (Result<NFT, Error>) -> Void) -> NetworkTask?
    func getFavouritesNft(completion: @escaping (Result<Profile, Error>) -> Void) -> NetworkTask?
    func getOrderedNft(completion: @escaping (Result<Order, Error>) -> Void) -> NetworkTask?
    func getProfile(completion: @escaping (Result<Profile, Error>) -> Void) -> NetworkTask?
    
    func putToFavoritesNft(likes: String, completion: @escaping (Result<Profile, Error>) -> Void) -> NetworkTask?
    func putToOrderedNft(nfts: String, completion: @escaping (Result<Order, Error>) -> Void) -> NetworkTask?
}

final class NftServiceImpl: NftService {
    
    private let networkClient: NetworkClient
    private let storage: NftStorage

    init(networkClient: NetworkClient, storage: NftStorage) {
        self.storage = storage
        self.networkClient = networkClient
    }

    func loadNft(id: String, completion: @escaping NftCompletion) {
        if let nft = storage.getNft(with: id) {
            completion(.success(nft))
            return
        }

        let request = NFTRequest(id: id)
        networkClient.send(request: request, type: Nft.self) { [weak storage] result in
            switch result {
            case .success(let nft):
                storage?.saveNft(nft)
                completion(.success(nft))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    @discardableResult
    func getUsers(page: Int, size: Int, completion: @escaping (Result<[User], any Error>) -> Void) -> NetworkTask? {
        let request = GetUsersRequest(page: page, size: size)
        return networkClient.send(request: request, type: [User].self) { result in
            completion(result)
        }
    }
    
    @discardableResult
    func getUserCard(id: String, completion: @escaping (Result<User, any Error>) -> Void) -> NetworkTask? {
        let request = GetUserCardRequest(id: id)
        return networkClient.send(request: request, type: User.self) { result in
            completion(result)
        }
    }
    
    @discardableResult
    func getNft(id: String, completion: @escaping (Result<NFT, any Error>) -> Void) -> (any NetworkTask)? {
        let request = GetNftRequest(id: id)
        return networkClient.send(request: request, type: NFT.self) { result in
            completion(result)
        }
    }
    
    @discardableResult
    func getFavouritesNft(completion: @escaping (Result<Profile, any Error>) -> Void) -> (any NetworkTask)? {
        let request = GetFavouritesNftsRequest()
        return networkClient.send(request: request, type: Profile.self) { result in
            completion(result)
        }
    }
    
    @discardableResult
    func getOrderedNft(completion: @escaping (Result<Order, any Error>) -> Void) -> (any NetworkTask)? {
        let request = GetOrderedNftsRequest()
        return networkClient.send(request: request, type: Order.self) { result in
            completion(result)
        }
    }
    
    @discardableResult
    func getProfile(completion: @escaping (Result<Profile, any Error>) -> Void) -> (any NetworkTask)? {
        let request = GetProfileRequest()
        return networkClient.send(request: request, type: Profile.self) { result in
            completion(result)
        }
    }
    
    @discardableResult
    func putToFavoritesNft(likes: String, completion: @escaping (Result<Profile, any Error>) -> Void) -> (any NetworkTask)? {
        let request = PutFavouritesNftsRequest(likes: likes)
        return networkClient.send(request: request, type: Profile.self) { result in
            completion(result)
        }
    }
    
    @discardableResult
    func putToOrderedNft(nfts: String, completion: @escaping (Result<Order, any Error>) -> Void) -> (any NetworkTask)? {
        let request = PutOrderedNftsRequest(nfts: nfts)
        return networkClient.send(request: request, type: Order.self) { result in
            completion(result)
        }
    }
}
