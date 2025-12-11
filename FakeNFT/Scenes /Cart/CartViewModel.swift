import UIKit
import Combine

final class CartViewModel {
    
    // MARK: - Output bindings
    var onItemsUpdated: (() -> Void)?
    var onTotalUpdated: ((String, String) -> Void)?
    var onLoadError: ((Error) -> Void)?
    
    // MARK: - Data
    private(set) var items: [NFTUIItem] = []
    
    private let nftService: NFTService
    private let cartService: CartService
    
    init(nftService: NFTService, cartService: CartService) {
        self.nftService = nftService
        self.cartService = cartService
    }
    
    // MARK: - Load Cart
    func loadCart() {

        cartService.fetchCart { [weak self] result in
            guard let self else { return }

            switch result {
            case .success(let order):
                let ids = order.nfts
                self.nftService.fetchNFTs(with: ids) { result in
                    switch result {
                    case .success(let nfts):
                        self.items = nfts.map { nft in
                            NFTUIItem(
                                id: nft.id,
                                image: nil,
                                imageUrl: nft.imageUrl,
                                title: nft.name,
                                rating: nft.rating ?? 0,
                                price: nft.price
                            )
                        }
                        self.notifyUpdates()
                    case .failure(let error):
                        self.onLoadError?(error)
                    }
                }

            case .failure(let error):
                self.onLoadError?(error)
            }
        }
    }
    
    // MARK: - CRUD
    func removeItem(at index: Int) {
        guard items.indices.contains(index) else { return }
        items.remove(at: index)
        notifyUpdates()
    }
    
    func removeAllItems() {
        items.removeAll()
        notifyUpdates()
    }
    
    func updateRating(at index: Int, rating: Int) {
        guard items.indices.contains(index) else { return }
        items[index].rating = rating
        notifyUpdates()
    }
    
    // MARK: - Sorting
    func sortByPrice() {
        items.sort { $0.price < $1.price }
        notifyUpdates()
    }
    
    func sortByRating() {
        items.sort { $0.rating > $1.rating }
        notifyUpdates()
    }
    
    func sortByTitle() {
        items.sort { $0.title < $1.title }
        notifyUpdates()
    }
    
    // MARK: - Helpers
    func numberOfItems() -> Int { items.count }
    func item(at index: Int) -> NFTUIItem { items[index] }
    
    private func notifyUpdates() {
        onItemsUpdated?()
        updateTotal()
    }
    
    func updateTotal() {
        let countText = "\(items.count) NFT"
        let sum = items.reduce(0) { $0 + $1.price }
        let totalText = String(format: "%.2f ETH", sum).replacingOccurrences(of: ".", with: ",")
        onTotalUpdated?(countText, totalText)
    }
}

