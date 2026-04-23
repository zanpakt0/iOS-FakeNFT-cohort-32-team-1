import Foundation

// MARK: - Need enums
enum StatisticsState {
    case idle
    case loading
    case loaded([UserCellViewData])
    case error(Error)
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
        currentTask?.cancel()
        print("Дошло")
        
        guard !isLoadingPage else { return }
        guard hasMorePages else { return }
        
        isLoadingPage = true
        state = .loading
        
        currentTask = servicesAssembly.nftService.getUsers(page: pageNumber, size: size) { [weak self] result in
            DispatchQueue.main.async {
                guard let self else { return }
                
                self.isLoadingPage = false
                self.currentTask = nil
                
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
                    if (error as NSError).code == NSURLErrorCancelled {
                        return
                    }
                    
                    print("Ошибка")
                    self.state = .error(error)
                }
            }
            
        }
    }
    
    func stopTaskWhenClosed() {
        currentTask?.cancel()
        currentTask = nil
        isLoadingPage = false
    }
    
    func sortByNeedFilterType() {
        let filterType = getFilterTypeOfStatisticsFromStorage()
        switch filterType {
        case FilterTypeForStatistics.byName.rawValue:
            sortCellViewModelByName()
        default:
            sortCellViewModelByRating()
        }
    }
    
    func setFilterTypeOfStatisticsToStorage(_ filterType: String) {
        UserDefaults.standard.set(filterType, forKey: ConstantsForStatistics.keyForFilterTypeInStatistics)
    }
    
    // MARK: - Private Methods
    private func sortCellViewModelByName() {
        usersList.sort { $0.name < $1.name }
    }
    
    private func sortCellViewModelByRating() {
        usersList.sort { $0.nfts.count > $1.nfts.count }
    }
    
    private func getFilterTypeOfStatisticsFromStorage() -> String {
        guard let rawValue = UserDefaults.standard.string(forKey: ConstantsForStatistics.keyForFilterTypeInStatistics) else {
            return FilterTypeForStatistics.byRating.rawValue
        }
        return rawValue
    }
    
    private func addToListExcludingDuplicates(_ newUsers: [UserCellViewData]) {
        let uniqueUsers = newUsers.filter { newUser in
            !usersList.contains(newUser)
        }
        usersList.append(contentsOf: uniqueUsers)
    }
}
