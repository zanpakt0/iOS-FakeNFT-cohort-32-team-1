import UIKit

protocol NFTService {
    func fetchNFTs(with ids: [String], completion: @escaping (Result<[NFTCart], Error>) -> Void)
}

struct NFTUIItem {
    let id: String
    var image: UIImage?
    let imageUrl: URL?
    let title: String
    var rating: Int
    let price: Double
}

struct NFTCart: Decodable {
    let id: String
    let name: String
    let price: Double
    let imageUrl: URL?
    let rating: Int?
    
    private enum CodingKeys: String, CodingKey {
        case id, name, price, rating
        case images
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        price = try container.decode(Double.self, forKey: .price)
        rating = try container.decodeIfPresent(Int.self, forKey: .rating) ?? 0
        
        if let urls = try container.decodeIfPresent([String].self, forKey: .images) {
            imageUrl = URL(string: urls.first ?? "")
        } else {
            imageUrl = nil
        }
    }
}

final class NFTServiceImpl: NFTService {
    
    func fetchNFTs(with ids: [String], completion: @escaping (Result<[NFTCart], Error>) -> Void) {
        guard !ids.isEmpty else {
            completion(.success([]))
            return
        }
        
        let idsQuery = ids.joined(separator: ",")
        let urlString = "\(RequestConstants.baseURL)/api/v1/nft?ids=\(idsQuery)"
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "NFTService", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue(RequestConstants.token, forHTTPHeaderField: "X-Practicum-Mobile-Token")
        
        print("FETCH NFTS")
        print("URL: \(request.url?.absoluteString ?? "nil")")
        print("Method: \(request.httpMethod ?? "nil")")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("NETWORK ERROR: \(error)")
                DispatchQueue.main.async { completion(.failure(error)) }
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                print("HTTP STATUS: \(httpResponse.statusCode)")
            }
            
            guard let data = data else {
                let err = NSError(domain: "NFTService", code: 0, userInfo: [NSLocalizedDescriptionKey: "No data"])
                print("ERROR: No data")
                DispatchQueue.main.async { completion(.failure(err)) }
                return
            }
            
            if let raw = String(data: data, encoding: .utf8) {
                print("RAW RESPONSE: \(raw)")
            }
            
            do {
                let allNFTs = try JSONDecoder().decode([NFTCart].self, from: data)
                
                let idsSet = Set(ids)
                let filteredNFTs = allNFTs.filter {
                    idsSet.contains($0.id)
                }
                
                print("JSON decoded: \(filteredNFTs.count) NFT(s)")
                DispatchQueue.main.async {
                    completion(.success(filteredNFTs))
                }
            } catch {
                print("DECODING ERROR: \(error)")
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }.resume()
    }
}
