import Foundation

struct FavoriteDto: Dto {
    let likes: String
    
    func asDictionary() -> [String : String] {
        return ["likes": likes]
    }
}
