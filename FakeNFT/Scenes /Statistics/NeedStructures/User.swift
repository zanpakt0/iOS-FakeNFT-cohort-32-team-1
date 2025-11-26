//
//  User.swift
//  FakeNFT
//
//  Created by Muhammed Nurmukhanov on 22.11.2025.
//

// MARK: - Structure for decoding user requests
struct User: Codable {
    let name: String
    let avatar: String
    let description: String?
    let website: String
    let nfts: [String]
    let rating: String
    let id: String
}
