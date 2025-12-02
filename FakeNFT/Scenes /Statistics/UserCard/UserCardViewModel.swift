import Foundation

// MARK: - Need enums
enum UserCardState {
    case idle
    case loading
    case loaded(UserCardViewData)
    case error(Error)
}

final class UserCardViewModel {
    
    // MARK: - Public Properties
    var userInfo: UserCardViewData?
    var userId: String?
    let serviceAssembly: ServicesAssembly
    
    // MARK: - Private Properties
    @Published private(set) var state: UserCardState = .idle
    private var currentTask: NetworkTask?
    private var isLoading = false
    
    // MARK: - Initializers
    init(serviceAssembly: ServicesAssembly) {
        self.serviceAssembly = serviceAssembly
    }
    
    // MARK: - Public Methods
    func fetchUserById(_ id: String) {
        print("Дошло")
        
        guard !isLoading else { return }
        
        isLoading = true
        self.userId = id
        state = .loading
        
        currentTask = serviceAssembly.nftService.getUserCard(id: id) {[weak self] result in
            DispatchQueue.main.async {
                guard let self else { return }
                
                self.isLoading = false
                
                switch result {
                case .success(let user):
                    print("Успех")
                    
                    let userInfo = UserCardViewData(user: user)
                    self.userInfo = userInfo
                    
                    self.state = .loaded(userInfo)
                    print("User name: \(userInfo.name)")
                case .failure(let error):
                    print("Ошибка")
                    self.state = .error(error)
                }
            }
        }
    }
}
