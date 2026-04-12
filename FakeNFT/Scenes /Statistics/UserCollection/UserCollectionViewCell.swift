import UIKit
import Kingfisher

// MARK: - Need enums
enum UserCollectionViewCellLayout {
    static let nftImageCornerRadius: CGFloat = 12
    static let nftImageSizes: CGFloat = 108
    
    static let sizesOfButtons: CGFloat = 40
    
    static let spacingInStackViewOfStars: CGFloat = 2
    static let stackViewOfStarsTop: CGFloat = 8
    
    static let sizeOfStars: CGFloat = 12
    
    static let numberOfLinesInLabels: Int = 1
    static let maximumWidthOfLabels: CGFloat = 68
    
    static let nftNameLabelHeight: CGFloat = 22
    static let nftNameLabelTop: CGFloat = 5
    
    static let nftPriceLabelHeight: CGFloat = 12
    static let nftPriceLabelTop: CGFloat = 4
    
    static let cartButtonTop: CGFloat = 24
}

final class UserCollectionViewCell: UICollectionViewCell {
    
    // MARK: - Callbacks
    var onFavouritesButtonTapped: ((Bool) -> Void)?
    var onCartButtonTapped: ((Bool) -> Void)?
    
    // MARK: - Static properties
    static let reuseIdentifier = "UserCollectionViewCell"
    
    // MARK: - Private Properties
    private var isFavourite = false
    private var isInCart = false
    
