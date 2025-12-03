import UIKit
import Combine

final class CatalogViewModel {
    //MARK: - Constants
    @Published var catalog: [Catalog] = []
    @Published var isLoading = false
    
    private let catalogProvider: CatalogProviderProtocol
    
    //MARK: - Init
    init(catalogProvider: CatalogProvider) {
        self.catalogProvider = catalogProvider
        self.isLoading = true
        
        loadData()
    }
    
    //MARK: - Methods
    func sortByName() {
        catalog = catalog.sorted(by: { $0.name < $1.name })
    }
    
    func sortByCountOfNfts() {
        catalog = catalog.sorted(by: { $0.nfts.count > $1.nfts.count })
    }
    
    func loadData() {
        catalogProvider.loadCatalog { [weak self] result in
            guard let self else { return }
            self.isLoading = false
            
            switch result {
            case .success(let catalog):
                self.catalog = catalog
            case .failure(let error):
                print("Load failed", error)
            }
        }
    }
}
