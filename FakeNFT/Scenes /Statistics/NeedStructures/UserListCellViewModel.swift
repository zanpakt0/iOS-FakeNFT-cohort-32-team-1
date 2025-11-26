//
//  UserCellViewModel.swift
//  FakeNFT
//
//  Created by Muhammed Nurmukhanov on 22.11.2025.
//

import Foundation

// MARK: - Structure of user's info (Need for tableView in statistics page)
final class UsersListCellViewModel: Equatable {
    let name: String
    let avatarURL: URL?
    let description: String?
    let nfts: [String]
    let rating: String
    let id: String

    init(user: User) {
        self.name = user.name
        self.avatarURL = user.avatar.flatMap { URL(string: $0) }
        self.description = user.description
        self.nfts = user.nfts
        self.rating = user.rating
        self.id = user.id
    }
    
    static func == (lhs: UsersListCellViewModel, rhs: UsersListCellViewModel) -> Bool {
        lhs.name == rhs.name &&
        lhs.description == rhs.description &&
        lhs.rating == rhs.rating &&
        Set(lhs.nfts) == Set(rhs.nfts)
    }
}
