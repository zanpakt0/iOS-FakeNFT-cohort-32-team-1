import UIKit
import Combine

final class NFTCollectionViewController: UIViewController {
    
    private var collectionViewHeightConstraint: NSLayoutConstraint?
    
    private let viewModel: NFTCollectionViewModel
    private var subscribes = Set<AnyCancellable>()
    
    private var favorites: [String] = []
    private var itemsInCart: [String] = []
    
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
        layout.minimumInteritemSpacing = 10
        layout.minimumLineSpacing = 8
        
        let collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collection.translatesAutoresizingMaskIntoConstraints = false
        collection.backgroundColor = .clear
        collection.delegate = self
        collection.dataSource = self
        collection.isScrollEnabled = false
        return collection
    }()
    
    private lazy var loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView()
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()

    //MARK: - Init
    init(catalogItem: Catalog) {
        self.viewModel = NFTCollectionViewModel(
            provider: NftServiceImpl(
                networkClient: DefaultNetworkClient(),
                storage: NftStorageImpl()
            ),
            nftIds: catalogItem.nfts
        )
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .background
        updateCollectionViewHeight()
        setupUI()
        bindViewModel()
    }
    
    //MARK: - Setup Methods
    private func setupUI() {
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
    
    private func updateCollectionViewHeight() {
        collectionView.reloadData()
        
        let itemsPerRow = 3
        let itemHeight: CGFloat = 192
        let verticalSpacing: CGFloat = 8

        let itemsCount = mockNFTs.count
        let rows = Int(ceil(Double(itemsCount) / Double(itemsPerRow)))
        let totalHeight = CGFloat(rows) * itemHeight + CGFloat(max(0, rows - 1)) * verticalSpacing

        if collectionViewHeightConstraint == nil {
            collectionViewHeightConstraint = collectionView.heightAnchor.constraint(equalToConstant: totalHeight)
            collectionViewHeightConstraint?.isActive = true
        } else {
            collectionViewHeightConstraint?.constant = totalHeight
        }

        // Обновим layout
        collectionView.layoutIfNeeded()
        contentView.layoutIfNeeded()
    }
    
    private func setupLoadingIndicator() {
        view.addSubview(loadingIndicator)
        loadingIndicator.constraintCenters(to: view)
    }
    
    //MARK: - Actions
    @objc private func backButtonAction() {
        dismiss(animated: true)
    }
    
    //MARK: - Bind
    func bindViewModel() {
        viewModel.$nfts
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] _ in
                self?.collectionView.reloadData()
            })
            .store(in: &subscribes)
        
        viewModel.$isLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                guard let self else { return }
                isLoading ? self.loadingIndicator.startAnimating() : self.loadingIndicator.stopAnimating()
            }
            .store(in: &subscribes)
    }
}

extension NFTCollectionViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        mockNFTs.count
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        let cell: NFTCell = collectionView.dequeueReusableCell(indexPath: indexPath)
        let nft = mockNFTs[indexPath.item]
        cell.delegate = self
            cell.configure(
                nft: nft,
                imageURL: nft.images[0],
                inCart: itemsInCart.contains(nft.id),
                isLiked: favorites.contains(nft.id)
            )
        return cell
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        CGSize(width: 108, height: 192)
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumInteritemSpacingForSectionAt section: Int
    ) -> CGFloat {
        10
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumLineSpacingForSectionAt section: Int
    ) -> CGFloat {
        8
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAt section: Int
    ) -> UIEdgeInsets {
        UIEdgeInsets(top: 0, left: 0, bottom: 16, right: 0)
    }
}

extension NFTCollectionViewController: NFTCellDelegate {
    func addInCart(id: String, in cell: NFTCell) {
        self.itemsInCart.append(id)
        print(itemsInCart)
    }
    
    func deleteFromCart(id: String, in cell: NFTCell) {
        if let index = itemsInCart.firstIndex(of: id) {
            self.itemsInCart.remove(at: index)
        }
        print(itemsInCart)
    }
    
    func addLike(id: String, in cell: NFTCell) {
        self.favorites.append(id)
        print(favorites)
    }
    
    func deleteLike(id: String, in cell: NFTCell) {
        if let index = favorites.firstIndex(of: id) {
            self.favorites.remove(at: index)
        }
        print(favorites)
    }
}
