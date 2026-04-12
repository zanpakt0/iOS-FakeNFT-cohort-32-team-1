import Combine
import Foundation

final class MyNftViewModel {
    
    // MARK: - Public Properties
    var listOfNfts: [NftCellViewData] = []
    
    // MARK: - Private Properties
    @Published private(set) var state: BaseStateForQuery = .idle
    private var isLoading = false
    private var currentTask: NetworkTask?
    private let servicesAssembly: ServicesAssembly
    private let idsOfMyNft: [String]
    private let idsOfFavouriteNfts: [String]
    
    init(servicesAssembly: ServicesAssembly, profileData: ProfileViewData) {
        self.servicesAssembly = servicesAssembly
        self.idsOfMyNft = profileData.nfts
        self.idsOfFavouriteNfts = profileData.likes
    }
    
    // MARK: - Public Methods
    func fetchNfts(completion: @escaping () -> Void) {
        print("Дошло")
        
        guard !isLoading else { return }
        
        isLoading = true
        state = .loading
        
        let group = Constants.dispatchGroup
        
        for nftId in idsOfMyNft {
            group.enter()
            
            currentTask = servicesAssembly.nftService.getNft(id: nftId) { [weak self] result in
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
            
            self.isLoading = false
            self.state = .loaded
            print("Список Мои nft загружены (количество): \(self.listOfNfts.count)")
            
            completion()
        }
    }
    
    // MARK: - Private Methods
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
    
}
