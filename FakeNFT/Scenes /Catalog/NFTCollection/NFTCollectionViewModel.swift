import Foundation
import Combine

final class NFTCollectionViewModel {
    //MARK: - Published Variables
    @Published var nfts: [Nft] = []
    @Published var isLoading = false
    @Published var loadError: Error?
    
    @Published private(set) var favorites: [String] = []
    @Published private(set) var itemsInCart: [String] = []
    
    //MARK: - Constants
    private let provider: NftService
    private let nftIds: [String]
    private let favoriteProvider : FavoriteNftProvider
    private let orderProvider: OrderNftProvider
    
    //MARK: - Init
    init(provider: NftServiceImpl, favoriteProvider: FavoriteNftProvider, orderProvider: OrderNftProvider, nftIds: [String]) {
        self.favoriteProvider = favoriteProvider
        self.orderProvider = orderProvider
        self.provider = provider
        self.isLoading = true
        self.nftIds = nftIds
        self.loadData()
        self.fetchFavorites()
        self.fetchOrders()
    }
    
    //MARK: - Methods
    func loadData() {
        self.isLoading = true
        self.loadError = nil
        
        let group = Constants.dispatchGroup
        var loadedNfts: [Nft] = []
        
        for id in nftIds {
            group.enter()
            provider.loadNft(id: id) { result in
                switch result {
                case .success(let nft):
                    loadedNfts.append(nft)
                case .failure(let error):
                    print("Load failed", error)
                    self.loadError = error
                }
                group.leave()
            }
        }
        group.notify(queue: .main) { [weak self] in
            guard let self else { return }
            self.nfts = loadedNfts
            self.nfts.sort(by: { $0.id < $1.id })
            self.isLoading = false
        }
    }
    
    func addInCart(id: String) {
        DispatchQueue.main.async {
            if !self.itemsInCart.contains(id) {
                self.itemsInCart.append(id)
                
                self.putOrder(id: id) { success in
                    if !success {
                        if let index = self.itemsInCart.firstIndex(of: id) {
                            self.itemsInCart.remove(at: index)
                            print(self.itemsInCart)
                        }
                    }
                }
            }
        }
    }
    
    func deleteFromCart(id: String) {
        DispatchQueue.main.async {
            if let index = self.itemsInCart.firstIndex(of: id) {
                self.itemsInCart.remove(at: index)
                
                self.putOrder(id: id) { success in
                    if !success {
                        if !self.itemsInCart.contains(id) {
                            self.itemsInCart.append(id)
                        }
                    }
                }
            }
        }
    }
    
    func addLike(id: String) {
        DispatchQueue.main.async {
            if !self.favorites.contains(id){
                self.favorites.append(id)
                
                self.putFavorites(id: id) { success in
                    if !success {
                        if let index = self.favorites.firstIndex(of: id) {
                            self.favorites.remove(at: index)
                        }
                    }
                }
            }
        }
    }
    
    func deleteLike(id: String) {
        DispatchQueue.main.async {
            if let index = self.favorites.firstIndex(of: id) {
                self.favorites.remove(at: index)
                
                self.putFavorites(id: id) { success in
                    if !success {
                        if !self.favorites.contains(id) {
                            self.favorites.append(id)
                        }
                    }
                }
            }
        }
    }
    
    //MARK: - Private Methods
    private func putFavorites(id: String, completion: @escaping (Bool) -> Void) {
        self.favoriteProvider.putFavorite(id: id) { [weak self] result in
            DispatchQueue.main.async {
                guard let self else { return }
                
                switch result {
                case .success(let likes):
                    self.favorites = likes
                    completion(true)
                case .failure(let error):
                    print("Load failed", error)
                    completion(false)
                }
            }
        }
    }
    
    private func fetchFavorites() {
        self.favoriteProvider.loadFavorites { [weak self] result in
            guard let self else { return }
            
            switch result {
            case .success(let favoriteList):
                self.favorites = favoriteList
            case .failure(let error):
                print("Load failed", error)
            }
        }
    }
    
    private func putOrder(id: String, completion: @escaping (Bool) -> Void) {
        self.orderProvider.putOrder(id: id) { [weak self] result in
            DispatchQueue.main.async {
                guard let self else { return }
                
                switch result {
                case .success(let orders):
                    self.itemsInCart = orders
                    completion(true)
                case .failure(let error):
                    print("Load failed", error)
                    completion(false)
                }
            }
        }
    }
    
    private func fetchOrders() {
        self.orderProvider.loadOrders { [weak self] result in
            guard let self else { return }
            
            switch result {
            case .success(let orders):
                self.itemsInCart = orders
            case .failure(let error):
                print("Load failed", error)
            }
        }
    }
    
}
