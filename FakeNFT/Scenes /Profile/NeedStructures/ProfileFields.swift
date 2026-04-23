struct ProfileFields {
    let name: String?
    let description: String?
    let avatar: String?
    let website: String?
    
    init(name: String?, description: String?, avatar: String?, website: String?) {
        self.name = name
        self.description = description
        self.avatar = avatar
        self.website = website
    }
}

