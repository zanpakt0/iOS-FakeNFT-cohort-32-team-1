//
//  UsersRequest.swift
//  FakeNFT
//
//  Created by Muhammed Nurmukhanov on 22.11.2025.
//

import Foundation

struct GetUsersRequest: NetworkRequest {
    var endpoint: URL? {
        URL(string: "https://d5dn3j2ouj72b0ejucbl.apigw.yandexcloud.net/api/v1/users?page=\(page)&size=\(size)")
    }
    
    var httpMethod: HttpMethod { .get }
    var dto: Dto? { nil }
    
    let page: Int
    let size: Int
}
