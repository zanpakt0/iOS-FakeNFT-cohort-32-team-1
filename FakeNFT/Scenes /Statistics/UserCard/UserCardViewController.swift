import UIKit
import Combine
import Kingfisher

// MARK: - Need enums
enum UserCardLayout {
    static let avatarSize: CGFloat = 70
    static let avatarLeading: CGFloat = 16
    static let avatarTop: CGFloat = 20
    static let avatarCornerRadius: CGFloat = 35

    static let userNameLeading: CGFloat = 16
    static let userNameTrailing: CGFloat = -16

    static let descriptionLeading: CGFloat = 16
    static let descriptionTrailing: CGFloat = -16
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

final class UserCardViewController: UIViewController, LoadingView, ErrorView {
    
    // MARK: - Private Properties
    private let viewModel: UserCardViewModel
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Views (elements)
    lazy var activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        
        return indicator
    }()
    private lazy var viewWithAllElements: UIView = {
        let viewWithAllElements = UIView()
        viewWithAllElements.backgroundColor = .forViewBackgound
        viewWithAllElements.translatesAutoresizingMaskIntoConstraints = false
        
        return viewWithAllElements
    }()
    private lazy var userAvatarImageView: UIImageView = {
        let exampleImage = UIImage(systemName: "person.crop.circle.fill")
        let userAvatarImageView = UIImageView(image: exampleImage)
        userAvatarImageView.clipsToBounds = true
        userAvatarImageView.layer.cornerRadius = UserCardLayout.avatarCornerRadius
        userAvatarImageView.translatesAutoresizingMaskIntoConstraints = false
        
        return userAvatarImageView
    }()
    private lazy var userNameLabel: UILabel = {
        let userNameLabel = UILabel()
        userNameLabel.font = UIFont.headline3
        userNameLabel.textColor = .segmentActive
        userNameLabel.backgroundColor = .forViewBackgound
        userNameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        return userNameLabel
    }()
    private lazy var userDescriptionLabel: UILabel = {
        let userDescriptionLabel = UILabel()
        userDescriptionLabel.font = UIFont.caption2
        userDescriptionLabel.textColor = .segmentActive
        userDescriptionLabel.backgroundColor = .forViewBackgound
        userDescriptionLabel.numberOfLines = UserCardLayout.descriptionNumberOfLines
        userDescriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        
        return userDescriptionLabel
    }()
    private lazy var goToUserWebsiteButton: UIButton = {
        let goToUserWebsiteButton = UIButton(type: .custom)
        let titleOfGoToUserWebsiteButton = NSLocalizedString("UserCard.goToUserWebsiteButton.title", comment: "")
        
        goToUserWebsiteButton.setTitle(titleOfGoToUserWebsiteButton, for: .normal)
        goToUserWebsiteButton.titleLabel?.font = UIFont.caption1
        goToUserWebsiteButton.setTitleColor(.segmentActive, for: .normal)
        goToUserWebsiteButton.contentHorizontalAlignment = .center
        goToUserWebsiteButton.contentVerticalAlignment = .center
        
        goToUserWebsiteButton.addTarget(self, action: #selector(goToUserWebsiteButtonClicked), for: .touchUpInside)
        
        goToUserWebsiteButton.layer.borderWidth = UserCardLayout.websiteBorderWidth
        goToUserWebsiteButton.layer.borderColor = UIColor.segmentActive.cgColor
        
        goToUserWebsiteButton.layer.cornerRadius = UserCardLayout.websiteCornerRadius
        goToUserWebsiteButton.translatesAutoresizingMaskIntoConstraints = false
        
        return goToUserWebsiteButton
    }()
    private lazy var countOfNftsLabel: UILabel = UILabel()
    private lazy var nftCollectionButton: UIButton = {
        let nftCollectionButton = UIButton(type: .system)
        let titleOfNftCollection = NSLocalizedString("UserCard.nftCollectionButton.title", comment: "")
        
        let leftLabel = UILabel()
        leftLabel.text = titleOfNftCollection
        leftLabel.font = UIFont.bodyBold
        leftLabel.textColor = .segmentActive
        
        countOfNftsLabel.text = ""
        countOfNftsLabel.font = UIFont.bodyBold
        countOfNftsLabel.textColor = .segmentActive
        
        let stack = UIStackView(arrangedSubviews: [leftLabel, countOfNftsLabel])
        stack.axis = .horizontal
        stack.spacing = UserCardLayout.nftButtonSpaceInStack
        stack.alignment = .center
        
        nftCollectionButton.addSubview(stack)
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        let config = UIImage.SymbolConfiguration(weight: .bold)
        let arrowImage = UIImageView(image: UIImage(systemName: "chevron.right", withConfiguration: config))
        arrowImage.tintColor = .segmentActive
        nftCollectionButton.addSubview(arrowImage)
        arrowImage.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: nftCollectionButton.leadingAnchor, constant: UserCardLayout.nftButtonStackLeading),
            stack.centerYAnchor.constraint(equalTo: nftCollectionButton.centerYAnchor),
            
            arrowImage.trailingAnchor.constraint(equalTo: nftCollectionButton.trailingAnchor, constant: UserCardLayout.nftButtonArrowImageTrailing),
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
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - View Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .forViewBackgound
        navigationController?.navigationBar.tintColor = .closeButton
        
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
        guard let webSiteURL = self.viewModel.userInfo?.website else { return }
        let webView = WebViewViewController(urlString: webSiteURL.absoluteString)
        
        let transition = CATransition()
        transition.duration = ConstantsForStatistics.transitionDurationWhenOpenPage
        transition.type = .push
        transition.subtype = .fromTop
        navigationController?.view.layer.add(transition, forKey: kCATransition)
        
        navigationItem.backButtonTitle = ""
        webView.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(webView, animated: false)
    }
    
