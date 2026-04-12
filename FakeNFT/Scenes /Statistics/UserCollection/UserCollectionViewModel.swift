import Foundation

// MARK: - Need enums
enum UserCollectionState {
    case idle
    case loading
    case loaded([NftCellViewData])
    case error(Error)
    case errorWhenTapOnButtonsInCell(Error)
}

final class UserCollectionViewModel {
    
    // MARK: - Public Properties
    var nftList: [NftCellViewData] = []
    var nftIdsList: [String]?
    var listOfFavouriteNfts: [String] = []
    var listOfNftsInShoppingCart: [String] = []
    
    // MARK: - Private Properties
    @Published private(set) var state: UserCollectionState = .idle
    private let servicesAssembly: ServicesAssembly
    
    private var taskForLikeOrDislike: NetworkTask?
    private var taskForOrderOrUnorder: NetworkTask?
    private var taskForGetCollectionOfNfts: NetworkTask?
    private var taskForGetFavouriteNfts: NetworkTask?
    private var taskForGetOrderedNfts: NetworkTask?
    
    private var isLoadingCollection = false
    private var isLoadingFavourites = false
    private var isLoadingOrdered = false
    private var isLikingNft = false
    private var isOrderingNft = false
    
    // MARK: - Initializers
    init(servicesAssembly: ServicesAssembly) {
        self.servicesAssembly = servicesAssembly
    }
    
    // MARK: - Public Methods
    func loadEverything(listOfNfts: [String]) {
        state = .loading
        
        let group1 = Constants.dispatchGroup
        
        group1.enter()
        fetchFavouritesNftsList {
            group1.leave()
        }
        
        group1.enter()
        fetchOrderedNftsList {
            group1.leave()
        }
        
        group1.notify(queue: .main) {
            
            let group2 = Constants.dispatchGroup
            
            group2.enter()
            self.fetchNftsCollectionOfUser(listOfNfts: listOfNfts) {
                group2.leave()
            }
            
            group2.notify(queue: .main) {
                self.nftList.sort(by: {$0.nft.name < $1.nft.name})
                self.state = .loaded(self.nftList)
            }
        }
    }
    
    func likeOrDislikeNft(isItLike: Bool, nftId: String) {
        let likes = configureNeedRequestBodyToPutRequests(
            nftId: nftId,
            isFavourite: isItLike,
            needNftList: listOfFavouriteNfts)
        
        print("Дошло до лайка nft")
        
        guard !isLikingNft else { return }
        
        isLikingNft = true
        state = .loading
        
        taskForLikeOrDislike = servicesAssembly.nftService.putToFavoritesNft(likes: likes) { [weak self] result in
            DispatchQueue.main.async {
                guard let self else { return }
                
                self.isLikingNft = false
                
                switch result {
                case .success(let profile):
                    print("Успех при лайке nft")
                    let favouriteNfts = ListOfFavouriteNftsData(profile: profile)
                    self.listOfFavouriteNfts = favouriteNfts.likes
                    
                    print("(Лайк) Количество понравившихся nft: \(self.listOfFavouriteNfts.count)")
                    
                    if let index = self.nftList.firstIndex(where: { $0.nft.id == nftId }) {
                        let old = self.nftList[index]
                        
                        let updated = NftCellViewData(
                            nft: old.nft,
                            isFavourite: isItLike,
                            isInCart: old.isInCart
                        )
                        
                        self.nftList[index] = updated
                    }
                    self.state = .loaded(self.nftList)
                case .failure(let error):
                    print("Ошибка при лайке nft")
                    self.state = .errorWhenTapOnButtonsInCell(error)
                }
            }
            
        }
    }
    
