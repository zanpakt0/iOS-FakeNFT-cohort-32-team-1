import Foundation

struct FavoriteDto: Dto {
    let FavoriteId: String

    func asDictionary() -> [String : String] {
        return ["likes": FavoriteId]
    }
}
