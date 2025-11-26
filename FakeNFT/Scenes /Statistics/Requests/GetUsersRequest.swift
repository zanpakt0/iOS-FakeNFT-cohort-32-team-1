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
        var components = URLComponents(string: RequestConstants.baseURL)
        components?.path = "/api/v1/users"
        components?.queryItems = [
            URLQueryItem(name: "page", value: "\(page)"),
            URLQueryItem(name: "size", value: "\(size)")
        ]
        return components?.url
    }
    
    // MARK: - Http mehod and body
    var httpMethod: HttpMethod { .get }
    var dto: Dto? { nil }
    
    // MARK: - Query params
    let page: Int
    let size: Int
}