    // MARK: - Views (elements)
    private let nftImageView: UIImageView = {
        let exampleImage = UIImage(systemName: "");
        let nftImageView = UIImageView(image: exampleImage)
        nftImageView.layer.cornerRadius = UserCollectionViewCellLayout.nftImageCornerRadius
        nftImageView.layer.masksToBounds = true
        nftImageView.translatesAutoresizingMaskIntoConstraints = false
        
        return nftImageView
    }()
    private let favouritesButton: UIButton = {
        let favouritesButton = UIButton(type: .system)
        favouritesButton.setImage(UIImage(systemName: "heart.fill"), for: .normal)
        favouritesButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            favouritesButton.widthAnchor.constraint(equalToConstant: UserCollectionViewCellLayout.sizesOfButtons),
            favouritesButton.heightAnchor.constraint(equalToConstant: UserCollectionViewCellLayout.sizesOfButtons)
        ])
        
        return favouritesButton
    }()
    private lazy var firstStar: UIImageView = createDefaultStar()
    private lazy var secondStar: UIImageView = createDefaultStar()
    private lazy var thirdStar: UIImageView = createDefaultStar()
    private lazy var fourthStar: UIImageView = createDefaultStar()
    private lazy var fifthStar: UIImageView = createDefaultStar()
    private lazy var stackViewOfStars: UIStackView = {
        let stackViewOfStars = UIStackView(arrangedSubviews: [firstStar, secondStar, thirdStar, fourthStar, fifthStar])
        stackViewOfStars.axis = .horizontal
        stackViewOfStars.translatesAutoresizingMaskIntoConstraints = false
        stackViewOfStars.spacing = UserCollectionViewCellLayout.spacingInStackViewOfStars
        
        return stackViewOfStars
    }()
    private let nftNameLabel: UILabel = {
        let nftNameLabel = UILabel()
        nftNameLabel.font = .bodyBold
        nftNameLabel.textColor = .segmentActive
        nftNameLabel.numberOfLines = UserCollectionViewCellLayout.numberOfLinesInLabels
        nftNameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            nftNameLabel.widthAnchor.constraint(lessThanOrEqualToConstant: UserCollectionViewCellLayout.maximumWidthOfLabels),
            nftNameLabel.heightAnchor.constraint(equalToConstant: UserCollectionViewCellLayout.nftNameLabelHeight)
        ])
        
        return nftNameLabel
    }()
    private let nftPriceLabel: UILabel = {
        let nftPriceLabel = UILabel()
        nftPriceLabel.font = .caption4
        nftPriceLabel.textColor = .segmentActive
        nftPriceLabel.numberOfLines = UserCollectionViewCellLayout.numberOfLinesInLabels
        nftPriceLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            nftPriceLabel.widthAnchor.constraint(lessThanOrEqualToConstant: UserCollectionViewCellLayout.maximumWidthOfLabels),
            nftPriceLabel.heightAnchor.constraint(equalToConstant: UserCollectionViewCellLayout.nftPriceLabelHeight)
        ])
        
        return nftPriceLabel
    }()
    private let cartButton: UIButton = {
        let cartButton = UIButton(type: .system)
        cartButton.setImage(UIImage(resource: .addCartIcon), for: .normal)
        cartButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            cartButton.widthAnchor.constraint(equalToConstant: UserCollectionViewCellLayout.sizesOfButtons),
            cartButton.heightAnchor.constraint(equalToConstant: UserCollectionViewCellLayout.sizesOfButtons)
        ])
        
        return cartButton
    }()
    
    // MARK: - Initializers
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = .forViewBackground
        
        addTargetsForButtons()
        addSubviews()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        nil
    }
    
    // MARK: - Public Methods
    func configure(nftData: NftCellViewData) {
        guard let url = nftData.nft.image else  {
            return
        }
        self.nftImageView.kf.setImage(with: url,
                                      placeholder: nil,
                                      options: [.processor(Constants.processorWithTwelveCornerRadius)])
        
        visualizeFavouritesAndCartButtons(isFavourtie: nftData.isFavourite, isInCart: nftData.isInCart)
        
        let stars = [firstStar, secondStar, thirdStar, fourthStar, fifthStar]
        visualizeStars(rating: nftData.nft.rating, stars: stars)
        
        self.nftNameLabel.text = nftData.nft.name
        self.nftPriceLabel.text = Constants.replaceDotsWithCommas(price: nftData.nft.price)
    }
    
    // MARK: - Private Methods
    @objc private func favouritesButtonClicked() {
        onFavouritesButtonTapped?(isFavourite)
    }
    
    @objc private func cartButtonClicked() {
        onCartButtonTapped?(isInCart)
    }
    
    private func addTargetsForButtons() {
        favouritesButton.addTarget(self, action: #selector(favouritesButtonClicked), for: .touchUpInside)
        cartButton.addTarget(self, action: #selector(cartButtonClicked), for: .touchUpInside)
    }
    
    private func addSubviews() {
        [nftImageView, favouritesButton, stackViewOfStars, nftNameLabel, nftPriceLabel, cartButton].forEach {
            contentView.addSubview($0)
        }
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            nftImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            nftImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            nftImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            nftImageView.heightAnchor.constraint(equalToConstant: UserCollectionViewCellLayout.nftImageSizes),
            
            favouritesButton.topAnchor.constraint(equalTo: nftImageView.topAnchor),
            favouritesButton.trailingAnchor.constraint(equalTo: nftImageView.trailingAnchor),
            
            stackViewOfStars.topAnchor.constraint(equalTo: nftImageView.bottomAnchor, constant: UserCollectionViewCellLayout.stackViewOfStarsTop),
            stackViewOfStars.leadingAnchor.constraint(equalTo: nftImageView.leadingAnchor),
            
            nftNameLabel.leadingAnchor.constraint(equalTo: nftImageView.leadingAnchor),
            nftNameLabel.topAnchor.constraint(equalTo: stackViewOfStars.bottomAnchor, constant: UserCollectionViewCellLayout.nftNameLabelTop),
            
            nftPriceLabel.leadingAnchor.constraint(equalTo: nftImageView.leadingAnchor),
            nftPriceLabel.topAnchor.constraint(equalTo: nftNameLabel.bottomAnchor, constant: UserCollectionViewCellLayout.nftPriceLabelTop),
            
            cartButton.topAnchor.constraint(equalTo: nftImageView.bottomAnchor, constant: UserCollectionViewCellLayout.cartButtonTop),
            cartButton.trailingAnchor.constraint(equalTo: nftImageView.trailingAnchor)
        ])
    }
    
    private func visualizeFavouritesAndCartButtons(isFavourtie: Bool, isInCart: Bool) {
        self.isFavourite = isFavourtie
        favouritesButton.tintColor = isFavourite ? .redForFavouritesButton : .background
        
        self.isInCart = isInCart
        let cartImage = isInCart ? UIImage(resource: .deleteCartIcon) : UIImage(resource: .addCartIcon)
        cartButton.setImage(cartImage, for: .normal)
        cartButton.tintColor = .segmentActive
    }
}
