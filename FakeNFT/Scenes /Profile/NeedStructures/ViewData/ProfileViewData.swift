import Foundation

// MARK: - Structure of user's info (Need for user card page)
struct ProfileViewData {
    let avatarURL: URL?
    let name: String
    let description: String?
    let websiteURL: URL?
    let nfts: [String]
    let likes: [String]
    let id: String
    
    init(profile: Profile) {
        self.avatarURL = URL(string: profile.avatar)
        self.name = profile.name
        self.description = profile.description
        self.websiteURL = URL(string: profile.website)
        self.nfts = profile.nfts
        self.likes = profile.likes
        self.id = profile.id
    }
}
