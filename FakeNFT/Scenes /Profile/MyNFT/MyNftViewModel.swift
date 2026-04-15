import Combine
import Foundation

final class MyNftViewModel {
    
    // MARK: - Private Properties
    @Published private(set) var state: BaseStateForNftList = .idle
    private(set) var listOfNfts: [NftCellViewData] = []
    private var idsOfFavouriteNfts: [String]
    
    private var isLoadingNfts = false
    private var isLikingNft = false
    
    private var currentTaskForLoadNfts: NetworkTask?
    private var currentTaskForLikeOrDislikeNft: NetworkTask?
    
    private let servicesAssembly: ServicesAssembly
    private let idsOfMyNft: [String]

    
    init(servicesAssembly: ServicesAssembly, profileData: ProfileViewData) {
        self.servicesAssembly = servicesAssembly
        self.idsOfMyNft = profileData.nfts
        self.idsOfFavouriteNfts = profileData.likes
    }
    
    // MARK: - Public Methods
    
    func downloadData() {
        fetchNfts {
            print("Список Мои nft загружены (количество): \(self.listOfNfts.count)")
        }
    }
    
    func setFilterTypeOfProfileToStorage(filterType: FilterType) {
        switch filterType {
        case .byPrice:
            UserDefaults.standard.set(FilterType.byPrice.rawValue, forKey: Constants.keyForFilterTypeInProfile)
        case .byRating:
            UserDefaults.standard.set(FilterType.byRating.rawValue, forKey: Constants.keyForFilterTypeInProfile)
        case .byName:
            UserDefaults.standard.set(FilterType.byName.rawValue, forKey: Constants.keyForFilterTypeInProfile)
        }
        sortByNeedFilterType()
    }
    
    func likeOrDislikeNft(isItLike: Bool, nftId: String) {
        let likes = Constants.configureNeedRequestBodyToPutRequests(
            nftId: nftId,
            isFavourite: isItLike,
            needNftList: idsOfFavouriteNfts)
        
        print("Дошло до лайка nft")
        
        guard !isLikingNft else { return }
        
        isLikingNft = true
        state = .loading
        
        currentTaskForLikeOrDislikeNft = servicesAssembly.nftService.putToFavoritesNft(likes: likes) { [weak self] result in
            DispatchQueue.main.async {
                guard let self else { return }
                
                self.isLikingNft = false
                
                switch result {
                case .success(let profile):
                    print("Успех при лайке nft")
                    let favouriteNfts = ListOfFavouriteNftsData(profile: profile)
                    self.idsOfFavouriteNfts = favouriteNfts.likes
                    
                    print("(Лайк) Количество понравившихся nft: \(self.idsOfFavouriteNfts.count)")
                    
                    if let index = self.listOfNfts.firstIndex(where: { $0.nft.id == nftId }) {
                        let old = self.listOfNfts[index]
                        
                        let updated = NftCellViewData(
                            nft: old.nft,
                            isFavourite: isItLike,
                            isInCart: old.isInCart
                        )
                        
                        self.listOfNfts[index] = updated
                    }
                    self.state = .loaded(self.listOfNfts)
                case .failure(let error):
                    print("Ошибка при лайке nft")
                    self.state = .errorWhenTapOnButtonsInCell(error)
                }
            }
            
        }
    }
    
    // MARK: - Private Methods
    
    private func fetchNfts(completion: @escaping () -> Void) {
        print("Дошло")
        
        guard !isLoadingNfts else { return }
        
        isLoadingNfts = true
        state = .loading
        
        let group = Constants.dispatchGroup
        
        for nftId in idsOfMyNft {
            group.enter()
            
            currentTaskForLoadNfts = servicesAssembly.nftService.getNft(id: nftId) { [weak self] result in
                DispatchQueue.main.async {
                    guard let self else { return }
                    
                    switch result {
                    case .success(let nft):
                        print("Успех при загрузке одной Nft")
                        let newNft = NftData(nftData: nft)
                        
                        self.addToListOfNftsExcludingDuplicates(nft: newNft)
                    case .failure(let error):
                        print("Ошибка при загрузке одной Nft")
                        
                        self.state = .error(error)
                    }
                    group.leave()
                }
            }
        }
        
        group.notify(queue: .main) { [weak self] in
            guard let self else { return }
            sortByNeedFilterType()
            
            self.isLoadingNfts = false
            self.state = .loaded(self.listOfNfts)
            
            completion()
        }
    }
    
    private func sortByNeedFilterType() {
        let filterType = getFilterTypeOfProfileFromStorage()
        
        switch filterType {
        case FilterType.byPrice.rawValue:
            sortByPrice()
        case FilterType.byRating.rawValue:
            sortByRating()
        case FilterType.byName.rawValue:
            sortByName()
        default:
            print("Такого фильтра нет")
        }
    }
    
    private func sortByPrice() {
        listOfNfts.sort { $0.nft.price > $1.nft.price }
    }
    
    private func sortByRating() {
        listOfNfts.sort { $0.nft.rating > $1.nft.rating }
    }
    
    private func sortByName() {
        listOfNfts.sort { $0.nft.name < $1.nft.name }
    }
    
    private func addToListOfNftsExcludingDuplicates(nft: NftData) {
        if !listOfNfts.contains(where: { $0.nft.id == nft.id }) {
            listOfNfts.append(NftCellViewData(
                nft: nft,
                isFavourite: checkIsNftFavourite(nftId: nft.id),
                isInCart: false))
        }
    }
    
    private func checkIsNftFavourite(nftId: String) -> Bool {
        return idsOfFavouriteNfts.contains(nftId)
    }
    
    private func getFilterTypeOfProfileFromStorage() -> String {
        guard let filterType = UserDefaults.standard.string(forKey: Constants.keyForFilterTypeInProfile) else {
            return FilterType.byRating.rawValue
        }
        return filterType
    }
}
