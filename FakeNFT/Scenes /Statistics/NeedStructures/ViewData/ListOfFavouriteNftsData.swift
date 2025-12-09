import Foundation

// MARK: - Structure of favourite nfts
struct ListOfFavouriteNftsData {
    let likes: [String]
    
    init(profile: Profile) {
        self.likes = profile.likes
    }
}

