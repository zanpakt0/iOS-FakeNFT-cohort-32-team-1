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
    var listOfFavouriteNfts: [String]?
    var listOfNftsInShoppingCart: [String]?
    
    // MARK: - Private Properties
    @Published private(set) var state: UserCollectionState = .idle
    private let servicesAssembly: ServicesAssembly
    private var currentTask: NetworkTask?
    private var isLoadingCollection = false
    private var isLoadingFavourites = false
    private var isLoadingOrdered = false
    
    // MARK: - Initializers
    init(servicesAssembly: ServicesAssembly) {
        self.servicesAssembly = servicesAssembly
    }
    
    // MARK: - Public Methods
    func loadEverything(listOfNfts: [String]) {
        fetchNftsCollectionOfUser(listOfNfts: listOfNfts) { [weak self] in
            self?.fetchFavouritesNftsList { [weak self] in
                self?.fetchOrderedNftsList { [weak self] in
                    guard let nftList = self?.nftList else { return }
                    
                    self?.state = .loaded(nftList)
                }
            }
        }
    }
    
    // MARK: - Private Methods
    private func fetchNftsCollectionOfUser(listOfNfts: [String], completion: @escaping () -> Void) {
        print("Дошло")
        
        guard !isLoadingCollection else { return }
        
        isLoadingCollection = true
        self.nftIdsList = listOfNfts
        state = .loading
        
        let group = DispatchGroup()
        
        for nftid in listOfNfts {
            group.enter()
            
            currentTask = servicesAssembly.nftService.getNft(id: nftid) { [weak self] result in
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
            self.isLoadingCollection = false
            print("Все загрузилось")
            print(self.nftList.count)
            
            completion()
        }
    }
    
    private func fetchFavouritesNftsList(completion: @escaping () -> Void) {
        print("Дошло до подгрузки понравившихся nft")
        
        guard !isLoadingFavourites else { return }
        
        isLoadingFavourites = true
        state = .loading
        
        currentTask = servicesAssembly.nftService.getFavouritesNft { [weak self] result in
            DispatchQueue.main.async {
                guard let self else { return }
                
                self.isLoadingFavourites = false
                
                switch result {
                case .success(let nfts):
                    print("Успех при загрузке понравившихся nft")
                    let favouriteNfts = ListOfFavouriteNftsData(profile: nfts)
                    self.listOfFavouriteNfts = favouriteNfts.likes
                    
                    guard let listOfFavouriteNfts = self.listOfFavouriteNfts else { return }
                    print("Количество понравившихся nft: \(listOfFavouriteNfts.count)")
                    
                    completion()
                case .failure(let error):
                    print("Ошибка при загрузке понравившихся nft")
                    self.state = .error(error)
                }
            }
            
        }
    }
    
    private func fetchOrderedNftsList(completion: @escaping () -> Void) {
        print("Дошло до подгрузки nft в корзине")
        
        guard !isLoadingOrdered else { return }
        
        isLoadingOrdered = true
        state = .loading
        
        currentTask = servicesAssembly.nftService.getOrderedNft { [weak self] result in
            DispatchQueue.main.async {
                guard let self else { return }
                
                self.isLoadingOrdered = false
                
                switch result {
                case .success(let nfts):
                    print("Успех при загрузке nft в корзине")
                    let orderedNfts = ListOfOrderedNftsData(order: nfts)
                    self.listOfNftsInShoppingCart = orderedNfts.nfts
                    
                    guard let listOfOrderedNfts = self.listOfNftsInShoppingCart else { return }
                    print("Количество nft в корзине: \(listOfOrderedNfts.count)")
                    
                    completion()
                case .failure(let error):
                    print("Ошибка при загрузке nft в корзине")
                    self.state = .error(error)
                }
            }
            
        }
    }
    
    private func prepareNftCellData(nft: NftData) -> NftCellViewData {
        let isFavourite = listOfFavouriteNfts?.contains(nft.id) ?? false
        let isInCart = listOfNftsInShoppingCart?.contains(nft.id) ?? false
        
        return NftCellViewData(
            nft: nft,
            isFavourite: isFavourite,
            isInChart: isInCart)
    }

    private func addToListOfNftsExcludingDuplicates(_ newNft: NftCellViewData) {
        if !nftList.contains(where: {newNft.nft.id == $0.nft.id}) {
            nftList.append(newNft)
        }
    }
}
