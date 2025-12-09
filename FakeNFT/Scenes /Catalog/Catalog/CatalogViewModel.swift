import UIKit
import Combine

final class CatalogViewModel {
    //MARK: - Published Variables
    @Published var catalog: [Catalog] = []
    @Published var isLoading = false
    @Published var loadError: Error?
    
    //MARK: - Constants
    private let catalogProvider: CatalogProviderProtocol
    
    //MARK: - Init
    init(catalogProvider: CatalogProvider) {
        self.catalogProvider = catalogProvider
        
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
        self.isLoading = true
        self.loadError = nil
        catalogProvider.loadCatalog { [weak self] result in
            guard let self else { return }
            self.isLoading = false
            
            switch result {
            case .success(let catalog):
                self.catalog = catalog
            case .failure(let error):
                print("Load failed", error)
                self.loadError = error
            }
        }
    }
}
