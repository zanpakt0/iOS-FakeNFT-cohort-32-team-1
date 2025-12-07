import Foundation

// MARK: - Structure of nft's info (Need for user's Nft collection page)
struct NftData {
    let image: URL?
    let rating: Int
    let name: String
    let price: Decimal
    let id: String
    
    init(nftData: NFT) {
        self.image = URL(string: nftData.images[0])
        self.rating = nftData.rating
        self.name = nftData.name
        self.price = nftData.price
        self.id = nftData.id
    }
}

struct NftCellViewData {
    let nft: NftData
    let isFavourite: Bool
    let isInChart: Bool
    
    init(nft: NftData, isFavourite: Bool, isInChart: Bool) {
        self.nft = nft
        self.isFavourite = isFavourite
        self.isInChart = isInChart
    }
}
