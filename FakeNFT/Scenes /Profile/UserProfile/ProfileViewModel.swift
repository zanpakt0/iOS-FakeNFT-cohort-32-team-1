import Foundation

// MARK: - Need enums
enum ProfileState {
    case idle
    case loading
    case loaded(ProfileViewData)
    case error(Error)
}

final class ProfileViewModel {
    
    // MARK: - Public Properties
    var profileInfo: ProfileViewData?
    let servicesAssembly: ServicesAssembly
    
    // MARK: - Private Properties
    @Published private(set) var state: ProfileState = .idle
    private var currentTask: NetworkTask?
    private var isLoading = false
    
    // MARK: - Initializers
    init(servicesAssembly: ServicesAssembly) {
        self.servicesAssembly = servicesAssembly
    }
    
    // MARK: - Public Methods
    func fetchProfileInfo() {
        currentTask?.cancel()
        print("Дошло")
    
        guard !isLoading else { return }
        
        isLoading = true
        state = .loading
        
        currentTask = servicesAssembly.nftService.getProfile { [weak self] result in
            DispatchQueue.main.async {
                guard let self else { return }
                
                self.isLoading = false
                self.currentTask = nil
                
                switch result {
                case .success(let profile):
                    
                    let profileInfo = ProfileViewData(profile: profile)
                    self.profileInfo = profileInfo
                    
                    self.state = .loaded(profileInfo)
                    print("Данные для профиля загружены: \(profileInfo.name)")
                case .failure(let error):
                    if (error as NSError).code == NSURLErrorCancelled {
                        return
                    }
                    
                    print("Ошибка во время загрузки данных для профиля")
                    self.state = .error(error)
                }
            }
        }
    }
    
    func stopTaskWhenClosed() {
        currentTask?.cancel()
        currentTask = nil
        isLoading = false
    }
}
