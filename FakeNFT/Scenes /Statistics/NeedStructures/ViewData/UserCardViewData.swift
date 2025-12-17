import Foundation

// MARK: - Structure of user's info (Need for user card page)
struct UserCardViewData {
    let name: String
    let avatarURL: URL?
    let decription: String?
    let website: URL?
    let nfts: [String]
    
    init(user: User) {
        self.name = user.name
        self.avatarURL = URL(string: user.avatar)
        self.decription = user.description
        self.website = URL(string: user.website)
        self.nfts = user.nfts
    }
}
