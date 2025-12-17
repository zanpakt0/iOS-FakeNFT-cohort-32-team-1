import Foundation

// MARK: - Structure of ordered nfts
struct ListOfOrderedNftsData {
    let nfts: [String]
    let id: String
    
    init(order: Order) {
        self.nfts = order.nfts
        self.id = order.id
    }
}
