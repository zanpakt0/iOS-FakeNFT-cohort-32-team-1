import Foundation
import Combine

final class NFTCollectionViewModel {
    @Published var nfts: [Nft] = []
    @Published var isLoading = false
    
    private let provider: NftService
    
    //MARK: - Init
    init(provider: NftServiceImpl, nftIds: [String]) {
        self.provider = provider
        self.isLoading = true
        self.loadData(nftIds: nftIds)
    }
    
    func loadData(nftIds: [String]) {
        for id in nftIds {
            provider.loadNft(id: id) { [weak self] result in
                guard let self else { return }
                self.isLoading = false
                
                switch result {
                case .success(let nft):
                    self.nfts.append(nft)
                case .failure(let error):
                    print("Load failed", error)
                }
            }
        }
        self.isLoading = false
    }
}
