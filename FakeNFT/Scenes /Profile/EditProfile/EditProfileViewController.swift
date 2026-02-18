import UIKit
import Kingfisher
import Combine

final class EditProfileViewController: UIViewController {
    
    // MARK: - Private Properties
    private let viewModel: EditProfileViewModel
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Views (elements)
    private let userAvatarImageButton: UIButton = {
        let exampleImage = UIImage(systemName: "person.crop.circle.fill")
        let userAvatarImageButton = UIButton(type: .custom)
        userAvatarImageButton.setImage(exampleImage, for: .normal)
        userAvatarImageButton.layer.cornerRadius = 35
        userAvatarImageButton.clipsToBounds = true
        userAvatarImageButton.imageView?.contentMode = .scaleAspectFill
        userAvatarImageButton.contentHorizontalAlignment = .fill
        userAvatarImageButton.contentVerticalAlignment = .fill
        userAvatarImageButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            userAvatarImageButton.heightAnchor.constraint(equalToConstant: 70),
            userAvatarImageButton.widthAnchor.constraint(equalToConstant: 70)
        ])
        
        return userAvatarImageButton
    }()
    private let cameraButton: UIButton = {
        let exampleImage = UIImage(resource: .iconOfCamera)
        let userAvatarImageButton = UIButton(type: .system)
        userAvatarImageButton.setImage(exampleImage, for: .normal)
        userAvatarImageButton.layer.cornerRadius = 11.285
        userAvatarImageButton.backgroundColor = .segmentInactive
        userAvatarImageButton.tintColor = .segmentActive
        userAvatarImageButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            userAvatarImageButton.heightAnchor.constraint(equalToConstant: 22.57),
            userAvatarImageButton.widthAnchor.constraint(equalToConstant: 22.57)
        ])
        
        return userAvatarImageButton
    }()
    private let userNameLabel: UILabel = {
        let userNameLabel = UILabel()
        let userNameText = NSLocalizedString("EditProfile.nameLabel.title", comment: "")
        
        userNameLabel.text = userNameText
        userNameLabel.font = .headline3
        userNameLabel.textColor = .segmentActive
        userNameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        return userNameLabel
    }()
    private let userNameTextField: PaddedTextField = {
        let userNameTextField = PaddedTextField()
        userNameTextField.textColor = .segmentActive
        userNameTextField.font = .bodyRegular
        userNameTextField.backgroundColor = .segmentInactive
        userNameTextField.layer.cornerRadius = 12
        userNameTextField.translatesAutoresizingMaskIntoConstraints = false
        
        return userNameTextField
    }()
    private let userDescriptionLabel: UILabel = {
        let userDescriptionLabel = UILabel()
        let userDescriptionText = NSLocalizedString("EditProfile.descriptionLabel.title", comment: "")
        
        userDescriptionLabel.text = userDescriptionText
        userDescriptionLabel.font = .headline3
        userDescriptionLabel.textColor = .segmentActive
        userDescriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        
        return userDescriptionLabel
    }()
    private let userDescriptionTextView: UITextView = {
        let userDescriptionTextView = UITextView()
        userDescriptionTextView.textColor = .segmentActive
        userDescriptionTextView.backgroundColor = .segmentInactive
        userDescriptionTextView.font = .bodyRegular
        userDescriptionTextView.layer.cornerRadius = 12
        userDescriptionTextView.isScrollEnabled = true
        userDescriptionTextView.textContainerInset = UIEdgeInsets(
            top: 11,
            left: 16,
            bottom: 11,
            right: 16)
        userDescriptionTextView.textContainer.lineFragmentPadding = 0
        userDescriptionTextView.translatesAutoresizingMaskIntoConstraints = false
        userDescriptionTextView.heightAnchor.constraint(equalToConstant: 132).isActive = true
    
        return userDescriptionTextView
    }()
    private let userWebsiteLabel: UILabel = {
        let userWebsiteLabel = UILabel()
        let userWebsiteText = NSLocalizedString("EditProfile.websiteLabel.title", comment: "")
        
        userWebsiteLabel.text = userWebsiteText
        userWebsiteLabel.font = .headline3
        userWebsiteLabel.textColor = .segmentActive
        userWebsiteLabel.translatesAutoresizingMaskIntoConstraints = false
        
        return userWebsiteLabel
    }()
    private let userWebsiteTextField: PaddedTextField = {
        let userWebsiteTextField = PaddedTextField()
        userWebsiteTextField.textColor = .segmentActive
        userWebsiteTextField.font = .bodyRegular
        userWebsiteTextField.backgroundColor = .segmentInactive
        userWebsiteTextField.layer.cornerRadius = 12
        userWebsiteTextField.translatesAutoresizingMaskIntoConstraints = false
        
        return userWebsiteTextField
    }()
    
    // MARK: - Initializers
    init(viewModel: EditProfileViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        nil
    }
    
    // MARK: View Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addTargetsForButtons()
        addSubviews()
        bindViewModel()
        
        insertDataIntoFields(userInfo: viewModel.profileData)
    }
    
    // MARK: - Private Methods
    @objc private func cameraButtonTapped() {
        
    }
    
    private func insertDataIntoFields(userInfo: ProfileViewData?) {
        guard let url = userInfo?.avatarURL else {
            return self.userAvatarImageButton.setImage(Constants.defaultImage, for: .normal)
        }
        
        
        self.userAvatarImageButton.kf.setImage(with: url,
                                               for: .normal,
                                               placeholder: nil,
                                               options: nil, completionHandler:   { result in
            switch result {
            case .success:
                // image loaded correctly
                break
            case .failure:
                self.userAvatarImageButton.setImage(Constants.defaultImage, for: .normal)
            }
        })
        
        userNameTextField.text = userInfo?.name
        userDescriptionTextView.text = userInfo?.description
        userWebsiteTextField.text = userInfo?.websiteURL?.absoluteString
    }
    
    private func addTargetsForButtons() {
        userAvatarImageButton.addTarget(self, action: #selector(cameraButtonTapped), for: .touchUpInside)
        cameraButton.addTarget(self, action: #selector(cameraButtonTapped), for: .touchUpInside)
    }
    
    private func addSubviews() {
        [userAvatarImageButton, cameraButton, userNameLabel, userNameTextField, userDescriptionLabel, userDescriptionTextView, userWebsiteLabel, userWebsiteTextField].forEach {
            view.addSubview($0)
        }
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            userAvatarImageButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            userAvatarImageButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: -8),
            
            cameraButton.bottomAnchor.constraint(equalTo: userAvatarImageButton.bottomAnchor),
            cameraButton.trailingAnchor.constraint(equalTo: userAvatarImageButton.trailingAnchor, constant: 2.57),
            
            userNameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            userNameLabel.topAnchor.constraint(equalTo: userAvatarImageButton.bottomAnchor, constant: 24),
            userNameLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            userNameTextField.topAnchor.constraint(equalTo: userNameLabel.bottomAnchor, constant: 8),
            userNameTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            userNameTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            userNameTextField.heightAnchor.constraint(equalToConstant: 44),
            
            userDescriptionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            userDescriptionLabel.topAnchor.constraint(equalTo: userNameTextField.bottomAnchor, constant: 24),
            userDescriptionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            userDescriptionTextView.topAnchor.constraint(equalTo: userDescriptionLabel.bottomAnchor, constant: 8),
            userDescriptionTextView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            userDescriptionTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            userWebsiteLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            userWebsiteLabel.topAnchor.constraint(equalTo: userDescriptionTextView.bottomAnchor, constant: 24),
            userWebsiteLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            userWebsiteTextField.topAnchor.constraint(equalTo: userWebsiteLabel.bottomAnchor, constant: 8),
            userWebsiteTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            userWebsiteTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            userWebsiteTextField.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    private func bindViewModel() {
        viewModel.$state
            .receive(on: RunLoop.main)
            .sink { [weak self] state in
                guard let self else { return }
                
                switch state {
                case .idle:
                    break
                case .loading:
                    break
                case .loaded(_):
                    break
                case .error(_):
                    break
                }
            }
            .store(in: &cancellables)
    }
}