    func orderOrUnorderNft(isInCart: Bool, nftId: String) {
        let nfts = configureNeedRequestBodyToPutRequests(
            nftId: nftId,
            isFavourite: isInCart,
            needNftList: listOfNftsInShoppingCart)
        
        print("Дошло до добавления в корзину nft")
        
        guard !isOrderingNft else { return }
        
        isOrderingNft = true
        state = .loading
        
        taskForOrderOrUnorder = servicesAssembly.nftService.putToOrderedNft(nfts: nfts) { [weak self] result in
            DispatchQueue.main.async {
                guard let self else { return }
                
                self.isOrderingNft = false
                
                switch result {
                case .success(let order):
                    print("Успех при добавлений в корзину nft")
                    let orderedNfts = ListOfOrderedNftsData(order: order)
                    self.listOfNftsInShoppingCart = orderedNfts.nfts
                    
                    print("(Добавление в корзину) Количество nft в корзине: \(self.listOfNftsInShoppingCart.count)")
                    
                    if let index = self.nftList.firstIndex(where: { $0.nft.id == nftId }) {
                        let old = self.nftList[index]
                        
                        let updated = NftCellViewData(
                            nft: old.nft,
                            isFavourite: old.isFavourite,
                            isInCart: isInCart
                        )
                        
                        self.nftList[index] = updated
                    }
                    self.state = .loaded(self.nftList)
                case .failure(let error):
                    print("Ошибка при добавлений в корзину nft")
                    self.state = .errorWhenTapOnButtonsInCell(error)
                }
            }
            
        }
    }
    
    // MARK: - Private Methods
    private func fetchNftsCollectionOfUser(listOfNfts: [String], completion: @escaping () -> Void) {
        print("Дошло")
        
        guard !isLoadingCollection else { return }
        
        isLoadingCollection = true
        nftIdsList = listOfNfts
        
        let group = Constants.dispatchGroup
        
        for nftid in listOfNfts {
            group.enter()
            
            taskForGetCollectionOfNfts = servicesAssembly.nftService.getNft(id: nftid) { [weak self] result in
                DispatchQueue.main.async {
                    guard let self else { return }
                    
                    switch result {
                    case .success(let nft):
                        print("Успех при загрузке одной nft")
                        let newNftData = NftData(nftData: nft)
                        let newNft = self.prepareNftCellData(nft: newNftData)
                        
                        self.addToListOfNftsExcludingDuplicates(newNft)
                    case .failure(let error):
                        print("Ошибка при загрузке одной nft")
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
        
        taskForGetFavouriteNfts = servicesAssembly.nftService.getFavouritesNft { [weak self] result in
            DispatchQueue.main.async {
                guard let self else { return }
                
                self.isLoadingFavourites = false
                
                switch result {
                case .success(let nfts):
                    print("Успех при загрузке понравившихся nft")
                    let favouriteNfts = ListOfFavouriteNftsData(profile: nfts)
                    self.listOfFavouriteNfts = favouriteNfts.likes
                    
                    print("Количество понравившихся nft: \(self.listOfFavouriteNfts.count)")
                    
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
        
        taskForGetOrderedNfts = servicesAssembly.nftService.getOrderedNft { [weak self] result in
            DispatchQueue.main.async {
                guard let self else { return }
                
                self.isLoadingOrdered = false
                
                switch result {
                case .success(let nfts):
                    print("Успех при загрузке nft в корзине")
                    let orderedNfts = ListOfOrderedNftsData(order: nfts)
                    self.listOfNftsInShoppingCart = orderedNfts.nfts
                    
                    print("Количество nft в корзине: \(self.listOfNftsInShoppingCart.count)")
                    
                    completion()
                case .failure(let error):
                    print("Ошибка при загрузке nft в корзине")
                    self.state = .error(error)
                }
            }
            
        }
    }
    
    private func prepareNftCellData(nft: NftData) -> NftCellViewData {
        let isFavourite = listOfFavouriteNfts.contains(nft.id)
        let isInCart = listOfNftsInShoppingCart.contains(nft.id)
        
        return NftCellViewData(
            nft: nft,
            isFavourite: isFavourite,
            isInCart: isInCart)
    }

    private func addToListOfNftsExcludingDuplicates(_ newNft: NftCellViewData) {
        if !nftList.contains(where: {newNft.nft.id == $0.nft.id}) {
            nftList.append(newNft)
        }
    }
    
    private func configureNeedRequestBodyToPutRequests(nftId: String, isFavourite: Bool, needNftList: [String]) -> String {
        var updatedList = needNftList
        if isFavourite {
            updatedList.append(nftId)
        } else if let index = updatedList.firstIndex(of: nftId) {
            updatedList.remove(at: index)
        }
        return updatedList.isEmpty ? "null" : updatedList.joined(separator: ", ")
    }
}
