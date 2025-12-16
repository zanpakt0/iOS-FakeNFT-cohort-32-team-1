import UIKit
import Kingfisher

protocol CartTableViewCellDelegate: AnyObject {
    func cartCell(_ cell: CartTableViewCell, didChangeRating rating: Int)
    func cartCellDidTapDelete(_ cell: CartTableViewCell)
}

final class CartTableViewCell: UITableViewCell {
    
    static let reuseIdentifier = "CartTableViewCell"
    
    private let nftImageView = UIImageView()
    private let titleLabel = UILabel()
    private let priceTitleLabel = UILabel()
    private let priceValueLabel = UILabel()
    private let ratingStackView = UIStackView()
    private var starButtons: [UIButton] = []
    private let deleteButton = UIButton(type: .system)
    
    private var rating: Int = 0 {
        didSet { updateStars() }
    }
    
    private var currentImageUrl: URL?
    
    weak var delegate: CartTableViewCellDelegate?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        nftImageView.image = nil
        rating = 0
        currentImageUrl = nil
    }
    
    func configure(with item: NFTUIItem) {
        titleLabel.text = item.title
        priceValueLabel.text = "\(item.price) ETH"
        rating = item.rating
        
        guard let url = item.imageUrl else { return }
        currentImageUrl = url
        nftImageView.kf.setImage(with: url, placeholder: nil, options: nil, progressBlock: nil) { [weak self] result in
            guard let self = self else { return }
            if self.currentImageUrl == url {
                switch result {
                case .success(let value):
                    self.nftImageView.image = value.image
                case .failure(let error):
                    print("❌ Failed to load image: \(error)")
                }
            }
        }
    }
    
    private func setupUI() {
        selectionStyle = .none
        contentView.addSubview(nftImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(ratingStackView)
        contentView.addSubview(priceTitleLabel)
        contentView.addSubview(priceValueLabel)
        contentView.addSubview(deleteButton)
        
        nftImageView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        ratingStackView.translatesAutoresizingMaskIntoConstraints = false
        priceTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        priceValueLabel.translatesAutoresizingMaskIntoConstraints = false
        deleteButton.translatesAutoresizingMaskIntoConstraints = false
        
        nftImageView.contentMode = .scaleAspectFill
        nftImageView.layer.cornerRadius = 12
        nftImageView.clipsToBounds = true
        
        titleLabel.font = .boldSystemFont(ofSize: 16)
        
        priceTitleLabel.text = NSLocalizedString("price", comment: "")
        priceTitleLabel.font = UIFont.systemFont(ofSize: 13)
        priceTitleLabel.textColor = .secondaryLabel
        
        priceValueLabel.font = UIFont.boldSystemFont(ofSize: 17)
        priceValueLabel.textColor = .label
        
        ratingStackView.axis = .horizontal
        ratingStackView.spacing = 2
        ratingStackView.distribution = .fillEqually
        
        for i in 1...5 {
            let button = UIButton(type: .custom)
            button.tag = i
            button.setImage(UIImage(named: "star_empty"), for: .normal)
            button.setImage(UIImage(named: "star_filled"), for: .selected)
            button.addTarget(self, action: #selector(starTapped(_:)), for: .touchUpInside)
            starButtons.append(button)
            ratingStackView.addArrangedSubview(button)
        }
        
        deleteButton.setImage(UIImage(resource: .delete), for: .normal)
        deleteButton.tintColor = .segmentButtonBackground
        deleteButton.addTarget(self, action: #selector(deleteTapped), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            nftImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            nftImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            nftImageView.widthAnchor.constraint(equalToConstant: 108),
            nftImageView.heightAnchor.constraint(equalToConstant: 108),
            
            deleteButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            deleteButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            deleteButton.widthAnchor.constraint(equalToConstant: 40),
            deleteButton.heightAnchor.constraint(equalToConstant: 40),
            
            titleLabel.leadingAnchor.constraint(equalTo: nftImageView.trailingAnchor, constant: 12),
            titleLabel.topAnchor.constraint(equalTo: nftImageView.topAnchor, constant: 8),
            titleLabel.trailingAnchor.constraint(equalTo: deleteButton.leadingAnchor, constant: -8),
            
            ratingStackView.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            ratingStackView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            
            priceTitleLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            priceTitleLabel.topAnchor.constraint(equalTo: ratingStackView.bottomAnchor, constant: 6),
            
            priceValueLabel.leadingAnchor.constraint(equalTo: priceTitleLabel.leadingAnchor),
            priceValueLabel.topAnchor.constraint(equalTo: priceTitleLabel.bottomAnchor, constant: 2),
            priceValueLabel.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -12)
        ])
    }
    
    @objc private func starTapped(_ sender: UIButton) {
        rating = sender.tag
        delegate?.cartCell(self, didChangeRating: rating)
    }
    
    @objc private func deleteTapped() {
        delegate?.cartCellDidTapDelete(self)
    }
    
    private func updateStars() {
        for button in starButtons {
            button.isSelected = button.tag <= rating
        }
    }
}
