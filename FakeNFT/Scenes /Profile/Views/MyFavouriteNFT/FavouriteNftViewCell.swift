import UIKit

final class FavouriteNftViewCell: UICollectionViewCell {
    
    // MARK: - Identifier
    static let reusedIdentifier = "FavouriteNftViewCell"
    
    // MARK: Callbacks
    var didHeartButtonTapped: (()-> Void)?
    
    // MARK: Views (elements)
    private let imageOfNft: UIImageView = {
        let imageOfNft = UIImageView()
        imageOfNft.layer.cornerRadius = 12
        imageOfNft.clipsToBounds = true
        imageOfNft.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            imageOfNft.widthAnchor.constraint(equalToConstant: 80),
            imageOfNft.heightAnchor.constraint(equalToConstant: 80)
        ])
        
        return imageOfNft
    }()
    private let heartButton: UIButton = {
        let heartButton = UIButton(type: .system)
        heartButton.setImage(UIImage(resource: .likeButtonNoActive), for: .normal)
        heartButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            heartButton.widthAnchor.constraint(equalToConstant: 29.63),
            heartButton.heightAnchor.constraint(equalToConstant: 29.63)
        ])
        
        return heartButton
    }()
    private let nameOfNft: UILabel = {
        let nameOfNft = UILabel()
        nameOfNft.font = .bodyBold
        nameOfNft.textColor = .segmentActive
        nameOfNft.numberOfLines = 1
        nameOfNft.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            nameOfNft.widthAnchor.constraint(equalToConstant: 76)
        ])
        
        return nameOfNft
    }()
    private lazy var firstStar: UIImageView = createDefaultStar()
    private lazy var secondStar: UIImageView = createDefaultStar()
    private lazy var thirdStar: UIImageView = createDefaultStar()
    private lazy var fourthStar: UIImageView = createDefaultStar()
    private lazy var fifthStar: UIImageView = createDefaultStar()
    private lazy var stackViewOfStars: UIStackView = {
        let stackViewOfStars = UIStackView(arrangedSubviews: [firstStar, secondStar, thirdStar, fourthStar, fifthStar])
        
        stackViewOfStars.translatesAutoresizingMaskIntoConstraints = false
        stackViewOfStars.axis = .horizontal
        stackViewOfStars.spacing = 2
        
        return stackViewOfStars
    }()
    private let priceOfNft: UILabel = {
        let authorOfNft = UILabel()
        authorOfNft.font = .caption1
        authorOfNft.textColor = .segmentActive
        authorOfNft.numberOfLines = 1
        authorOfNft.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            authorOfNft.widthAnchor.constraint(equalToConstant: 76)
        ])
        
        return authorOfNft
    }()
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.backgroundColor = .forViewBackground
        
        addSubviews()
        addTargetsForButtons()
    }
    
    required init?(coder: NSCoder) {
        nil
    }
    
    // MARK: - Public Methods
    func configure(nftData: NftCellViewData) {
        guard let imageURL = nftData.nft.image else { return }
        
        imageOfNft.kf.setImage(with: imageURL, placeholder: nil, options: [.processor(Constants.processorWithTwelveCornerRadius)])
        
        heartButton.tintColor = nftData.isFavourite ? .redForFavouritesButton : .background
        nameOfNft.text = nftData.nft.name
        
        let stars = [firstStar, secondStar, thirdStar, fourthStar, fifthStar]
        visualizeStars(rating: nftData.nft.rating, stars: stars)
        
        priceOfNft.text = Constants.replaceDotsWithCommas(price: nftData.nft.price)
    }
    
    // MARK: - Private Methods
    @objc private func heartButtonClicked() {
        didHeartButtonTapped?()
    }
    
    private func addTargetsForButtons() {
        heartButton.addTarget(self, action: #selector(heartButtonClicked) , for: .touchUpInside)
    }
    
    private func addSubviews() {
        [imageOfNft, heartButton, nameOfNft, stackViewOfStars, priceOfNft].forEach {
            contentView.addSubview($0)
        }
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            imageOfNft.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageOfNft.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            
            heartButton.topAnchor.constraint(equalTo: imageOfNft.topAnchor),
            heartButton.trailingAnchor.constraint(equalTo: imageOfNft.trailingAnchor),
            
            nameOfNft.topAnchor.constraint(equalTo: imageOfNft.topAnchor, constant: 7),
            nameOfNft.leadingAnchor.constraint(equalTo: imageOfNft.trailingAnchor, constant: 12),
            
            stackViewOfStars.topAnchor.constraint(equalTo: nameOfNft.bottomAnchor, constant: 4),
            stackViewOfStars.leadingAnchor.constraint(equalTo: imageOfNft.trailingAnchor, constant: 12),
            
            priceOfNft.topAnchor.constraint(equalTo: stackViewOfStars.bottomAnchor, constant: 8),
            priceOfNft.leadingAnchor.constraint(equalTo: imageOfNft.trailingAnchor, constant: 12)
        ])
    }
    
}
