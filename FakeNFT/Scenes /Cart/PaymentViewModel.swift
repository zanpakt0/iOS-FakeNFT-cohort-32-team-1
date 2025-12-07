import UIKit

final class PaymentViewModel {
    
    private(set) var items: [CryptoPayment] = MockCrypto.items
    
    private(set) var selectedIndex: IndexPath?
    
    var onSuccess: (() -> Void)?
    var onError: ((_ retryHandler: @escaping () -> Void) -> Void)?
    
    func pay() {
        let success = Bool.random()
        if success {
            onSuccess?()
        } else {
            onError? { [weak self] in
                self?.pay()
            }
        }
    }
    
    func selectItem(at indexPath: IndexPath) {
        selectedIndex = indexPath
    }
}

