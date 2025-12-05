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
    var nftIdsList: [String]?
    
    // MARK: - Private Properties
    @Published private(set) var state: UserCollectionState = .idle
    private let serviceAssembly: ServicesAssembly
    private var currentTask: NetworkTask?
    private var isLoading = false
    
    // MARK: - Initializers
    init(serviceAssembly: ServicesAssembly) {
        self.serviceAssembly = serviceAssembly
    }
    
    // MARK: - Public Methods
    func fetchNfts(listOfNfts: [String]) {
        print("Дошло")
        
        guard !isLoading else { return }
        
        isLoading = true
        self.nftIdsList = listOfNfts
        state = .loading
        
        let group = DispatchGroup()
        
        for nftid in listOfNfts {
            group.enter()
            
            currentTask = serviceAssembly.nftService.getNft(id: nftid) { [weak self] result in
                DispatchQueue.main.async {
                    guard let self else { return }
                    
                    switch result {
                    case .success(let nft):
                        print("Успех")
                        let newNft = NftCellViewData(nftData: nft)
                        self.addToListOfNftsExcludingDuplicates(newNft)
                    case .failure(let error):
                        print("Ошибка")
                        self.state = .error(error)
                    }
                    group.leave()
                }
            }
        }
        
        group.notify(queue: .main) { [weak self] in
            guard let self else { return }
            self.isLoading = false
            self.state = .loaded(self.nftList)
            print("Все загрузилось")
            print(self.nftList.count)
        }
    }
    
    // MARK: - Private Methods
    private func addToListOfNftsExcludingDuplicates(_ newNft: NftCellViewData) {
        if !nftList.contains(where: {newNft.id == $0.id}) {
            nftList.append(newNft)
        }
    }
}
