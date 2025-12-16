import Foundation

protocol PaymentService {
    func createOrder(nfts: [String], currency: String, completion: @escaping (Result<CreateOrderResponse, Error>) -> Void)
    func fetchCurrencies(completion: @escaping (Result<[Currency], Error>) -> Void)
    func pay(orderId: String, currencyId: String, completion: @escaping (Result<Void, Error>) -> Void)
}

