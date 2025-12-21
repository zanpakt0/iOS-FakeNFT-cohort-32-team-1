import Foundation

struct OrderDto: Dto {
    let order: String
    
    func asDictionary() -> [String : String] {
        return ["nfts": order]
    }
}
