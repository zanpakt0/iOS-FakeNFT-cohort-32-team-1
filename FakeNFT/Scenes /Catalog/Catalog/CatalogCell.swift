import UIKit
import Kingfisher

final class CatalogCell: UITableViewCell, ReuseIdentifying {
    
    //MARK: - UI
    private lazy var catalogImage: UIImageView = {
        let image = UIImageView()
        image.layer.cornerRadius = 12
        image.layer.masksToBounds = true
        image.translatesAutoresizingMaskIntoConstraints = false
        image.backgroundColor = .background
        image.contentMode = .scaleAspectFill
        return image
    }()
    
    private lazy var catalogLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.bodyBold
        label.textColor = .textPrimary
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    //MARK: - Init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = .background
        setupImage()
        setupLabel()
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Setup UI
    private func setupImage() {
        contentView.addSubview(catalogImage)
        
        NSLayoutConstraint.activate([
            catalogImage.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            catalogImage.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            catalogImage.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            catalogImage.heightAnchor.constraint(equalToConstant: 140)
        ])
    }
    
    private func setupLabel() {
        contentView.addSubview(catalogLabel)
        
        NSLayoutConstraint.activate([
            catalogLabel.topAnchor.constraint(equalTo: catalogImage.bottomAnchor, constant: 4),
            catalogLabel.leadingAnchor.constraint(equalTo: catalogImage.leadingAnchor),
            catalogLabel.trailingAnchor.constraint(equalTo: catalogImage.trailingAnchor),
            catalogLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -1)
        ])
    }
    
    //MARK: - Methods
    override func prepareForReuse() {
        super.prepareForReuse()
        catalogImage.image = nil
        catalogLabel.text = nil
    }
    
    func configure(imageURL: URL, text: String, numberOfNfts: Int) {
        catalogImage.kf.setImage(with: imageURL)
        catalogLabel.text = "\(text.capitalized) (\(numberOfNfts))"
    }
}
