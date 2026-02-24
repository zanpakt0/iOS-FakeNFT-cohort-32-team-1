import UIKit
import Kingfisher
import Combine

final class EditProfileViewController: UIViewController {
    
    // MARK: - Private Properties
    private let viewModel: EditProfileViewModel
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Views (elements)
    private var okAction: UIAlertAction?
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
        let userNameText = NSLocalizedString("editProfile.name", comment: "")
        
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
        let userDescriptionText = NSLocalizedString("editProfile.description", comment: "")
        
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
        let userWebsiteText = NSLocalizedString("editProfile.website", comment: "")
        
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
    private let saveButton: UIButton = {
        let saveButton = UIButton(type: .custom)
        let titleOfSaveButton = NSLocalizedString("editProfile.photo.save", comment: "")
        saveButton.backgroundColor = .segmentActive
        saveButton.titleLabel?.font = .bodyBold
        saveButton.setTitle(titleOfSaveButton, for: .normal)
        saveButton.setTitleColor(.forViewBackground, for: .normal)
        saveButton.layer.cornerRadius = 16
        saveButton.clipsToBounds = true
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            saveButton.heightAnchor.constraint(equalToConstant: 60),
            saveButton.widthAnchor.constraint(equalToConstant: 343)
        ])
        
        return saveButton
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
        
        addTargetsAndDelegates()
        addSubviews()
        bindViewModel()
        
        insertDataIntoFields(userInfo: viewModel.profileData)
    }
    
    // MARK: - Private Methods
    @objc private func changePhoto() {
        showActionSheetWhenClickingToPhoto()
    }
    
    @objc private func textForAvatarURLDidChange(_ textField: UITextField) {
        let text = textField.text ?? ""
        okAction?.isEnabled = !text.trimmingCharacters(in: .whitespaces).isEmpty
    }
    
    @objc private func textDidChange(_ textField: UITextField) {
        switch textField {
        case userNameTextField:
            self.viewModel.updateName(textField.text)
        case userWebsiteTextField:
            self.viewModel.updateWebsite(textField.text)
        default:
            break
        }
    }
    
    private func insertDataIntoFields(userInfo: ProfileViewData?) {
        setImageToUserAvatar(avatarURL: userInfo?.avatarURL)
        userNameTextField.text = userInfo?.name
        userDescriptionTextView.text = userInfo?.description
        userWebsiteTextField.text = userInfo?.websiteURL?.absoluteString
    }
    
    private func addTargetsAndDelegates() {
        //Добавил делегат для текстового поля userDescriptionTextView
        userDescriptionTextView.delegate = self
        
        userAvatarImageButton.addTarget(self, action: #selector(changePhoto), for: .touchUpInside)
        cameraButton.addTarget(self, action: #selector(changePhoto), for: .touchUpInside)
        userNameTextField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
        userWebsiteTextField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
    }
    
    private func addSubviews() {
        [userAvatarImageButton, cameraButton, userNameLabel, userNameTextField, userDescriptionLabel, userDescriptionTextView, userWebsiteLabel, userWebsiteTextField, saveButton].forEach {
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
            userWebsiteTextField.heightAnchor.constraint(equalToConstant: 44),
            
            saveButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            saveButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])
    }
    
    private func setImageToUserAvatar(avatarURL: URL?) {
        guard let url = avatarURL else {
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
        
        viewModel.$isSaveButtonVisible
            .receive(on: RunLoop.main)
            .sink { [weak self] isVisible in
                self?.saveButton.isHidden = !isVisible
            }
            .store(in: &cancellables)
    }
    
    private func showActionSheetWhenClickingToPhoto() {
        let titleOfActionSheet = NSLocalizedString("editProfile.photo.title", comment: "")
        let titleOfChangePhotoButton = NSLocalizedString("editProfile.photo.change", comment: "")
        let titleOfDeletePhotoButton = NSLocalizedString("editProfile.photo.delete", comment: "")
        let titleOfCancelButton = NSLocalizedString("common.cancel", comment: "")
        
        let actionSheet = UIAlertController(title: titleOfActionSheet, message: nil, preferredStyle: .actionSheet)
        
        let changePhotoAction = UIAlertAction(
            title: titleOfChangePhotoButton,
            style: .default,
            handler: { _ in
                self.showAlertWhenChangingURLOfProfileImage()
        })
        let deletePhotoAction = UIAlertAction(
            title: titleOfDeletePhotoButton,
            style: .destructive,
            handler: { _ in
                self.viewModel.updateAvatar(newAvatar: "")
                self.userAvatarImageButton.setImage(Constants.defaultImage, for: .normal)
        })
        let cancelAction = UIAlertAction(
            title: titleOfCancelButton,
            style: .cancel
        )
        
        [changePhotoAction, deletePhotoAction, cancelAction].forEach {
            actionSheet.addAction($0)
        }
        present(actionSheet, animated: true)
    }
    
    private func showAlertWhenChangingURLOfProfileImage() {
        let titleOfCancelButton = NSLocalizedString("common.cancel", comment: "")
        let titleOfSaveButton = NSLocalizedString("editProfile.photo.save", comment: "")
        let titleOfAlert = NSLocalizedString("editProfile.photo.linkTitle", comment: "")
        
        let alert = UIAlertController(
            title: titleOfAlert,
            message: nil,
            preferredStyle: .alert)
        
        alert.addTextField { textField in
            textField.placeholder = "http://..."
            
            textField.addTarget(self, action: #selector(self.textForAvatarURLDidChange(_:)), for: .editingChanged)
        }
        
        let cancelAction = UIAlertAction(
            title: titleOfCancelButton,
            style: .cancel)
        let saveAction = UIAlertAction(
            title: titleOfSaveButton,
            style: .default,
            handler: { _ in
                guard let text = alert.textFields?.first?.text else { return }
                
                self.viewModel.updateAvatar(newAvatar: alert.textFields?.first?.text)
                self.setImageToUserAvatar(avatarURL: URL(string: text))
            })
        saveAction.isEnabled = false
        
        alert.addAction(cancelAction)
        alert.addAction(saveAction)
        
        self.okAction = saveAction
        present(alert, animated: true)
    }
}

extension EditProfileViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        self.viewModel.updateDescription(textView.text)
    }
}
