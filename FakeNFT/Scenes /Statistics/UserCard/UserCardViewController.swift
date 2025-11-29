//
//  UserCardViewController.swift
//  FakeNFT
//
//  Created by Muhammed Nurmukhanov on 26.11.2025.
//

import UIKit
import Combine

final class UserCardViewController: UIViewController {
    
    private let viewModel: UserCardViewModel
    private var cancellables = Set<AnyCancellable>()
    
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
        userAvatarImageView.layer.cornerRadius = 35
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
        userDescriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        
        return userDescriptionLabel
    }()
    private lazy var goToUserWebsiteButton: UIButton = {
        let goToUserWebsiteButton = UIButton(type: .custom)
        let titleOfGoToUSerWebsiteButton = NSLocalizedString("UserCard.goToUserWebsiteButton.title", comment: "")
        
        goToUserWebsiteButton.setTitle(titleOfGoToUSerWebsiteButton, for: .normal)
        goToUserWebsiteButton.titleLabel?.font = UIFont.caption1
        goToUserWebsiteButton.titleLabel?.textColor = .segmentActive
        goToUserWebsiteButton.contentHorizontalAlignment = .center
        goToUserWebsiteButton.contentVerticalAlignment = .center
        
        goToUserWebsiteButton.layer.borderWidth = 1
        goToUserWebsiteButton.layer.borderColor = UIColor.segmentActive.cgColor
        
        goToUserWebsiteButton.layer.cornerRadius = 16
        
        return goToUserWebsiteButton
    }()
    private lazy var countOfNftsLabel: UILabel = UILabel()
    private lazy var nftCollectionButton: UIButton = {
        let nftCollectionButton = UIButton(type: .system)
        let titleOfGoToUSerWebsiteButton = NSLocalizedString("UserCard.goToUserWebsiteButton.title", comment: "")
        
        let leftLabel = UILabel()
        leftLabel.text = titleOfGoToUSerWebsiteButton
        leftLabel.font = UIFont.bodyBold
        leftLabel.textColor = .segmentActive
        
        countOfNftsLabel.text = ""
        countOfNftsLabel.font = UIFont.bodyBold
        countOfNftsLabel.textColor = .segmentActive
        
        let stack = UIStackView(arrangedSubviews: [leftLabel, countOfNftsLabel])
        stack.axis = .horizontal
        stack.spacing = 8
        stack.alignment = .center
        
        nftCollectionButton.addSubview(stack)
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        let config = UIImage.SymbolConfiguration(weight: .bold)
        let arrowImage = UIImageView(image: UIImage(systemName: "chevron.right", withConfiguration: config))
        arrowImage.tintColor = .segmentActive
        nftCollectionButton.addSubview(arrowImage)
        arrowImage.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            stack.centerYAnchor.constraint(equalTo: nftCollectionButton.centerYAnchor),
            arrowImage.centerYAnchor.constraint(equalTo: nftCollectionButton.centerYAnchor)
        ])
        
        nftCollectionButton.translatesAutoresizingMaskIntoConstraints = false
        
        return nftCollectionButton
    }()
    
    init(viewModel: UserCardViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .forViewBackgound
        navigationController?.navigationBar.tintColor = .closeButton
        
        addSubviews()
        setupConstraints()
        bindViewModel()
    }
    
    private func addSubviews() {
        view.addSubview(viewWithAllElements)
        
        [userAvatarImageView, userNameLabel, goToUserWebsiteButton, nftCollectionButton].forEach {
            viewWithAllElements.addSubview($0)
        }
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            viewWithAllElements.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            viewWithAllElements.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            viewWithAllElements.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            viewWithAllElements.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            userAvatarImageView.heightAnchor.constraint(equalToConstant: 70),
            userAvatarImageView.widthAnchor.constraint(equalToConstant: 70),
            userAvatarImageView.leadingAnchor.constraint(equalTo: viewWithAllElements.leadingAnchor, constant: 16),
            userAvatarImageView.topAnchor.constraint(equalTo: viewWithAllElements.topAnchor, constant: 20),
            
            userNameLabel.leadingAnchor.constraint(equalTo: userAvatarImageView.trailingAnchor, constant: 16),
            userNameLabel.trailingAnchor.constraint(equalTo: viewWithAllElements.trailingAnchor, constant: -16),
            userNameLabel.centerXAnchor.constraint(equalTo: userAvatarImageView.centerXAnchor),
            
            userDescriptionLabel.leadingAnchor.constraint(equalTo: viewWithAllElements.leadingAnchor, constant: 16),
            userDescriptionLabel.trailingAnchor.constraint(equalTo: viewWithAllElements.trailingAnchor, constant: -16),
            userDescriptionLabel.topAnchor.constraint(equalTo: userAvatarImageView.bottomAnchor, constant: 20),
            userDescriptionLabel.heightAnchor.constraint(equalToConstant: 72),
            
            goToUserWebsiteButton.leadingAnchor.constraint(equalTo: viewWithAllElements.leadingAnchor, constant: 16),
            goToUserWebsiteButton.trailingAnchor.constraint(equalTo: viewWithAllElements.trailingAnchor, constant: -16),
            goToUserWebsiteButton.topAnchor.constraint(equalTo: userDescriptionLabel.bottomAnchor, constant: 28),
            goToUserWebsiteButton.heightAnchor.constraint(equalToConstant: 40),
            
            nftCollectionButton.leadingAnchor.constraint(equalTo: viewWithAllElements.leadingAnchor, constant: 16),
            nftCollectionButton.trailingAnchor.constraint(equalTo: viewWithAllElements.trailingAnchor, constant: -16),
            nftCollectionButton.topAnchor.constraint(equalTo: goToUserWebsiteButton.bottomAnchor, constant: 57),
            nftCollectionButton.heightAnchor.constraint(equalToConstant: 22)
        ])
    }
    
    private func bindViewModel() {
        viewModel.$state
            .receive(on: RunLoop.main)
            .sink { [weak self] state in
                guard let self = self else { return }
                
                switch state {
                case .idle:
                    break
                case .loading:
                    break
                case .loaded(let user):
                    break
                case .error(_):
                    break
                }
            }
            .store(in: &cancellables)
    }
}