    @objc private func nftCollectionButtonClicked() {
        let userCollectionViewModel = UserCollectionViewModel(serviceAssembly: self.viewModel.serviceAssembly)
        let userCollectionViewController = UserCollectionViewController(viewModel: userCollectionViewModel)
        
        let transition = CATransition()
        transition.duration = ConstantsForStatistics.transitionDurationWhenOpenPage
        transition.type = .push
        transition.subtype = .fromTop
        navigationController?.view.layer.add(transition, forKey: kCATransition)
        
        navigationItem.backButtonTitle = ""
        userCollectionViewController.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(userCollectionViewController, animated: false)
        
        guard let nfts = viewModel.userInfo?.nfts else { return }
        userCollectionViewModel.fetchNfts(listOfNfts: nfts)
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
            
            userAvatarImageView.heightAnchor.constraint(equalToConstant: UserCardLayout.avatarSize),
            userAvatarImageView.widthAnchor.constraint(equalToConstant: UserCardLayout.avatarSize),
            userAvatarImageView.leadingAnchor.constraint(equalTo: viewWithAllElements.leadingAnchor, constant: UserCardLayout.avatarLeading),
            userAvatarImageView.topAnchor.constraint(equalTo: viewWithAllElements.topAnchor, constant: UserCardLayout.avatarTop),
            
            userNameLabel.leadingAnchor.constraint(equalTo: userAvatarImageView.trailingAnchor, constant: UserCardLayout.userNameLeading),
            userNameLabel.trailingAnchor.constraint(equalTo: viewWithAllElements.trailingAnchor, constant: UserCardLayout.userNameTrailing),
            userNameLabel.centerYAnchor.constraint(equalTo: userAvatarImageView.centerYAnchor),
            
            userDescriptionLabel.leadingAnchor.constraint(equalTo: viewWithAllElements.leadingAnchor, constant: UserCardLayout.descriptionLeading),
            userDescriptionLabel.trailingAnchor.constraint(equalTo: viewWithAllElements.trailingAnchor, constant: UserCardLayout.descriptionTrailing),
            userDescriptionLabel.topAnchor.constraint(equalTo: userAvatarImageView.bottomAnchor, constant: UserCardLayout.descriptionTop),
            userDescriptionLabel.heightAnchor.constraint(equalToConstant: UserCardLayout.descriptionHeight),
            
            goToUserWebsiteButton.leadingAnchor.constraint(equalTo: viewWithAllElements.leadingAnchor, constant: UserCardLayout.websiteButtonLeading),
            goToUserWebsiteButton.trailingAnchor.constraint(equalTo: viewWithAllElements.trailingAnchor, constant: UserCardLayout.websiteButtonTrailing),
            goToUserWebsiteButton.topAnchor.constraint(equalTo: userDescriptionLabel.bottomAnchor, constant: UserCardLayout.websiteButtonTop),
            goToUserWebsiteButton.heightAnchor.constraint(equalToConstant: UserCardLayout.websiteButtonHeight),
            
            nftCollectionButton.leadingAnchor.constraint(equalTo: viewWithAllElements.leadingAnchor),
            nftCollectionButton.trailingAnchor.constraint(equalTo: viewWithAllElements.trailingAnchor),
            nftCollectionButton.topAnchor.constraint(equalTo: goToUserWebsiteButton.bottomAnchor, constant: UserCardLayout.nftButtonTop),
            nftCollectionButton.heightAnchor.constraint(greaterThanOrEqualToConstant: UserCardLayout.nftButtonMinHeight)
        ])
    }
    
    private func showNeedViewsInScreen(needToShowLoadingIndicator: UIStateForLoader) {
        switch needToShowLoadingIndicator {
        case .showLoaderHideViews:
            showLoading()
            viewWithAllElements.isHidden = true
        case .showViewsHideLoader:
            hideLoading()
            viewWithAllElements.isHidden = false
        case .showBoth:
            showLoading()
            viewWithAllElements.isHidden = false
        case .hideBoth:
            hideLoading()
            viewWithAllElements.isHidden = true
        }
    }
    
    private func insertUserDataIntoFields(userData: UserCardViewData) {
        let processor = RoundCornerImageProcessor(cornerRadius: UserCardLayout.avatarCornerRadius)
        let defaultImage = UIImage(systemName: "person.crop.circle.fill")?
            .withTintColor(UIColor.forDefaultAvatarBackgound, renderingMode: .alwaysOriginal)
        guard let url = userData.avatarURL else  {
            return self.userAvatarImageView.image = defaultImage
        }
        
        self.userAvatarImageView.kf.setImage(with: url,
                                             placeholder: nil,
                                             options: [.processor(processor)]) { result in
            switch result {
            case .success:
                // image loaded correctly
                break
            case .failure:
                self.userAvatarImageView.image = defaultImage
            }
        }
        
        userNameLabel.text = userData.name
        userDescriptionLabel.text = userData.decription
        countOfNftsLabel.text = "(\(userData.nfts.count))"
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
                    self.showErrorAlert()
                }
            }
            .store(in: &cancellables)
    }
    
    private func showErrorAlert() {
        let retryActionText = NSLocalizedString("Statistics.errorAlert.retryAction.text", comment: "")
        let errorModel = ErrorModel(
            message: "",
            actionText: retryActionText,
            action: {[weak self] in
                guard let self,
                      let userId = self.viewModel.userId else { return }
                self.viewModel.fetchUserById(userId)
            }
        )
        
        let title = NSLocalizedString("Statistics.errorAlert.title", comment: "")
        
        let retryAction = UIAlertAction(title: errorModel.actionText, style: .default) {_ in
            errorModel.action()
        }
        
        let cancelActionText = NSLocalizedString("Statistics.errorAlert.cancelAction.text", comment: "")
        let cancelAction = UIAlertAction(title: cancelActionText, style: .cancel)
        
        self.showErrorAlertWithTwoButtons(titleOfAlert: title, firstAction: cancelAction, secondAction: retryAction)
    }
}
