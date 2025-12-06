import UIKit

struct NFTItem {
    let id: UUID = UUID()
    let image: UIImage?
    let title: String
    var rating: Int
    let price: Double
}

struct CryptoPayment {
    let iconName: String
    let title: String
    let ticker: String
}
