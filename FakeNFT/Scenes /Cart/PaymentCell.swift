import UIKit

final class PaymentCell: UICollectionViewCell {
    
    static let reuseIdentifier = "PaymentCell"
    
    private let iconView = UIImageView()
    private let titleLabel = UILabel()
    private let tickerLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) { nil }
    
    private func setupUI() {
        contentView.layer.cornerRadius = 12
        contentView.layer.borderWidth = 0
        contentView.backgroundColor = .segmentPayCellBackground
        
        titleLabel.font = .systemFont(ofSize: 13, weight: .regular)
        tickerLabel.font = .systemFont(ofSize: 13, weight: .regular)
        titleLabel.textColor = .segmentButtonBackground
        tickerLabel.textColor = .greenUniversal
        
        let textStack = UIStackView(arrangedSubviews: [titleLabel, tickerLabel])
        textStack.axis = .vertical
        textStack.spacing = 2
        textStack.alignment = .leading
        
        let mainStack = UIStackView(arrangedSubviews: [iconView, textStack])
        mainStack.axis = .horizontal
        mainStack.spacing = 12
        mainStack.alignment = .center
        
        contentView.addSubview(mainStack)
        mainStack.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            mainStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            mainStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            mainStack.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
        
        iconView.widthAnchor.constraint(equalToConstant: 36).isActive = true
        iconView.heightAnchor.constraint(equalToConstant: 36).isActive = true
        iconView.contentMode = .scaleAspectFit
    }
    
    func configure(with item: CryptoPayment) {
        iconView.image = UIImage(named: item.iconName)
        iconView.contentMode = .scaleAspectFit
        iconView.widthAnchor.constraint(equalToConstant: 36).isActive = true
        iconView.heightAnchor.constraint(equalToConstant: 36).isActive = true
        
        titleLabel.text = item.title
        tickerLabel.text = item.ticker
    }
    
    override var isSelected: Bool {
        didSet {
            contentView.layer.borderWidth = isSelected ? 1 : 0
            contentView.layer.borderColor = isSelected ?  UIColor.segmentButtonBackground.cgColor : UIColor.segmentPayCellBackground.cgColor
        }
    }
}

