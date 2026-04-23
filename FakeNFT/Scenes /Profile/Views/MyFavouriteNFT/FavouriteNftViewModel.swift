import Combine
import Foundation

final class FavouriteNftViewModel {
    
    // MARK: - Private Properties
    @Published private(set) var state: BaseStateForNftList = .idle
    private(set) var listOfNfts: [NftCellViewData] = []
    private var idsOfFavouriteNfts: [String]
    
    private var isLoadingNfts = false
    private var isDislikingNft = false
    
    private var currentTaskForLoadNfts: NetworkTask?
    private var currentTaskForDislikeNft: NetworkTask?
    
    private let servicesAssembly: ServicesAssembly
    
    // MARK: - Initializers
    init(servicesAssembly: ServicesAssembly, idsOfFavouriteNfts: [String]) {
        self.servicesAssembly = servicesAssembly
        self.idsOfFavouriteNfts = idsOfFavouriteNfts
    }
    
    // MARK: - Public Methods
    func loadData() {
        fetchNfts {
             print("Список Избранных nft загружены (количество): \(self.listOfNfts.count)")
        }
    }
    
    func dislikeNft(nftId: String) {
        let likes = Constants.configureNeedRequestBodyToPutRequests(
            nftId: nftId,
            isFavourite: false,
            needNftList: idsOfFavouriteNfts)
        
        print("Дошло до лайка nft")
        
        guard !isDislikingNft else { return }
        
        isDislikingNft = true
        state = .loading
        
        currentTaskForDislikeNft = servicesAssembly.nftService.putToFavoritesNft(likes: likes) { [weak self] result in
            DispatchQueue.main.async {
                guard let self else { return }
                
                self.isDislikingNft = false
                
                switch result {
                case .success(let profile):
                    print("Успех при дизлайке nft")
                    let favouriteNfts = ListOfFavouriteNftsData(profile: profile)
                    self.idsOfFavouriteNfts = favouriteNfts.likes
                    
                    print("(Лайк) Количество понравившихся nft: \(self.idsOfFavouriteNfts.count)")
                    
                    guard let idOfNftToDelete = self.listOfNfts.firstIndex(where: { $0.nft.id == nftId }) else { return }
                    self.listOfNfts.remove(at: idOfNftToDelete)
                    
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
        
        for nftId in idsOfFavouriteNfts {
            group.enter()
            
            currentTaskForLoadNfts = servicesAssembly.nftService.getNft(id: nftId) { [weak self] result in
                DispatchQueue.main.async {
                    guard let self else { return }
                    
                    switch result {
                    case .success(let nft):
                        print("Успех при загрузке одной Nft")
                        let newNft = NftData(nftData: nft)
                        
                        self.listOfNfts = Constants.addToListOfNftsExcludingDuplicates(
                            listOfNfts: self.listOfNfts,
                            nft: newNft,
                            idsOfFavouriteNfts: self.idsOfFavouriteNfts
                        )
                        
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
            
            self.isLoadingNfts = false
            self.state = .loaded(self.listOfNfts)
            
            completion()
        }
    }
    
    
}
