//
//  StatisticsTableViewCell.swift
//  FakeNFT
//
//  Created by Muhammed Nurmukhanov on 23.11.2025.
//

import UIKit
import Kingfisher

final class StatisticsTableViewCell: UITableViewCell {
    
    static let reuseIdentifier = "StatisticsTableViewCell"
    
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
    
    override init(style: StatisticsTableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = .forViewBackgound
        
        addSubviews()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
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
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            
            usersInfoView.topAnchor.constraint(equalTo: containerView.topAnchor),
            usersInfoView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            usersInfoView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            usersInfoView.widthAnchor.constraint(equalToConstant: 343),
            
            numberingLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 30),
            numberingLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            numberingLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -30),
            numberingLabel.widthAnchor.constraint(equalToConstant: 27),
            numberingLabel.heightAnchor.constraint(equalToConstant: 20),
            
            userAvatarImageView.heightAnchor.constraint(equalToConstant: 28),
            userAvatarImageView.widthAnchor.constraint(equalToConstant: 28),
            userAvatarImageView.leadingAnchor.constraint(equalTo: usersInfoView.leadingAnchor, constant: 16),
            userAvatarImageView.topAnchor.constraint(equalTo: usersInfoView.topAnchor, constant: 26),
            userAvatarImageView.bottomAnchor.constraint(equalTo: usersInfoView.bottomAnchor, constant: -26),
            
            userNameLabel.leadingAnchor.constraint(equalTo: userAvatarImageView.trailingAnchor, constant: 8),
            userNameLabel.heightAnchor.constraint(equalToConstant: 28),
            userNameLabel.widthAnchor.constraint(equalToConstant: 186),
            userNameLabel.topAnchor.constraint(equalTo: usersInfoView.topAnchor, constant: 26),
            userNameLabel.bottomAnchor.constraint(equalTo: usersInfoView.bottomAnchor, constant: -26),
            
            countOfNftsLabel.heightAnchor.constraint(equalToConstant: 28),
            countOfNftsLabel.widthAnchor.constraint(equalToConstant: 38),
            countOfNftsLabel.topAnchor.constraint(equalTo: usersInfoView.topAnchor, constant: 26),
            countOfNftsLabel.bottomAnchor.constraint(equalTo: usersInfoView.bottomAnchor, constant: -26),
            countOfNftsLabel.trailingAnchor.constraint(equalTo: usersInfoView.trailingAnchor, constant: -16)
        ])
    }
    
}
