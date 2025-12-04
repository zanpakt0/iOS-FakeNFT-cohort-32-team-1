import Foundation
import Combine

final class NFTCollectionViewModel {
    //MARK: - Published Variables
    @Published var nfts: [Nft] = []
    @Published var isLoading = false
    
    @Published private(set) var favorites: [String] = []
    @Published private(set) var itemsInCart: [String] = []
    
    //MARK: - Constants
    private let provider: NftService
    
    //MARK: - Init
    init(provider: NftServiceImpl, nftIds: [String]) {
        self.provider = provider
        self.isLoading = true
        self.loadData(nftIds: nftIds)
    }
    
    //MARK: - Methods
    func loadData(nftIds: [String]) {
        for id in nftIds {
            provider.loadNft(id: id) { [weak self] result in
                guard let self else { return }
                
                switch result {
                case .success(let nft):
                    self.nfts.append(nft)
                case .failure(let error):
                    print("Load failed", error)
                }
            }
        }
        self.isLoading = false
    }
    
    func addInCart(id: String) {
        DispatchQueue.main.async {
            if !self.itemsInCart.contains(id) {
                self.itemsInCart.append(id)
            }
        }
    }
    
    func deleteFromCart(id: String) {
        DispatchQueue.main.async {
            if let index = self.itemsInCart.firstIndex(of: id) {
                self.itemsInCart.remove(at: index)
            }
        }
    }
    
    func addLike(id: String) {
        DispatchQueue.main.async {
            if !self.favorites.contains(id){
                self.favorites.append(id)
            }
        }
    }
    
    func deleteLike(id: String) {
        DispatchQueue.main.async {
            if let index = self.favorites.firstIndex(of: id) {
                self.favorites.remove(at: index)
            }
        }
    }
}
