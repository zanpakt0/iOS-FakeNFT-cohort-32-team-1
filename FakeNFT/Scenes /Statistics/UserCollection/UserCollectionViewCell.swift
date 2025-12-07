import UIKit
import Kingfisher

final class UserCollectionViewCell: UICollectionViewCell {
    
    // MARK: - Callbacks
    var onFavouritesButtonTapped: ((Bool) -> Void)?
    var onCartButtonTapped: ((Bool) -> Void)?
    
    // MARK: - Static properties
    static let reuseIdentifier = "StatisticsTableViewCell"
    
    // MARK: - Private Properties
    private var isFavourite = false
    private var isInCart = false
    
    // MARK: - Views (elements)
    private lazy var nftImageView: UIImageView = {
        let exampleImage = UIImage(systemName: "");
        let nftImageView = UIImageView(image: exampleImage)
        nftImageView.layer.cornerRadius = 12
        nftImageView.layer.masksToBounds = true
        nftImageView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            nftImageView.widthAnchor.constraint(equalToConstant: 108),
            nftImageView.heightAnchor.constraint(equalToConstant: 108)
        ])
        
        return nftImageView
    }()
    private lazy var favouritesButton: UIButton = {
        let favouritesButton = UIButton(type: .system)
        favouritesButton.setImage(UIImage(systemName: "heart.fill"), for: .normal)
        favouritesButton.addTarget(self, action: #selector(favouritesButtonClicked), for: .touchUpInside)
        favouritesButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            favouritesButton.widthAnchor.constraint(equalToConstant: 40),
            favouritesButton.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        return favouritesButton
    }()
    private lazy var viewWithAdditionalInfo: UIView = {
        let viewWithAdditionalInfo = UIView()
        viewWithAdditionalInfo.backgroundColor = .forViewBackground
        viewWithAdditionalInfo.translatesAutoresizingMaskIntoConstraints = false
        
        return viewWithAdditionalInfo
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
        stackViewOfStars.spacing = 2
        
        return stackViewOfStars
    }()
    private lazy var nftNameLabel: UILabel = {
        let nftNameLabel = UILabel()
        nftNameLabel.font = .bodyBold
        nftNameLabel.textColor = .segmentActive
        nftNameLabel.numberOfLines = 1
        nftNameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            nftNameLabel.widthAnchor.constraint(lessThanOrEqualToConstant: 68),
            nftNameLabel.heightAnchor.constraint(equalToConstant: 22)
        ])
        
        return nftNameLabel
    }()
    private lazy var nftPriceLabel: UILabel = {
        let nftPriceLabel = UILabel()
        nftPriceLabel.font = .caption3
        nftPriceLabel.textColor = .segmentActive
        nftPriceLabel.numberOfLines = 1
        nftPriceLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            nftPriceLabel.widthAnchor.constraint(lessThanOrEqualToConstant: 68),
            nftPriceLabel.heightAnchor.constraint(equalToConstant: 12)
        ])
        
        return nftPriceLabel
    }()
    private lazy var cartButton: UIButton = {
        let cartButton = UIButton(type: .system)
        cartButton.setImage(UIImage(resource: .addCartIcon), for: .normal)
        cartButton.translatesAutoresizingMaskIntoConstraints = false
        cartButton.addTarget(self, action: #selector(cartButtonClicked), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            cartButton.widthAnchor.constraint(equalToConstant: 40),
            cartButton.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        return cartButton
    }()
    
    // MARK: - Initializers
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = .forViewBackground
        
        addSubviews()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(nftData: NftCellViewData) {
        let processor = RoundCornerImageProcessor(cornerRadius: 12)
        guard let url = nftData.nft.image else  {
            return
        }
        self.nftImageView.kf.setImage(with: url,
                                             placeholder: nil,
                                             options: [.processor(processor)])
        
        visualizeFavouritesAndCartButtons(isFavourtie: nftData.isFavourite, isInChart: nftData.isInChart)
        visualizeStars(rating: nftData.nft.rating)
        nftNameLabel.text = nftData.nft.name
        nftPriceLabel.text = replaceDotsWithCommas(price: nftData.nft.price)
    }
    
    // MARK: - Private Methods
    @objc private func favouritesButtonClicked() {
        onFavouritesButtonTapped?(isFavourite)
    }
    
    @objc private func cartButtonClicked() {
        onCartButtonTapped?(isInCart)
    }
    
    private func addSubviews() {
        [stackViewOfStars, nftNameLabel, nftPriceLabel, cartButton].forEach {
            viewWithAdditionalInfo.addSubview($0)
        }
        
        [nftImageView, favouritesButton, viewWithAdditionalInfo].forEach {
            contentView.addSubview($0)
        }
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            nftImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            nftImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            
            favouritesButton.topAnchor.constraint(equalTo: nftImageView.topAnchor),
            favouritesButton.trailingAnchor.constraint(equalTo: nftImageView.trailingAnchor),
            
            viewWithAdditionalInfo.leadingAnchor.constraint(equalTo: nftImageView.leadingAnchor),
            viewWithAdditionalInfo.topAnchor.constraint(equalTo: nftImageView.bottomAnchor, constant: 8),
            viewWithAdditionalInfo.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20),
            
            stackViewOfStars.topAnchor.constraint(equalTo: viewWithAdditionalInfo.topAnchor),
            stackViewOfStars.leadingAnchor.constraint(equalTo: nftImageView.leadingAnchor),
            
            nftNameLabel.leadingAnchor.constraint(equalTo: nftImageView.leadingAnchor),
            nftNameLabel.topAnchor.constraint(equalTo: stackViewOfStars.bottomAnchor, constant: 5),
            
            nftPriceLabel.leadingAnchor.constraint(equalTo: nftImageView.leadingAnchor),
            nftPriceLabel.topAnchor.constraint(equalTo: nftNameLabel.bottomAnchor, constant: 4),
            
            cartButton.topAnchor.constraint(equalTo: viewWithAdditionalInfo.topAnchor, constant: 16),
            cartButton.trailingAnchor.constraint(equalTo: nftImageView.trailingAnchor)
        ])
    }
    
    private func visualizeFavouritesAndCartButtons(isFavourtie: Bool, isInChart: Bool) {
        isFavourite = isFavourtie
        favouritesButton.tintColor = isFavourite ? .redForFavouritesButton : .background
        
        isInCart = isInChart
        let cartImage = isInCart ? UIImage(resource: .deleteCartIcon) : UIImage(resource: .addCartIcon)
        cartButton.setImage(cartImage, for: .normal)
        cartButton.tintColor = .segmentActive
    }

    
    private func replaceDotsWithCommas(price: Decimal) -> String {
        let string = "\(price)"
        return "\(string.replacingOccurrences(of: ".", with: ",")) ETH"
    }
    
    private func visualizeStars(rating: Int) {
        let stars = [firstStar, secondStar, thirdStar, fourthStar, fifthStar]
        for (index, star) in stars.enumerated() {
            star.tintColor = index < rating ? .yellowForStars : .segmentInactive
        }
    }
    
    private func createDefaultStar() -> UIImageView {
        let exampleImage = UIImage(systemName: "star.fill")
        let star = UIImageView(image: exampleImage)
        star.translatesAutoresizingMaskIntoConstraints = false
        star.tintColor = .segmentInactive
        
        NSLayoutConstraint.activate([
            star.widthAnchor.constraint(equalToConstant: 12),
            star.heightAnchor.constraint(equalToConstant: 12)
        ])
        
        return star
    }
}
