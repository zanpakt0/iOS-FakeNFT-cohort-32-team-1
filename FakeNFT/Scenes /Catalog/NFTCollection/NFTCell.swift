import UIKit

protocol NFTCellDelegate: AnyObject {
    func addInCart(id: String, in cell: NFTCell)
    func deleteFromCart(id: String, in cell: NFTCell)
    func addLike(id: String, in cell: NFTCell)
    func deleteLike(id: String, in cell: NFTCell)
}

final class NFTCell: UICollectionViewCell, ReuseIdentifying {
    private enum NFTCellLayout {
        static let cornerRadius: CGFloat = 12

        static let imageHeight: CGFloat = 108
        static let imageWidth: CGFloat = 108

        static let likeButtonWidth: CGFloat = 42
        static let likeButtonHeight: CGFloat = 42
        static let likeButtonTrailingOffset: CGFloat = 0

        static let starSize: CGFloat = 12
        static let starSpacing: CGFloat = 2
        static let ratingTopSpacing: CGFloat = 8
        static let ratingHeight: CGFloat = 12
        static let ratingWidth: CGFloat = 68

        static let labelTopSpacing: CGFloat = 4
        static let priceTopSpacing: CGFloat = 2
        static let labelToCartSpacing: CGFloat = -8

        static let bottomPadding: CGFloat = -20

        static let cartButtonWidth: CGFloat = 40
        static let cartButtonHeight: CGFloat = 40
        static let cartButtonTrailing: CGFloat = -4
    }
    
    weak var delegate: NFTCellDelegate?
    
    private var inCart: Bool = false
    private var isLiked: Bool = false
    private var nftId: String?
    
    //MARK: - UI
    private lazy var nftImageView: UIImageView = {
        let image = UIImageView()
        image.layer.cornerRadius = NFTCellLayout.cornerRadius
        image.layer.masksToBounds = true
        image.translatesAutoresizingMaskIntoConstraints = false
        image.backgroundColor = .background
        image.contentMode = .scaleAspectFill
        return image
    }()
    
    private let ratingView = SimpleRatingView(starSize: NFTCellLayout.starSize, spacing: NFTCellLayout.starSpacing)
    
    private lazy var nftLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.bodyBold
        label.textColor = .textPrimary
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var nftPriceLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.caption3
        label.textColor = .textPrimary
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var nftCartButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(resource: .addToCart), for: .normal)
        button.tintColor = .segmentActive
        button.imageView?.contentMode = .scaleAspectFit
        button.addTarget(self, action: #selector(nftCartButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var nftLikeButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(resource: .likeButtonNoActive), for: .normal)
        button.tintColor = .segmentActive
        button.imageView?.contentMode = .scaleAspectFit
        button.addTarget(self, action: #selector(nftLikeButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    
    //MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = .background
        setupUI()
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Setup UI
    private func setupUI() {
        contentView.addSubview(nftImageView)
        contentView.addSubview(nftLikeButton)
        contentView.addSubview(ratingView)
        contentView.addSubview(nftLabel)
        contentView.addSubview(nftPriceLabel)
        contentView.addSubview(nftCartButton)
        
        NSLayoutConstraint.activate([
            // nftImageView
            nftImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            nftImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            nftImageView.heightAnchor.constraint(equalToConstant: NFTCellLayout.imageHeight),
            nftImageView.widthAnchor.constraint(equalToConstant: NFTCellLayout.imageWidth),
            
            // nftLikeButton
            nftLikeButton.topAnchor.constraint(equalTo: nftImageView.topAnchor),
            nftLikeButton.trailingAnchor.constraint(equalTo: nftImageView.trailingAnchor),
            nftLikeButton.heightAnchor.constraint(equalToConstant: NFTCellLayout.likeButtonHeight),
            nftLikeButton.widthAnchor.constraint(equalToConstant: NFTCellLayout.likeButtonWidth),
            
            // ratingView
            ratingView.topAnchor.constraint(equalTo: nftImageView.bottomAnchor, constant: NFTCellLayout.ratingTopSpacing),
            ratingView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            ratingView.heightAnchor.constraint(equalToConstant: NFTCellLayout.ratingHeight),
            ratingView.widthAnchor.constraint(equalToConstant: NFTCellLayout.ratingWidth),
            ratingView.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor),
            
            // nftLabel
            nftLabel.topAnchor.constraint(equalTo: ratingView.bottomAnchor, constant: NFTCellLayout.labelTopSpacing),
            nftLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            nftLabel.trailingAnchor.constraint(lessThanOrEqualTo: nftCartButton.leadingAnchor, constant: NFTCellLayout.labelToCartSpacing),
            
            // nftPriceLabel
            nftPriceLabel.topAnchor.constraint(equalTo: nftLabel.bottomAnchor, constant: NFTCellLayout.priceTopSpacing),
            nftPriceLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            nftPriceLabel.trailingAnchor.constraint(lessThanOrEqualTo: nftCartButton.leadingAnchor, constant: NFTCellLayout.labelToCartSpacing),
            nftPriceLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: NFTCellLayout.bottomPadding),
            
            // nftCartButton
            nftCartButton.topAnchor.constraint(equalTo: nftLabel.topAnchor),
            nftCartButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: NFTCellLayout.cartButtonTrailing),
            nftCartButton.widthAnchor.constraint(equalToConstant: NFTCellLayout.cartButtonWidth),
            nftCartButton.heightAnchor.constraint(equalToConstant: NFTCellLayout.cartButtonHeight)
        ])
    }
    
    //MARK: - Methods
    func configure(nft: Nft, imageURL: URL, inCart: Bool, isLiked: Bool) {
        self.nftId = nft.id
        
        nftImageView.kf.setImage(with: imageURL)
        
        let firstWord = nft.name.split(separator: " ").first.map(String.init) ?? nft.name
        nftLabel.text = firstWord
        
        ratingView.setRating(nft.rating)
        nftPriceLabel.text = "\(nft.price) ETH"
        self.inCart = inCart
        nftCartButton.setImage(UIImage(resource: inCart ? .deleteFromCart : .addToCart), for: .normal)
        self.isLiked = isLiked
        nftLikeButton.setImage(UIImage(resource: isLiked ? .likeButtonActive : .likeButtonNoActive), for: .normal)
    }
    
    //MARK: - Actions
    @objc private func nftCartButtonTapped() {
        guard let nftId = nftId else {
            assertionFailure("nftId not found")
            return
        }
        
        inCart.toggle()
        nftCartButton.setImage(UIImage(resource: inCart ? .deleteFromCart : .addToCart), for: .normal)
        
        if inCart {
            delegate?.addInCart(id: nftId, in: self)
        } else {
            delegate?.deleteFromCart(id: nftId, in: self)
        }
    }
    
    @objc private func nftLikeButtonTapped() {
        guard let nftId = nftId else {
            assertionFailure("nftId not found")
            return
        }
        
        isLiked.toggle()
        nftLikeButton.setImage(UIImage(resource: isLiked ? .likeButtonActive : .likeButtonNoActive), for: .normal)
        
        if isLiked {
            delegate?.addLike(id: nftId, in: self)
        } else {
            delegate?.deleteLike(id: nftId, in: self)
        }
    }
}
