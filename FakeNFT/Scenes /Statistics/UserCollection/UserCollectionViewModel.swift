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
    var listOfFavouriteNfts: [String]? = ["1fda6f0c-a615-4a1a-aa9c-a1cbd7cc76ae"]
    var listOfNftsInShoppingCart: [String]? = ["db196ee3-07ef-44e7-8ff5-16548fc6f434"]
    
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
                        let newNftData = NftData(nftData: nft)
                        let newNft = self.prepareNftCellData(nft: newNftData)
                        
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
    
    private func prepareNftCellData(nft: NftData) -> NftCellViewData {
        let isFavourite = listOfFavouriteNfts?.contains(nft.id) ?? false
        let isInChart = listOfNftsInShoppingCart?.contains(nft.id) ?? false
        
        return NftCellViewData(
            nft: nft,
            isFavourite: isFavourite,
            isInChart: isInChart)
    }
    
    // MARK: - Private Methods
    private func addToListOfNftsExcludingDuplicates(_ newNft: NftCellViewData) {
        if !nftList.contains(where: {newNft.nft.id == $0.nft.id}) {
            nftList.append(newNft)
        }
    }
}
