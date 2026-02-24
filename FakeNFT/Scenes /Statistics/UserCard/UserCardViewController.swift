import UIKit
import Combine
import Kingfisher

// MARK: - Need enums
enum UserCardViewControllerLayout {
    static let avatarSize: CGFloat = 70
    static let avatarLeading: CGFloat = 16
    static let avatarTop: CGFloat = 20
    static let avatarCornerRadius: CGFloat = 35

    static let userNameLeading: CGFloat = 16
    static let userNameTrailing: CGFloat = -16

    static let descriptionLeading: CGFloat = 16
    static let descriptionTrailing: CGFloat = -18
    static let descriptionTop: CGFloat = 20
    static let descriptionHeight: CGFloat = 72
    static let descriptionNumberOfLines: Int = 4

    static let websiteButtonLeading: CGFloat = 16
    static let websiteButtonTrailing: CGFloat = -16
    static let websiteButtonTop: CGFloat = 28
    static let websiteButtonHeight: CGFloat = 40
    static let websiteBorderWidth: CGFloat = 1
    static let websiteCornerRadius: CGFloat = 16
    
    static let nftButtonTop: CGFloat = 40
    static let nftButtonMinHeight: CGFloat = 54
    static let nftButtonSpaceInStack: CGFloat = 8
    static let nftButtonStackLeading: CGFloat = 16
    static let nftButtonArrowImageTrailing: CGFloat = -16
}

final class UserCardViewController: UIViewController, LoadingView {
    
    // MARK: - Private Properties
    private let viewModel: UserCardViewModel
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Views (elements)
    let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.hidesWhenStopped = true
        indicator.color = .segmentActive
        indicator.translatesAutoresizingMaskIntoConstraints = false
        
