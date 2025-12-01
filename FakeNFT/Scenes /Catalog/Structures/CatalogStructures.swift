import UIKit

struct NFT: Codable {
    let name: String
    let images: [URL]
    let rating: Int
    let description: String
    let price: Double
    let author: URL
    let id: String
}

struct Collection: Codable {
    let name: String
    let cover: URL
    let nfts: [String]
    let description: String
    let author: String
    let id: String
}
