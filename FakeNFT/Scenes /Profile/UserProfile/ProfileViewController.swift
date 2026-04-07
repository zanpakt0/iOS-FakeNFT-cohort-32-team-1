import UIKit
import Kingfisher
import Combine

final class ProfileViewController: UIViewController, LoadingView {
    
    // MARK: - Private Properties
    private let viewModel: ProfileViewModel
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Views (elements)
    let activityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.hidesWhenStopped = true
        activityIndicator.color = .segmentActive
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        
        return activityIndicator
    }()
    private let viewWithAllElements: UIView = {
        let viewWithAllElements = UIView()
        viewWithAllElements.backgroundColor = .forViewBackground
        viewWithAllElements.translatesAutoresizingMaskIntoConstraints = false
        
        return viewWithAllElements
    }()
    private let editProfileButton: UIButton = {
        let editProfileButton = UIButton(type: .system)
        let imageForButton = UIImage(resource: .editProfile)
        editProfileButton.setImage(imageForButton, for: .normal)
        editProfileButton.tintColor = .segmentActive
        editProfileButton.isUserInteractionEnabled = false
        editProfileButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            editProfileButton.widthAnchor.constraint(equalToConstant: 42),
            editProfileButton.heightAnchor.constraint(equalToConstant: 42)
        ])
        
        return editProfileButton
    }()
    private let avatarImageView: UIImageView = {
        let exampleImage = UIImage(systemName: "person.crop.circle.fill")
        let avatarImageView = UIImageView(image: exampleImage)
        avatarImageView.clipsToBounds = true
        avatarImageView.layer.cornerRadius = 35
        avatarImageView.clipsToBounds = true
        avatarImageView.translatesAutoresizingMaskIntoConstraints = false
        
        return avatarImageView
    }()
    private let nameLabel: UILabel = {
        let nameLabel = UILabel()
        nameLabel.font = .headline3
        nameLabel.textColor = .segmentActive
        nameLabel.backgroundColor = .forViewBackground
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        return nameLabel
    }()
    private let descriptionLabel: UILabel = {
        let descriptionLabel = UILabel()
        descriptionLabel.textColor = . segmentActive
        descriptionLabel.font = .caption2
        descriptionLabel.numberOfLines = 4
        descriptionLabel.backgroundColor = .forViewBackground
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        
        return descriptionLabel
    }()
    private let websiteButton: UIButton = {
        let websiteButton = UIButton(type: .system)
        websiteButton.setTitleColor(.authorBlue, for: .normal)
        websiteButton.titleLabel?.font = .caption1
        websiteButton.backgroundColor = .forViewBackground
        websiteButton.contentHorizontalAlignment = .left
        websiteButton.translatesAutoresizingMaskIntoConstraints = false
        
        return websiteButton
    }()
    private let countOfMyNftLabel: UILabel = UILabel()
    private lazy var myNftButton: UIButton = {
        let myNftButton = UIButton(type: .system)
        let titleOfMyNft = NSLocalizedString("profile.myNft", comment: "")
        
        let leftLabel = UILabel()
        leftLabel.text = titleOfMyNft
        leftLabel.font = .bodyBold
        leftLabel.textColor = .segmentActive
        
        countOfMyNftLabel.text = ""
        countOfMyNftLabel.font = .bodyBold
        countOfMyNftLabel.textColor = .segmentActive
        
        let stackView = UIStackView(arrangedSubviews: [leftLabel, countOfMyNftLabel])
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.alignment = .center
        
        myNftButton.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        let config = UIImage.SymbolConfiguration(weight: .bold)
        let arrowImage = UIImageView(image: UIImage(systemName: "chevron.right", withConfiguration: config))
        arrowImage.tintColor = .segmentActive
        myNftButton.addSubview(arrowImage)
        arrowImage.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: myNftButton.leadingAnchor, constant: 16),
            stackView.centerYAnchor.constraint(equalTo: myNftButton.centerYAnchor),
            
            arrowImage.trailingAnchor.constraint(equalTo: myNftButton.trailingAnchor, constant: -16),
            arrowImage.centerYAnchor.constraint(equalTo: myNftButton.centerYAnchor)
        ])
        
        leftLabel.isUserInteractionEnabled = false
        countOfMyNftLabel.isUserInteractionEnabled = false
        stackView.isUserInteractionEnabled = false
        arrowImage.isUserInteractionEnabled = false
        
        myNftButton.addTarget(self, action: #selector(myNftButtonTapped), for: .touchUpInside)
        myNftButton.translatesAutoresizingMaskIntoConstraints = false
        
        return myNftButton
    }()
    private let countOfFavouriteNftLabel: UILabel = UILabel()
    private lazy var favouriteNftButton: UIButton = {
        let favouriteNftButton = UIButton(type: .system)
        let favouriteNftTitle = NSLocalizedString("profile.favouriteNft", comment: "")
        
        let leftLabel = UILabel()
        leftLabel.text = favouriteNftTitle
        leftLabel.font = .bodyBold
        leftLabel.textColor = .segmentActive
        
        countOfFavouriteNftLabel.text = ""
        countOfFavouriteNftLabel.font = .bodyBold
        countOfFavouriteNftLabel.textColor = .segmentActive
        
        let stackView = UIStackView(arrangedSubviews: [leftLabel, countOfFavouriteNftLabel])
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.alignment = .center
        
        favouriteNftButton.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        let config = UIImage.SymbolConfiguration(weight: .bold)
        let arrowImage = UIImageView(image: UIImage(systemName: "chevron.right", withConfiguration: config))
        arrowImage.tintColor = .segmentActive
        favouriteNftButton.addSubview(arrowImage)
        arrowImage.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: favouriteNftButton.leadingAnchor, constant: 16),
            stackView.centerYAnchor.constraint(equalTo: favouriteNftButton.centerYAnchor),
            
            arrowImage.trailingAnchor.constraint(equalTo: favouriteNftButton.trailingAnchor, constant: -16),
            arrowImage.centerYAnchor.constraint(equalTo: favouriteNftButton.centerYAnchor)
        ])
        
        leftLabel.isUserInteractionEnabled = false
        countOfFavouriteNftLabel.isUserInteractionEnabled = false
        stackView.isUserInteractionEnabled = false
        arrowImage.isUserInteractionEnabled = false
        
        favouriteNftButton.addTarget(self, action: #selector(favouriteNftButtonTapped), for: .touchUpInside)
        favouriteNftButton.translatesAutoresizingMaskIntoConstraints = false
        
        return favouriteNftButton
    }()
    
    // MARK: - Initializers
    init(viewModel: ProfileViewModel) {
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
        setupNavBar()
        addSubviews()
        setupConstraints()
        bindViewModel()
        
        viewModel.fetchProfileInfo()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        viewModel.fetchProfileInfo()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        viewModel.stopTaskWhenClosed()
        showNeedViewsInScreen(whatShouldBeShown: .hideBoth)
    }
    
    // MARK: - Private Methods
    @objc private func editProfileButtonTapped() {
        guard let profileInfo = viewModel.profileInfo else { return }
        let viewModel = EditProfileViewModel(
            servicesAssembly: viewModel.servicesAssembly,
            profileData: profileInfo
        )
        let viewController = EditProfileViewController(viewModel: viewModel)
        
        universalOpenPage(viewController: viewController)
    }
    
    @objc private func websiteButtonTapped() {
        let webView = WebViewViewController(urlString: "https://practicum.yandex.kz")
        
        universalOpenPage(viewController: webView)
    }
    
    @objc private func myNftButtonTapped() {
        print("MyNft button tapped")
    }
    
    @objc private func favouriteNftButtonTapped() {
        print("FavouriteNft button tapped")
    }
    
    private func makeEditProfileButtonClickable() {
        editProfileButton.isUserInteractionEnabled = true
    }
    
    private func addTargetsForButtons() {
        editProfileButton.addTarget(self, action: #selector(editProfileButtonTapped), for: .touchUpInside)
        websiteButton.addTarget(self, action: #selector(websiteButtonTapped), for: .touchUpInside)
    }
    
    private func addSubviews() {
        view.addSubview(activityIndicator)
        view.addSubview(viewWithAllElements)
        
        [avatarImageView, nameLabel, descriptionLabel, websiteButton, myNftButton, favouriteNftButton].forEach {
            viewWithAllElements.addSubview($0)
        }
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            viewWithAllElements.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            viewWithAllElements.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            viewWithAllElements.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            viewWithAllElements.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            avatarImageView.heightAnchor.constraint(equalToConstant: 70),
            avatarImageView.widthAnchor.constraint(equalToConstant: 70),
            avatarImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            avatarImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            
            nameLabel.leadingAnchor.constraint(equalTo: avatarImageView.trailingAnchor, constant: 16),
            nameLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            nameLabel.centerYAnchor.constraint(equalTo: avatarImageView.centerYAnchor),
            
            descriptionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            descriptionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -18),
            descriptionLabel.topAnchor.constraint(equalTo: avatarImageView.bottomAnchor, constant: 20),
            descriptionLabel.heightAnchor.constraint(equalToConstant: 72),
            
            websiteButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            websiteButton.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 8),
            websiteButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -18),
            websiteButton.heightAnchor.constraint(equalToConstant: 28),
            
            myNftButton.leadingAnchor.constraint(equalTo: viewWithAllElements.leadingAnchor),
            myNftButton.trailingAnchor.constraint(equalTo: viewWithAllElements.trailingAnchor),
            myNftButton.topAnchor.constraint(equalTo: websiteButton.bottomAnchor, constant: 40),
            myNftButton.heightAnchor.constraint(greaterThanOrEqualToConstant: 54),
            
            favouriteNftButton.leadingAnchor.constraint(equalTo: viewWithAllElements.leadingAnchor),
            favouriteNftButton.trailingAnchor.constraint(equalTo: viewWithAllElements.trailingAnchor),
            favouriteNftButton.topAnchor.constraint(equalTo: myNftButton.bottomAnchor),
            favouriteNftButton.heightAnchor.constraint(greaterThanOrEqualToConstant: 54)
        ])
    }
    
    private func showNeedViewsInScreen(whatShouldBeShown: UIStateForLoader) {
        switch whatShouldBeShown {
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
    
    private func insertDataIntoFields(profile: ProfileViewData) {
        let processor = RoundCornerImageProcessor(cornerRadius: 35)
        guard let url = profile.avatarURL else {
            return self.avatarImageView.image = Constants.defaultImage
        }

        self.avatarImageView.kf.setImage(with: url,
                                         placeholder: nil,
                                         options: [.processor(processor)]) { result in
            switch result {
            case .success: 
                // image loaded correctly
                break
            case .failure:
                self.avatarImageView.image = Constants.defaultImage
            }
        }
        
        nameLabel.text = profile.name
        descriptionLabel.text = profile.description
        websiteButton.setTitle("\(profile.name).com", for: .normal)
        countOfMyNftLabel.text = "(\(profile.nfts.count))"
        countOfFavouriteNftLabel.text = "(\(profile.likes.count))"
    }
    
    private func bindViewModel() {
        viewModel.$state
            .receive(on: RunLoop.main)
            .sink { [weak self] state in
                guard let self else { return }
                
                switch state {
                case .idle:
                    showNeedViewsInScreen(whatShouldBeShown: .hideBoth)
                case .loading:
                    showNeedViewsInScreen(whatShouldBeShown: .showLoaderHideViews)
                case .loaded(let profile):
                    showNeedViewsInScreen(whatShouldBeShown: .showViewsHideLoader)
                    insertDataIntoFields(profile: profile)
                    makeEditProfileButtonClickable()
                case .error(_):
                    showNeedViewsInScreen(whatShouldBeShown: .hideBoth)
                    showErrorAlert()
                }
            }
            .store(in: &cancellables)
    }
    
    private func setupNavBar() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: editProfileButton)
    }
    
    private func showErrorAlert() {
        universalErrorAlert { [weak self] in
            guard let self else { return }
            self.viewModel.fetchProfileInfo()
        }
    }
}
