import Combine

// MARK: - Need enums
enum EditProfileState {
    case idle
    case loading
    case loaded(ProfileViewData)
    case error(Error)
}

final class EditProfileViewModel {
    
    // MARK: - Private Properties
    @Published private(set) var state: EditProfileState = .idle
    @Published private(set) var isSaveButtonVisible: Bool = false
    
    private(set) var profileData: ProfileViewData
    private var originalData: ProfileViewData
    
    private let servicesAssembly: ServicesAssembly
    private var currentTask: NetworkTask?
    private var isLoading = false
    
    // MARK: - Initializers
    init(servicesAssembly: ServicesAssembly, profileData: ProfileViewData) {
        self.servicesAssembly = servicesAssembly;
        self.profileData = profileData
        self.originalData = profileData
    }
    
    // MARK: - Public Methods
    func updateName(_ newName: String?) {
        guard let description = profileData.description,
              let websiteURL = profileData.websiteURL,
              let avatarURL = profileData.avatarURL,
              let newName else { return }
        
        let newProfileData = ProfileViewData(
            profile: Profile(
                name: newName,
                avatar: avatarURL.absoluteString,
                description: description,
                website: websiteURL.absoluteString,
                nfts: profileData.nfts,
                likes: profileData.likes,
                id: profileData.id
            ))
        
        self.profileData = newProfileData
        recalcSaveButton()
    }
    
    func updateDescription(_ newDescription: String?) {
        guard let websiteURL = profileData.websiteURL,
              let avatarURL = profileData.avatarURL,
              let newDescription else { return }
        
        let newProfileData = ProfileViewData(
            profile: Profile(
                name: profileData.name,
                avatar: avatarURL.absoluteString,
                description: newDescription,
                website: websiteURL.absoluteString,
                nfts: profileData.nfts,
                likes: profileData.likes,
                id: profileData.id
            ))
        
        self.profileData = newProfileData
        recalcSaveButton()
    }
    
    func updateWebsite(_ newWebsite: String?) {
        guard let avatarURL = profileData.avatarURL,
              let description = profileData.description,
              let newWebsite else { return }
        
        let newProfileData = ProfileViewData(
            profile: Profile(
                name: profileData.name,
                avatar: avatarURL.absoluteString,
                description: description,
                website: newWebsite,
                nfts: profileData.nfts,
                likes: profileData.likes,
                id: profileData.id
            ))
        
        self.profileData = newProfileData
        recalcSaveButton()
    }
    
    func updateAvatar(newAvatar: String?) {
        guard let description = profileData.description,
              let websiteURL = profileData.websiteURL,
              let newAvatar else { return }
        
        let newProfileData = ProfileViewData(
            profile: Profile(
                name: profileData.name,
                avatar: newAvatar,
                description: description,
                website: websiteURL.absoluteString,
                nfts: profileData.nfts,
                likes: profileData.likes,
                id: profileData.id
            ))
        
        self.profileData = newProfileData
        recalcSaveButton()
    }
    
    // MARK: - Private Methods
    private func recalcSaveButton() {
        isSaveButtonVisible = profileData != originalData
    }
}
