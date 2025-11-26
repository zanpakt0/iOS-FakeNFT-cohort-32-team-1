//
//  UsersRequest.swift
//  FakeNFT
//
//  Created by Muhammed Nurmukhanov on 22.11.2025.
//

import Foundation

// MARK: - Request for get users
struct GetUsersRequest: NetworkRequest {
    
    // MARK: - Endpoint
    var endpoint: URL? {
        URL(string: "https://d5dn3j2ouj72b0ejucbl.apigw.yandexcloud.net/api/v1/users?page=\(page)&size=\(size)")
    }
    
    // MARK: - Http mehod and body
    var httpMethod: HttpMethod { .get }
    var dto: Dto? { nil }
    
    // MARK: - Query params
    let page: Int
    let size: Int
}
