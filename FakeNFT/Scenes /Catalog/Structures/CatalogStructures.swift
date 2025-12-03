import UIKit

//struct Nft: Codable {
//    let name: String
//    let images: [URL]
//    let rating: Int
//    let description: String
//    let price: Double
//    let author: URL
//    let id: String
//}

struct Catalog: Codable {
    let name: String
    let cover: URL
    let nfts: [String]
    let description: String
    let author: String
    let id: String
}

