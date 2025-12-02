import Foundation

// MARK: - Need enums
enum StatisticsState {
    case idle
    case loading
    case loaded([UserCellViewData])
    case error(Error)
}

enum FilterType: String {
    case byName = "ByName"
    case byRating = "ByRating"
}

enum ConstantsForStatistics {
    static let pageSize: Int = 10
    static let keyForFilterTypeInStatistics: String = "filterTypeInStatistics"
    static let transitionDurationWhenOpenPage: CFTimeInterval = 0.01
}

final class StatisticsViewModel {
    
    // MARK: - Public Properties
    var usersList: [UserCellViewData] = []
    var pageNumber = 0
    let servicesAssembly: ServicesAssembly
    
    // MARK: - Private Properties
    @Published private(set) var state: StatisticsState = .idle
    private var currentTask: NetworkTask?
    private var isLoadingPage = false
    private var hasMorePages = true
    
    // MARK: - Initializers
    init(servicesAssembly: ServicesAssembly) {
        self.servicesAssembly = servicesAssembly
    }
    
    // MARK: - Public Methods
    func fetchUsers(size: Int = ConstantsForStatistics.pageSize) {
        print("Дошло")
        
        guard !isLoadingPage else { return }
        guard hasMorePages else { return }
        
        isLoadingPage = true
        state = .loading
        
        currentTask = servicesAssembly.nftService.getUsers(page: self.pageNumber, size: size) { [weak self] result in
            DispatchQueue.main.async {
                guard let self else { return }
                
                self.isLoadingPage = false
                
                switch result {
                case .success(let users):
                    print("Успех")
                    let usersList = users.map { UserCellViewData(user: $0)}
                    self.addToListExcludingDuplicates(usersList)
                    self.sortByNeedFilterType()
                    
                    if users.isEmpty {
                        self.hasMorePages = false
                    } else {
                        self.pageNumber += 1
                    }
                    
                    self.state = .loaded(self.usersList)
                    print(self.usersList.count)
                case .failure(let error):
                    print("Ошибка")
                    self.state = .error(error)
                }
            }
            
        }
    }
    
    func sortByNeedFilterType() {
        let filterType = self.getFilterTypeFromStorage()
        switch filterType {
        case FilterType.byName.rawValue:
            self.sortCellViewModelByName()
        default:
            self.sortCellViewModelByRating()
        }
    }
    
    func setFilterTypeToStorage(_ filterType: String) {
        UserDefaults.standard.set(filterType, forKey: ConstantsForStatistics.keyForFilterTypeInStatistics)
    }
    
    // MARK: - Private Methods
    private func sortCellViewModelByName() {
        self.usersList.sort { $0.name < $1.name }
    }
    
    private func sortCellViewModelByRating() {
        self.usersList.sort { $0.nfts.count > $1.nfts.count }
    }
    
    private func getFilterTypeFromStorage() -> String {
        guard let rawValue = UserDefaults.standard.string(forKey: ConstantsForStatistics.keyForFilterTypeInStatistics) else {
            return FilterType.byRating.rawValue
        }
        return rawValue
    }
    
    private func addToListExcludingDuplicates(_ newUsers: [UserCellViewData]) {
        let uniqueUsers = newUsers.filter { newUser in
            !usersList.contains(newUser)
        }
        self.usersList.append(contentsOf: uniqueUsers)
    }
}
