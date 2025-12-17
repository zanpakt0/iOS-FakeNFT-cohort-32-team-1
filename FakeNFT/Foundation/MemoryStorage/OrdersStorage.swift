import Foundation

protocol OrdersNftStorage: AnyObject {
    func saveNftOrder(_ order: [String])
    func getNftOrder() -> [String]?
}

final class OrdersNftStorageImpl: OrdersNftStorage {
    private var storage: [String] = []

    private let syncQueue = DispatchQueue(label: "sync-order-queue")

    func saveNftOrder(_ order: [String]) {
        syncQueue.sync { [weak self] in
            self?.storage = order
        }
    }

    func getNftOrder() -> [String]? {
        syncQueue.sync {
            storage
        }
    }
}
