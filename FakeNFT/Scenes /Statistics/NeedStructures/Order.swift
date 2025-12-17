// MARK: - Structure for decoding list of nfts in shopping cart
struct Order: Decodable {
    let nfts: [String]
    let id: String
}
