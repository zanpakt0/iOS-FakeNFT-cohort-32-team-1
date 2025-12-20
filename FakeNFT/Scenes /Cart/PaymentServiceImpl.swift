import Foundation

final class PaymentServiceImpl: PaymentService {
    
    private let client: NetworkClient
    private let baseURL: String
    
    init(client: NetworkClient, baseURL: String) {
        self.client = client
        self.baseURL = baseURL
    }
    
    func fetchCurrencies(completion: @escaping (Result<[Currency], Error>) -> Void) {
        let request = CurrenciesRequest()
        print("Fetching currencies from URL:", request.endpoint?.absoluteString ?? "nil")
        
        client.send(request: request, completionQueue: .main) { result in
            switch result {
            case .success(let data):
                do {
                    let currencies = try JSONDecoder().decode([Currency].self, from: data)
                    completion(.success(currencies))
                } catch {
                    completion(.failure(error))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func createOrder(nfts: [String], currency: String, completion: @escaping (Result<CreateOrderResponse, Error>) -> Void) {
        let request = PutOrdersRequest(orders: nfts)
        print("Creating order with NFTs:", nfts, "currency:", currency)
        
        client.send(request: request, completionQueue: .main) { result in
            switch result {
            case .success(let data):
                do {
                    let response = try JSONDecoder().decode(CreateOrderResponse.self, from: data)
                    completion(.success(response))
                } catch {
                    completion(.failure(error))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func pay(orderId: String, currencyId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let request = PayRequest(currencyId: currencyId)
        print("Paying order \(orderId) with currencyId \(currencyId)")
        
        client.send(request: request, completionQueue: .main) { result in
            switch result {
            case .success(let data):
                do {
                    let payResponse = try JSONDecoder().decode(PayResponse.self, from: data)
                    if payResponse.success {
                        completion(.success(()))
                    } else {
                        completion(.failure(NSError(domain: "Payment failed", code: 0)))
                    }
                } catch {
                    completion(.failure(error))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func deleteAllNFT(
        id: String,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        let request = DeleteNFTFromCartRequest(nftId: id)
        
        client.send(request: request) { result in
            switch result {
            case .success:
                completion(.success(()))
                
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
