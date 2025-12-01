import UIKit

protocol NFTCellDelegate: AnyObject {
    func addInCart(id: String, in cell: NFTCell)
    func deleteFromCart(id: String, in cell: NFTCell)
    func addLike(id: String, in cell: NFTCell)
    func deleteLike(id: String, in cell: NFTCell)
}

final class NFTCell: UICollectionViewCell, ReuseIdentifying {
    
    weak var delegate: NFTCellDelegate?
    
    private var inCart: Bool = false
    private var isLiked: Bool = false
    private var nftId: String?
    
    //MARK: - UI
    private lazy var nftImageView: UIImageView = {
        let image = UIImageView()
        image.layer.cornerRadius = 12
        image.layer.masksToBounds = true
        image.translatesAutoresizingMaskIntoConstraints = false
        image.backgroundColor = .background
        image.contentMode = .scaleAspectFill
        return image
    }()
    
    private let ratingView = SimpleRatingView(starSize: 12, spacing: 2)
    
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
            nftImageView.heightAnchor.constraint(equalToConstant: 108),
            nftImageView.widthAnchor.constraint(equalToConstant: 108),
            
            // nftLikeButton
            nftLikeButton.topAnchor.constraint(equalTo: nftImageView.topAnchor),
            nftLikeButton.trailingAnchor.constraint(equalTo: nftImageView.trailingAnchor),
            nftLikeButton.heightAnchor.constraint(equalToConstant: 42),
            nftLikeButton.widthAnchor.constraint(equalToConstant: 42),
            
            // ratingView
            ratingView.topAnchor.constraint(equalTo: nftImageView.bottomAnchor, constant: 8),
            ratingView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            ratingView.heightAnchor.constraint(equalToConstant: 12),
            ratingView.widthAnchor.constraint(equalToConstant: 68),
            ratingView.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor),
            
            // nftLabel
            nftLabel.topAnchor.constraint(equalTo: ratingView.bottomAnchor, constant: 4),
            nftLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            nftLabel.trailingAnchor.constraint(lessThanOrEqualTo: nftCartButton.leadingAnchor, constant: -8),
            
            // nftPriceLabel
            nftPriceLabel.topAnchor.constraint(equalTo: nftLabel.bottomAnchor, constant: 2),
            nftPriceLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            nftPriceLabel.trailingAnchor.constraint(lessThanOrEqualTo: nftCartButton.leadingAnchor, constant: -8),
            nftPriceLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20),
            
            // nftCartButton
            nftCartButton.topAnchor.constraint(equalTo: nftLabel.topAnchor),
            nftCartButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -4),
            nftCartButton.widthAnchor.constraint(equalToConstant: 40),
            nftCartButton.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    //MARK: - Methods
    func configure(nft: NFT, image: UIImage?, inCart: Bool, isLiked: Bool) {
        self.nftId = nft.id
        
        if let image = image {
            nftImageView.image = image
        } else {
            nftImageView.image = UIImage(named: "Peach")
        }
        
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
