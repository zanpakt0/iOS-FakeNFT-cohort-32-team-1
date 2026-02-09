import Combine

// MARK: - Need enums
enum EditProfileState {
    case idle
    case loading
    case loaded(ProfileViewData)
    case error(Error)
}

final class EditProfileViewModel {
    
    // MARK: - Public Properties
    var profileData: ProfileViewData?
    let servicesAssembly: ServicesAssembly
    
    // MARK: - Private Properties
    @Published private(set) var state: EditProfileState = .idle
    private var currentTask: NetworkTask?
    private var isLoading = false
    
    // MARK: - Initializers
    init(servicesAssembly: ServicesAssembly) {
        self.servicesAssembly = servicesAssembly
    }
    
}
