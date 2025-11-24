//
//  StatisticsViewModel.swift
//  FakeNFT
//
//  Created by Muhammed Nurmukhanov on 22.11.2025.
//

import Foundation

enum StatisticsState {
    case idle
    case loading
    case loaded([UsersListCellViewModel])
    case error(Error)
}

final class StatisticsViewModel {
    
    @Published private(set) var state: StatisticsState = .idle
    private let servicesAssembly: ServicesAssembly
    
    init(servicesAssembly: ServicesAssembly) {
        self.servicesAssembly = servicesAssembly
    }
    
}
