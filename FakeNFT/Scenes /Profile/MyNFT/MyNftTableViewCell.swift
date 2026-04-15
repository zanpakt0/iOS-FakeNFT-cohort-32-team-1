import UIKit
import Kingfisher

final class MyNftTableViewCell: UITableViewCell {
    
    // MARK: - Identifier
    static let reusedIdentifier = "MyNftTableViewCell"
    
    // MARK: Callbacks
    var didHeartButtonTapped: (()-> Void)?
    
    // MARK: - Views (elements)
    private let imageOfNft: UIImageView = {
        let imageOfNft = UIImageView()
        imageOfNft.layer.cornerRadius = 12
        imageOfNft.clipsToBounds = true
        imageOfNft.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            imageOfNft.widthAnchor.constraint(equalToConstant: 108),
            imageOfNft.heightAnchor.constraint(equalToConstant: 108)
        ])
        
        return imageOfNft
    }()
    private let heartButton: UIButton = {
        let heartButton = UIButton(type: .system)
        heartButton.setImage(UIImage(resource: .likeButtonNoActive), for: .normal)
        heartButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            heartButton.widthAnchor.constraint(equalToConstant: 40),
            heartButton.heightAnchor.constraint(equalToConstant: 40)
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
            nameOfNft.widthAnchor.constraint(equalToConstant: 78)
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
    private let authorOfNft: UILabel = {
        let authorOfNft = UILabel()
        authorOfNft.font = .caption2
        authorOfNft.textColor = .segmentActive
        authorOfNft.numberOfLines = 1
        authorOfNft.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            authorOfNft.widthAnchor.constraint(equalToConstant: 78)
        ])
        
        return authorOfNft
    }()
    private let textPriceOfNft: UILabel = {
        let priceText = NSLocalizedString("myNft.price", comment: "")
        let authorOfNft = UILabel()
        authorOfNft.font = .caption2
        authorOfNft.textColor = .segmentActive
        authorOfNft.numberOfLines = 1
        authorOfNft.text = priceText
        authorOfNft.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            authorOfNft.widthAnchor.constraint(equalToConstant: 75)
        ])
        
        return authorOfNft
    }()
    private let priceOfNft: UILabel = {
        let authorOfNft = UILabel()
        authorOfNft.font = .bodyBold
        authorOfNft.textColor = .segmentActive
        authorOfNft.numberOfLines = 1
        authorOfNft.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            authorOfNft.widthAnchor.constraint(equalToConstant: 95)
        ])
        
        return authorOfNft
    }()
    
    // MARK: - Initialization
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
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
        
        authorOfNft.text = "от \(nftData.nft.author)"
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
        [imageOfNft, heartButton, nameOfNft, stackViewOfStars, authorOfNft, textPriceOfNft, priceOfNft].forEach {
            contentView.addSubview($0)
        }
        
        setupContraints()
    }
    
    private func setupContraints() {
        NSLayoutConstraint.activate([
            imageOfNft.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            imageOfNft.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            imageOfNft.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
            
            heartButton.topAnchor.constraint(equalTo: imageOfNft.topAnchor),
            heartButton.trailingAnchor.constraint(equalTo: imageOfNft.trailingAnchor),
            
            nameOfNft.topAnchor.constraint(equalTo: imageOfNft.topAnchor, constant: 23),
            nameOfNft.leadingAnchor.constraint(equalTo: imageOfNft.trailingAnchor, constant: 20),
            
            stackViewOfStars.topAnchor.constraint(equalTo: nameOfNft.bottomAnchor, constant: 4),
            stackViewOfStars.leadingAnchor.constraint(equalTo: imageOfNft.trailingAnchor, constant: 20),
            
            authorOfNft.topAnchor.constraint(equalTo: stackViewOfStars.bottomAnchor, constant: 4),
            authorOfNft.leadingAnchor.constraint(equalTo: imageOfNft.trailingAnchor, constant: 20),
            
            textPriceOfNft.topAnchor.constraint(equalTo: nameOfNft.topAnchor, constant: 10),
            textPriceOfNft.leadingAnchor.constraint(equalTo: nameOfNft.trailingAnchor, constant: 39),
            
            priceOfNft.topAnchor.constraint(equalTo: textPriceOfNft.bottomAnchor, constant: 2),
            priceOfNft.leadingAnchor.constraint(equalTo: nameOfNft.trailingAnchor, constant: 38),
        ])
    }
}
