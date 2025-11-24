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
    private var currentTask: NetworkTask?
    
    var cellViewModels: [UsersListCellViewModel] = []
    var pageNumber = 0
    
    private var isLoadingPage = false
    private var hasMorePages = true
    
    init(servicesAssembly: ServicesAssembly) {
        self.servicesAssembly = servicesAssembly
    }
    
    func fetchUsers(page: Int, size: Int = 10) {
        print("Дошло")
        
        guard !isLoadingPage else { return }
        guard hasMorePages else { return }
        
        isLoadingPage = true
        state = .loading
        
        currentTask = servicesAssembly.nftService.getUsers(page: page, size: size) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                
                self.isLoadingPage = false
                
                switch result {
                case .success(let users):
                    print("Успех")
                    let cellViewModels = users.map { UsersListCellViewModel(user: $0)}
                    self.addToListExcludingDuplicates(cellViewModels)
                    
                    if users.isEmpty {
                        self.hasMorePages = false
                    } else {
                        self.pageNumber += 1
                    }
                    
                    self.state = .loaded(self.cellViewModels)
                    print(self.cellViewModels)
                case .failure(let error):
                    print("Ошибка")
                    self.state = .error(error)
                }
            }
            
        }
    }
    
    private func addToListExcludingDuplicates(_ newUsers: [UsersListCellViewModel]) {
        let uniqueUsers = newUsers.filter { newUser in
            !cellViewModels.contains(newUser)
        }
        self.cellViewModels.append(contentsOf: uniqueUsers)
    }
}
