//
//  StatisticsTableViewCell.swift
//  FakeNFT
//
//  Created by Muhammed Nurmukhanov on 23.11.2025.
//

import UIKit
import Kingfisher

// MARK: - Need enums
enum StatisticsTableViewCellLayout {
    static let containerBottom: CGFloat = -8

    static let numberingLabelTop: CGFloat = 30
    static let numberingLabelBottom: CGFloat = -30
    static let numberingLabelTrailing: CGFloat = -8

    static let avatarLeading: CGFloat = 16
    static let avatarVerticalPadding: CGFloat = 26
    static let avatarWidth: CGFloat = 28

    static let userNameTrailing: CGFloat = 8
    static let userNameWidth: CGFloat = 186
    
    static let nftCountTrailing: CGFloat = -16
    static let nftCountWidth: CGFloat = 38
    
    static let usersInfoViewWidth: CGFloat = 343
    static let heightOfViewsInUsersInfoView: CGFloat = 28
    static let topAnchorOfViewsInUsersInfoView: CGFloat = 26
    static let bottomAnchorOfViewsInUsersInfoView: CGFloat = -26
}

final class StatisticsTableViewCell: UITableViewCell {
    
    // MARK: - Static properties
    static let reuseIdentifier = "StatisticsTableViewCell"
    
    // MARK: - Views (elements)
    private let containerView: UIView = {
        let containerview = UIView()
        containerview.layer.cornerRadius = 12
        containerview.backgroundColor = .forViewBackgound
        containerview.translatesAutoresizingMaskIntoConstraints = false
        return containerview
    }()
    private lazy var numberingLabel: UILabel = {
        let numberingLabel = UILabel()
        numberingLabel.font = UIFont.caption1
        numberingLabel.textColor = .segmentActive
        numberingLabel.backgroundColor = .forViewBackgound
        numberingLabel.translatesAutoresizingMaskIntoConstraints = false
        
        return numberingLabel
    }()
    private lazy var usersInfoView: UIView = {
        let usersInfoView = UIView()
        usersInfoView.backgroundColor = .segmentInactive
        usersInfoView.layer.cornerRadius = 12
        usersInfoView.translatesAutoresizingMaskIntoConstraints = false
        
        return usersInfoView
    }()
    private lazy var userAvatarImageView: UIImageView = {
        let exampleImage = UIImage(systemName: "person.crop.circle.fill")
        let userAvatarImageView = UIImageView(image: exampleImage)
        userAvatarImageView.clipsToBounds = true
        userAvatarImageView.layer.cornerRadius = 14
        userAvatarImageView.translatesAutoresizingMaskIntoConstraints = false
        
        return userAvatarImageView
    }()
    private lazy var userNameLabel: UILabel = {
        let userNameLabel = UILabel()
        userNameLabel.font = UIFont.headline3
        userNameLabel.textColor = .segmentActive
        userNameLabel.backgroundColor = .segmentInactive
        userNameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        return userNameLabel
    }()
    private lazy var countOfNftsLabel: UILabel = {
        let countOfNftsLabel = UILabel()
        countOfNftsLabel.font = UIFont.headline3
        countOfNftsLabel.textColor = .segmentActive
        countOfNftsLabel.backgroundColor = .segmentInactive
        countOfNftsLabel.translatesAutoresizingMaskIntoConstraints = false
        
        return countOfNftsLabel
    }()
    
    // MARK: - Initializers
    override init(style: StatisticsTableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = .forViewBackgound
        
        addSubviews()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public Methods
    func configure(numberingOfCell: Int, with usersInfo: UserCellViewData) {
        self.numberingLabel.text = "\(numberingOfCell)"
        let processor = RoundCornerImageProcessor(cornerRadius: 14)
        let defaultImage = UIImage(systemName: "person.crop.circle.fill")?
            .withTintColor(UIColor.forDefaultAvatarBackgound, renderingMode: .alwaysOriginal)
        guard let url = usersInfo.avatarURL else  {
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
        
        self.userNameLabel.text = usersInfo.name
        self.countOfNftsLabel.text = "\(usersInfo.nfts.count)"
    }
    
    // MARK: - Private Methods
    private func addSubviews() {
        contentView.addSubview(containerView)
        
        [numberingLabel, usersInfoView].forEach {
            containerView.addSubview($0)
        }
        
        [userAvatarImageView, userNameLabel, countOfNftsLabel].forEach {
            usersInfoView.addSubview($0)
        }
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: StatisticsTableViewCellLayout.containerBottom),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            
            usersInfoView.topAnchor.constraint(equalTo: containerView.topAnchor),
            usersInfoView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            usersInfoView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            usersInfoView.widthAnchor.constraint(equalToConstant: StatisticsTableViewCellLayout.usersInfoViewWidth),
            
            numberingLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: StatisticsTableViewCellLayout.numberingLabelTop),
            numberingLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            numberingLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: StatisticsTableViewCellLayout.numberingLabelBottom),
            numberingLabel.trailingAnchor.constraint(equalTo: usersInfoView.leadingAnchor, constant: StatisticsTableViewCellLayout.numberingLabelTrailing),
            
            userAvatarImageView.heightAnchor.constraint(equalToConstant: StatisticsTableViewCellLayout.heightOfViewsInUsersInfoView),
            userAvatarImageView.widthAnchor.constraint(equalToConstant: StatisticsTableViewCellLayout.avatarWidth),
            userAvatarImageView.leadingAnchor.constraint(equalTo: usersInfoView.leadingAnchor, constant: StatisticsTableViewCellLayout.avatarLeading),
            userAvatarImageView.topAnchor.constraint(equalTo: usersInfoView.topAnchor, constant: StatisticsTableViewCellLayout.topAnchorOfViewsInUsersInfoView),
            userAvatarImageView.bottomAnchor.constraint(equalTo: usersInfoView.bottomAnchor, constant: StatisticsTableViewCellLayout.bottomAnchorOfViewsInUsersInfoView),
            
            userNameLabel.leadingAnchor.constraint(equalTo: userAvatarImageView.trailingAnchor, constant: StatisticsTableViewCellLayout.userNameTrailing),
            userNameLabel.heightAnchor.constraint(equalToConstant: StatisticsTableViewCellLayout.heightOfViewsInUsersInfoView),
            userNameLabel.widthAnchor.constraint(equalToConstant: StatisticsTableViewCellLayout.userNameWidth),
            userNameLabel.topAnchor.constraint(equalTo: usersInfoView.topAnchor, constant: StatisticsTableViewCellLayout.topAnchorOfViewsInUsersInfoView),
            userNameLabel.bottomAnchor.constraint(equalTo: usersInfoView.bottomAnchor, constant: StatisticsTableViewCellLayout.bottomAnchorOfViewsInUsersInfoView),
            
            countOfNftsLabel.heightAnchor.constraint(equalToConstant: StatisticsTableViewCellLayout.heightOfViewsInUsersInfoView),
            countOfNftsLabel.widthAnchor.constraint(equalToConstant: StatisticsTableViewCellLayout.nftCountWidth),
            countOfNftsLabel.topAnchor.constraint(equalTo: usersInfoView.topAnchor, constant: StatisticsTableViewCellLayout.topAnchorOfViewsInUsersInfoView),
            countOfNftsLabel.bottomAnchor.constraint(equalTo: usersInfoView.bottomAnchor, constant: StatisticsTableViewCellLayout.bottomAnchorOfViewsInUsersInfoView),
            countOfNftsLabel.trailingAnchor.constraint(equalTo: usersInfoView.trailingAnchor, constant: StatisticsTableViewCellLayout.nftCountTrailing)
        ])
    }
}
