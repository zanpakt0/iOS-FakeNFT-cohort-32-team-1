import Foundation

enum UserCollectionState {
    case idle
    case loading
    case loaded([NftCellViewData])
    case error(Error)
}

final class UserCollectionViewModel {
    
    // MARK: - Public Properties
    var nftList: [NftCellViewData] = []
    
    // MARK: - Private Properties
    @Published private(set) var state: UserCollectionState = .idle
    private let serviceAssembly: ServicesAssembly
    private var currentTask: NetworkTask?
    private var isLoading = false
    
    // MARK: - Initializers
    init(serviceAssembly: ServicesAssembly) {
        self.serviceAssembly = serviceAssembly
    }
}
