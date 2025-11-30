//
//  UserCellViewModel.swift
//  FakeNFT
//
//  Created by Muhammed Nurmukhanov on 22.11.2025.
//

import Foundation

// MARK: - Structure of users info (Need for tableView in statistics page)
final class UserCellViewData: Equatable {
    let name: String
    let avatarURL: URL?
    let description: String?
    let nfts: [String]
    let rating: String
    let id: String

    init(user: User) {
        self.name = user.name
        self.avatarURL = URL(string: user.avatar)
        self.description = user.description
        self.nfts = user.nfts
        self.rating = user.rating
        self.id = user.id
    }
    
    static func == (lhs: UserCellViewData, rhs: UserCellViewData) -> Bool {
        lhs.name == rhs.name &&
        lhs.description == rhs.description &&
        lhs.rating == rhs.rating &&
        Set(lhs.nfts) == Set(rhs.nfts)
    }
}
