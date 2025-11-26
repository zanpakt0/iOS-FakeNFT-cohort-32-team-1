//
//  UserCardViewData.swift
//  FakeNFT
//
//  Created by Muhammed Nurmukhanov on 26.11.2025.
//

import Foundation

final class UserCardViewData {
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
