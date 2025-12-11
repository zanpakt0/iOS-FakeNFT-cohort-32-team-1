import UIKit

protocol NFTService {
    func fetchNFTs(with ids: [String], completion: @escaping (Result<[NFT], Error>) -> Void)
}

struct NFTUIItem {
    let id: String
    var image: UIImage?
    let imageUrl: URL?
    let title: String
    var rating: Int
    let price: Double
}

struct NFT: Decodable {
    let id: String
    let name: String
    let price: Double
    let imageUrl: URL?
    let rating: Int?
    
    private enum CodingKeys: String, CodingKey {
        case id, name, price
        case images
        case rating
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        price = try container.decode(Double.self, forKey: .price)
        rating = try container.decodeIfPresent(Int.self, forKey: .rating) ?? 0
        
        if let urls = try? container.decode([URL].self, forKey: .images) {
            imageUrl = urls.first
        } else {
            imageUrl = nil
        }
    }
}

final class NFTServiceImpl: NFTService {
    
    func fetchNFTs(with ids: [String], completion: @escaping (Result<[NFT], Error>) -> Void) {
        guard !ids.isEmpty else {
            completion(.success([]))
            return
        }
        
        var nfts: [NFT] = []
        let group = DispatchGroup()
        var fetchError: Error?
        
        for id in ids {
            group.enter()
            let urlString = "\(RequestConstants.baseURL)/api/v1/nft/\(id)"
            guard let url = URL(string: urlString) else {
                fetchError = NSError(domain: "NFTService", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])
                group.leave()
                continue
            }
            
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.addValue(RequestConstants.token, forHTTPHeaderField: "X-Practicum-Mobile-Token")
            
            URLSession.shared.dataTask(with: request) { data, response, error in
                defer { group.leave() }
                
                if let error = error {
                    fetchError = error
                    return
                }
                
                guard let data = data else {
                    fetchError = NSError(domain: "NFTService", code: 0, userInfo: [NSLocalizedDescriptionKey: "No data"])
                    return
                }
                
                do {
                    let nft = try JSONDecoder().decode(NFT.self, from: data)
                    nfts.append(nft)
                } catch {
                    fetchError = error
                }
            }.resume()
        }
        
        group.notify(queue: .main) {
            if let error = fetchError {
                completion(.failure(error))
            } else {
                completion(.success(nfts))
            }
        }
    }
}
