//
//  GetUserCardRequest.swift
//  FakeNFT
//
//  Created by Muhammed Nurmukhanov on 26.11.2025.
//

import Foundation

// MARK: - Request for get user by id
struct GetUserCardRequest: NetworkRequest {
    
    // MARK: - Endpoint
    var endpoint: URL? {
        var components = URLComponents(string: RequestConstants.baseURL)
        components?.path = "/api/v1/users/\(id)"
        return components?.url
    }
    
    // MARK: - Http mehod and body
    var httpMethod: HttpMethod { .get }
    var dto: Dto? { nil }
    
    // MARK: - User data
    let id: String
}
