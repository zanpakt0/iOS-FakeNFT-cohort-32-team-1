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
}