        return indicator
    }()
    private let viewWithAllElements: UIView = {
        let viewWithAllElements = UIView()
        viewWithAllElements.backgroundColor = .forViewBackground
        viewWithAllElements.translatesAutoresizingMaskIntoConstraints = false
        
        return viewWithAllElements
    }()
    private let userAvatarImageView: UIImageView = {
        let exampleImage = UIImage(systemName: "person.crop.circle.fill")
        let userAvatarImageView = UIImageView(image: exampleImage)
        userAvatarImageView.clipsToBounds = true
        userAvatarImageView.layer.cornerRadius = UserCardViewControllerLayout.avatarCornerRadius
        userAvatarImageView.translatesAutoresizingMaskIntoConstraints = false
        
        return userAvatarImageView
    }()
    private let userNameLabel: UILabel = {
        let userNameLabel = UILabel()
        userNameLabel.font = .headline3
        userNameLabel.textColor = .segmentActive
        userNameLabel.backgroundColor = .forViewBackground
        userNameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        return userNameLabel
    }()
    private let userDescriptionLabel: UILabel = {
        let userDescriptionLabel = UILabel()
        userDescriptionLabel.font = .caption2
        userDescriptionLabel.textColor = .segmentActive
        userDescriptionLabel.backgroundColor = .forViewBackground
        userDescriptionLabel.numberOfLines = UserCardViewControllerLayout.descriptionNumberOfLines
        userDescriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        
        return userDescriptionLabel
    }()
    private let goToUserWebsiteButton: UIButton = {
        let goToUserWebsiteButton = UIButton(type: .custom)
        let titleOfGoToUserWebsiteButton = NSLocalizedString("userCard.openWebsiteButton", comment: "")
        
        goToUserWebsiteButton.setTitle(titleOfGoToUserWebsiteButton, for: .normal)
        goToUserWebsiteButton.titleLabel?.font = .caption1
        goToUserWebsiteButton.setTitleColor(.segmentActive, for: .normal)
        goToUserWebsiteButton.contentHorizontalAlignment = .center
        goToUserWebsiteButton.contentVerticalAlignment = .center
        
        goToUserWebsiteButton.layer.borderWidth = UserCardViewControllerLayout.websiteBorderWidth
        goToUserWebsiteButton.layer.borderColor = UIColor.segmentActive.cgColor
        
        goToUserWebsiteButton.layer.cornerRadius = UserCardViewControllerLayout.websiteCornerRadius
        goToUserWebsiteButton.translatesAutoresizingMaskIntoConstraints = false
        
        return goToUserWebsiteButton
    }()
    private let countOfNftsLabel: UILabel = UILabel()
    private lazy var nftCollectionButton: UIButton = {
        let nftCollectionButton = UIButton(type: .system)
        let titleOfNftCollection = NSLocalizedString("userCard.collectionButton", comment: "")
        
        let leftLabel = UILabel()
        leftLabel.text = titleOfNftCollection
        leftLabel.font = .bodyBold
        leftLabel.textColor = .segmentActive
        
        countOfNftsLabel.text = ""
        countOfNftsLabel.font = .bodyBold
        countOfNftsLabel.textColor = .segmentActive
        
        let stack = UIStackView(arrangedSubviews: [leftLabel, countOfNftsLabel])
        stack.axis = .horizontal
        stack.spacing = UserCardViewControllerLayout.nftButtonSpaceInStack
        stack.alignment = .center
        
        nftCollectionButton.addSubview(stack)
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        let config = UIImage.SymbolConfiguration(weight: .bold)
        let arrowImage = UIImageView(image: UIImage(systemName: "chevron.right", withConfiguration: config))
        arrowImage.tintColor = .segmentActive
        nftCollectionButton.addSubview(arrowImage)
        arrowImage.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: nftCollectionButton.leadingAnchor, constant: UserCardViewControllerLayout.nftButtonStackLeading),
            stack.centerYAnchor.constraint(equalTo: nftCollectionButton.centerYAnchor),
            
            arrowImage.trailingAnchor.constraint(equalTo: nftCollectionButton.trailingAnchor, constant: UserCardViewControllerLayout.nftButtonArrowImageTrailing),
            arrowImage.centerYAnchor.constraint(equalTo: nftCollectionButton.centerYAnchor)
        ])
        
        leftLabel.isUserInteractionEnabled = false
        countOfNftsLabel.isUserInteractionEnabled = false
        stack.isUserInteractionEnabled = false
        arrowImage.isUserInteractionEnabled = false
        
        nftCollectionButton.addTarget(self, action: #selector(nftCollectionButtonClicked), for: .touchUpInside)
        nftCollectionButton.translatesAutoresizingMaskIntoConstraints = false
        
        return nftCollectionButton
    }()
    
    // MARK: - Initializers
    init(viewModel: UserCardViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        nil
    }
    
    // MARK: - View Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .forViewBackground
        navigationController?.navigationBar.tintColor = .closeButton
        
        addTargetsForButtons()
        addSubviews()
        setupConstraints()
        bindViewModel()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        goToUserWebsiteButton.layer.borderColor = UIColor.segmentActive.cgColor
        goToUserWebsiteButton.setTitleColor(.segmentActive, for: .normal)
    }
    
    // MARK: - Private Methods
    @objc private func goToUserWebsiteButtonClicked() {
        guard let webSiteURL = viewModel.userInfo?.website else { return }
        let webView = WebViewViewController(urlString: webSiteURL.absoluteString)
        
        universalOpenPage(viewController: webView)
    }
    
    @objc private func nftCollectionButtonClicked() {
        let userCollectionViewModel = UserCollectionViewModel(servicesAssembly: viewModel.servicesAssembly)
        let userCollectionViewController = UserCollectionViewController(viewModel: userCollectionViewModel)
        
        universalOpenPage(viewController: userCollectionViewController)

        guard let nfts = viewModel.userInfo?.nfts else { return }
        userCollectionViewModel.loadEverything(listOfNfts: nfts)
    }
    
    private func addTargetsForButtons() {
        goToUserWebsiteButton.addTarget(self, action: #selector(goToUserWebsiteButtonClicked), for: .touchUpInside)
    }
    
    private func addSubviews() {
        view.addSubview(activityIndicator)
        view.addSubview(viewWithAllElements)
        
        [userAvatarImageView, userNameLabel, userDescriptionLabel, goToUserWebsiteButton, nftCollectionButton].forEach {
            viewWithAllElements.addSubview($0)
        }
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            viewWithAllElements.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            viewWithAllElements.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            viewWithAllElements.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            viewWithAllElements.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            userAvatarImageView.heightAnchor.constraint(equalToConstant: UserCardViewControllerLayout.avatarSize),
            userAvatarImageView.widthAnchor.constraint(equalToConstant: UserCardViewControllerLayout.avatarSize),
            userAvatarImageView.leadingAnchor.constraint(equalTo: viewWithAllElements.leadingAnchor, constant: UserCardViewControllerLayout.avatarLeading),
            userAvatarImageView.topAnchor.constraint(equalTo: viewWithAllElements.topAnchor, constant: UserCardViewControllerLayout.avatarTop),
            
            userNameLabel.leadingAnchor.constraint(equalTo: userAvatarImageView.trailingAnchor, constant: UserCardViewControllerLayout.userNameLeading),
            userNameLabel.trailingAnchor.constraint(equalTo: viewWithAllElements.trailingAnchor, constant: UserCardViewControllerLayout.userNameTrailing),
            userNameLabel.centerYAnchor.constraint(equalTo: userAvatarImageView.centerYAnchor),
            
            userDescriptionLabel.leadingAnchor.constraint(equalTo: viewWithAllElements.leadingAnchor, constant: UserCardViewControllerLayout.descriptionLeading),
            userDescriptionLabel.trailingAnchor.constraint(equalTo: viewWithAllElements.trailingAnchor, constant: UserCardViewControllerLayout.descriptionTrailing),
            userDescriptionLabel.topAnchor.constraint(equalTo: userAvatarImageView.bottomAnchor, constant: UserCardViewControllerLayout.descriptionTop),
            userDescriptionLabel.heightAnchor.constraint(equalToConstant: UserCardViewControllerLayout.descriptionHeight),
            
            goToUserWebsiteButton.leadingAnchor.constraint(equalTo: viewWithAllElements.leadingAnchor, constant: UserCardViewControllerLayout.websiteButtonLeading),
            goToUserWebsiteButton.trailingAnchor.constraint(equalTo: viewWithAllElements.trailingAnchor, constant: UserCardViewControllerLayout.websiteButtonTrailing),
            goToUserWebsiteButton.topAnchor.constraint(equalTo: userDescriptionLabel.bottomAnchor, constant: UserCardViewControllerLayout.websiteButtonTop),
            goToUserWebsiteButton.heightAnchor.constraint(equalToConstant: UserCardViewControllerLayout.websiteButtonHeight),
            
            nftCollectionButton.leadingAnchor.constraint(equalTo: viewWithAllElements.leadingAnchor),
            nftCollectionButton.trailingAnchor.constraint(equalTo: viewWithAllElements.trailingAnchor),
            nftCollectionButton.topAnchor.constraint(equalTo: goToUserWebsiteButton.bottomAnchor, constant: UserCardViewControllerLayout.nftButtonTop),
            nftCollectionButton.heightAnchor.constraint(greaterThanOrEqualToConstant: UserCardViewControllerLayout.nftButtonMinHeight)
        ])
    }
    
    private func showNeedViewsInScreen(needToShowLoadingIndicator: UIStateForLoader) {
        switch needToShowLoadingIndicator {
        case .showLoaderHideViews:
            showLoading()
            self.viewWithAllElements.isHidden = true
        case .showViewsHideLoader:
            hideLoading()
            self.viewWithAllElements.isHidden = false
        case .showBoth:
            showLoading()
            self.viewWithAllElements.isHidden = false
        case .hideBoth:
            hideLoading()
            self.viewWithAllElements.isHidden = true
        }
    }
    
    private func insertUserDataIntoFields(userData: UserCardViewData) {
        let processor = RoundCornerImageProcessor(cornerRadius: UserCardViewControllerLayout.avatarCornerRadius)
        guard let url = userData.avatarURL else  {
            return self.userAvatarImageView.image = Constants.defaultImage
        }
        
        self.userAvatarImageView.kf.setImage(with: url,
                                             placeholder: nil,
                                             options: [.processor(processor)]) { result in
            switch result {
            case .success:
                // image loaded correctly
                break
            case .failure:
                self.userAvatarImageView.image = Constants.defaultImage
            }
        }
        
        self.userNameLabel.text = userData.name
        self.userDescriptionLabel.text = userData.decription
        self.countOfNftsLabel.text = "(\(userData.nfts.count))"
    }
    
    private func bindViewModel() {
        viewModel.$state
            .receive(on: RunLoop.main)
            .sink { [weak self] state in
                guard let self else { return }
                
                switch state {
                case .idle:
                    showNeedViewsInScreen(needToShowLoadingIndicator: .hideBoth)
                case .loading:
                    showNeedViewsInScreen(needToShowLoadingIndicator: .showLoaderHideViews)
                case .loaded(let user):
                    showNeedViewsInScreen(needToShowLoadingIndicator: .showViewsHideLoader)
                    insertUserDataIntoFields(userData: user)
                case .error(_):
                    showNeedViewsInScreen(needToShowLoadingIndicator: .hideBoth)
                    showErrorAlert()
                }
            }
            .store(in: &cancellables)
    }
    
    private func showErrorAlert() {
        universalErrorAlert { [weak self] in
            guard let self,
                  let userId = self.viewModel.userId else { return }
            self.viewModel.fetchUserById(userId)
        }
    }
}
