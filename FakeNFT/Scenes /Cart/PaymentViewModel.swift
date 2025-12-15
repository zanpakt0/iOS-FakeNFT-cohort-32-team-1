import UIKit

final class PaymentViewModel {
    
    private let paymentService: PaymentService
    private let nftIds: [String]
    private var orderId: String?
    
    private(set) var items: [PaymentMethod] = []
    var selectedIndex: IndexPath?
    
    var onItemsLoaded: (() -> Void)?
    var onSuccess: (() -> Void)?
    var onError: ((String) -> Void)?
    
    init(paymentService: PaymentService, nftIds: [String]) {
        self.paymentService = paymentService
        self.nftIds = nftIds
    }
    
    func loadCurrencies() {
        paymentService.fetchCurrencies { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let currencies):
                self.items = currencies.map { PaymentMethod(id: $0.id, title: $0.title, name: $0.name, image: $0.image) }
                self.onItemsLoaded?()
            case .failure(let error):
                self.onError?(error.localizedDescription)
            }
        }
    }
    
    func selectItem(at indexPath: IndexPath) {
        selectedIndex = indexPath
    }
    
    func pay() {
        guard let index = selectedIndex else {
            return
        }
        
        let currency = items[index.item]
        createOrderIfNeeded(currency: currency)
    }
    
    private func createOrderIfNeeded(currency: PaymentMethod) {
        if let orderId {
            pay(orderId: orderId, currencyId: currency.id)
            return
        }
        
        paymentService.createOrder(nfts: nftIds, currency: currency.name) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let response):
                self.orderId = response.id
                self.pay(orderId: response.id, currencyId: currency.id)
            case .failure(let error):
                self.onError?(error.localizedDescription)
            }
        }
    }
    
    private func pay(orderId: String, currencyId: String) {
        paymentService.pay(orderId: orderId, currencyId: currencyId) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success:
                self.onSuccess?()
            case .failure(let error):
                self.onError?(error.localizedDescription)
            }
        }
    }
}
