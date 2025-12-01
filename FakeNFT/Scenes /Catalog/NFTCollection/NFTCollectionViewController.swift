import UIKit

final class NFTCollectionViewController: UIViewController {
    //MARK: - UI Elements
    private lazy var backButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(resource: .collectionBackButton), for: .normal)
        button.addTarget(self, action: #selector(backButtonAction), for: .touchUpInside)
        return button
    }()
    
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.alwaysBounceVertical = true
        return scrollView
    }()
    
    private lazy var contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var coverImage: UIImageView =  {
        let image = UIImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        image.image = UIImage(named: "Peach")
        image.layer.cornerRadius = 12
        image.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        image.layer.masksToBounds = true
        return image
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .headline3
        label.textAlignment = .left
        label.text = "Peach"
        return label
    }()
    
    private lazy var webLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .caption1
        label.textAlignment = .left
        label.text = "John Doe"
        label.textColor = .blue
        return label
    }()
    
    private lazy var authorLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .caption2
        label.textAlignment = .left
        label.text = NSLocalizedString("nftCollection.authorLabel.text", comment: "Author of collection:")
        return label
    }()
    
    private lazy var authorStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [authorLabel, webLabel])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.spacing = 4
        return stack
    }()
    
    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .caption2
        label.numberOfLines = 0
        label.text = "Персиковый — как облака над закатным солнцем в океане. В этой коллекции совмещены трогательная нежность и живая игривость сказочных зефирных зверей."
        return label
    }()
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 8
        
        let collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collection.translatesAutoresizingMaskIntoConstraints = false
        collection.backgroundColor = .clear
        collection.delegate = self
        collection.dataSource = self
        return collection
    }()
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .background
        setupUI()
    }
    
    //MARK: - Setup Methods
    private func setupUI(){
        setupScrollView()
        setupUIInsideContent()
        setupBackButton()
    }
    
    private func setupBackButton() {
        view.addSubview(backButton)
        
        NSLayoutConstraint.activate([
            backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 11),
            backButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 9),
            backButton.heightAnchor.constraint(equalToConstant: 24),
            backButton.widthAnchor.constraint(equalToConstant: 24)
        ])
    }
    
    private func setupScrollView() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        scrollView.contentInsetAdjustmentBehavior = .never
        
        NSLayoutConstraint.activate([
            // scrollView
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            // contentView
            contentView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor)
        ])
    }
    
    private func setupUIInsideContent() {
        contentView.addSubview(coverImage)
        contentView.addSubview(titleLabel)
        contentView.addSubview(authorStack)
        contentView.addSubview(descriptionLabel)
        contentView.addSubview(collectionView)
        
        collectionView.register(NFTCell.self)
        
        NSLayoutConstraint.activate([
            // coverImage
            coverImage.topAnchor.constraint(equalTo: contentView.topAnchor),
            coverImage.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            coverImage.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            coverImage.heightAnchor.constraint(equalToConstant: 310),
            
            // title
            titleLabel.topAnchor.constraint(equalTo: coverImage.bottomAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            // authorStack
            authorStack.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            authorStack.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            
            // description
            descriptionLabel.topAnchor.constraint(equalTo: authorStack.bottomAnchor, constant: 4),
            descriptionLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            descriptionLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            
            // collectionView
            collectionView.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 24),
            collectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            collectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            collectionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16)
        ])
    }
    
    //MARK: - Actions
    @objc private func backButtonAction() {
        dismiss(animated: true)
    }
}

extension NFTCollectionViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: NFTCell = collectionView.dequeueReusableCell(indexPath: indexPath)
        return cell
    }
    
}
