import UIKit
import Combine

final class EditProfileViewController: UIViewController {
    
    // MARK: - Private Properties
    private let viewModel: EditProfileViewModel
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Views (elements)
    private let userAvatarImageButton: UIButton = {
        let exampleImage = UIImage(systemName: "person.crop.circle.fill")
        let userAvatarImageButton = UIButton(type: .system)
        userAvatarImageButton.setImage(exampleImage, for: .normal)
        userAvatarImageButton.layer.cornerRadius = 35
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
        userAvatarImageButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            userAvatarImageButton.heightAnchor.constraint(equalToConstant: 22.57),
            userAvatarImageButton.widthAnchor.constraint(equalToConstant: 22.57)
        ])
        
        return userAvatarImageButton
    }()
    
    // MARK: - Initializers
    init(viewModel: EditProfileViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        nil
    }
    
    // MARK: - Private Methods
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

