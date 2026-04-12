import Foundation

// MARK: - Structure of nft's info (Need for user's Nft collection page)
struct NftData {
    let image: URL?
    let rating: Int
    let name: String
    let price: Decimal
    let id: String
    let author: String
    
    init(nftData: NFT) {
        self.image = URL(string: nftData.images[0])
        self.rating = nftData.rating
        self.name = nftData.name
        self.price = nftData.price
        self.id = nftData.id
        self.author = nftData.author
    }
}

struct NftCellViewData {
    let nft: NftData
    let isFavourite: Bool
    let isInCart: Bool
    
    init(nft: NftData, isFavourite: Bool, isInCart: Bool) {
        self.nft = nft
        self.isFavourite = isFavourite
        self.isInCart = isInCart
    }
}
