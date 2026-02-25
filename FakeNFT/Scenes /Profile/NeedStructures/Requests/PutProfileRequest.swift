import Foundation

// MARK: - Request for change profile data
struct PutProfileRequest: NetworkRequest {
    
    // MARK: - Endpoint
    var endpoint: URL? {
        var components = URLComponents(string: RequestConstants.baseURL)
        components?.path = "/api/v1/profile/1"
        return components?.url
    }
    
    // MARK: - Http mehod and body
    var dto: Dto?
    var httpMethod: HttpMethod { .put }
    
    init(profileFields: ProfileFields) {
        guard let name = profileFields.name,
              let description = profileFields.description,
              let avatar = profileFields.avatar,
              let website = profileFields.website else { return }
        
        self.dto = PutProfileDto(name: name, description: description, avatar: avatar, website: website)
    }
}

struct PutProfileDto: Dto {
    let name: String
    let description: String
    let avatar: String
    let website: String
    
    func asDictionary() -> [String : String] {
        ["description": description,
         "avatar": avatar,
         "name": name,
         "website": website]
    }
}
