//
//  UserCardViewModel.swift
//  FakeNFT
//
//  Created by Muhammed Nurmukhanov on 26.11.2025.
//

import Foundation

enum UserCardState {
    case idle
    case loading
    case loaded(UserCardViewData)
    case error(Error)
}

final class UserCardViewModel {
    
    var userInfo: UserCardViewData?
    
    @Published private(set) var state: UserCardState = .idle
    private let serviceAssembly: ServicesAssembly
    private var currentTask: NetworkTask?
    private var isLoading = false
    
    init(serviceAssembly: ServicesAssembly) {
        self.serviceAssembly = serviceAssembly
    }
    
    func fetchUserById(_ id: String) {
        print("Дошло")
        
        guard !isLoading else { return }
        
        isLoading = true
        state = .loading
        
        currentTask = serviceAssembly.nftService.getUserCard(id: id) {[weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                
                self.isLoading = false
                
                switch result {
                case .success(let user):
                    print("Успех")
                    
                    let userInfo = UserCardViewData(user: user)
                    self.userInfo = userInfo
                    
                    self.state = .loaded(userInfo)
                    print(userInfo)
                case .failure(let error):
                    print("Ошибка")
                    self.state = .error(error)
                }
            }
        }
    }
}
