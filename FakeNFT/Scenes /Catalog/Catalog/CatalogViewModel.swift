import UIKit
import Combine

final class CatalogViewModel {
    //MARK: - Constants
    @Published var catalog: [CatalogItem] = []
    @Published var isLoading = false
    
    private let catalogProvider: CatalogProviderProtocol
    
    //MARK: - Init
    init(catalogProvider: CatalogProvider) {
        self.catalogProvider = catalogProvider
        reload()
    }
    
    //MARK: - Methods
    private func convert(_ catalog: [Catalog]) -> [CatalogItem] {
        catalog.map { catalog in
            CatalogItem(
                imageURL: catalog.cover,
                title: catalog.name,
                count: catalog.nfts.count
            )
        }
    }
    
    func sortByName() {
        catalog = catalog.sorted(by: { $0.title < $1.title })
    }
    
    func sortByCountOfNfts() {
        catalog = catalog.sorted(by: { $0.count > $1.count })
    }
    
    func reload() {
        self.isLoading = true
        
        catalogProvider.loadCatalog { [weak self] result in
            guard let self else { return }
            self.isLoading = false
            
            switch result {
            case .success(let catalog):
                self.catalog = self.convert(catalog)
            case .failure(let error):
                print("Load failed", error)
            }
        }
    }
}
