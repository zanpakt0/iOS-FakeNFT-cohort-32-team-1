//
//  PaymentViewController.swift
//  FakeNFT
//
//  Created by Svetlana Varenova on 04.12.2025.
//

import UIKit

final class PaymentViewController: UIViewController {
    
    private let viewModel = PaymentViewModel()
    private let titleLabel = UILabel()
    private let collectionView: UICollectionView
    private let bottomView = UIView()
    private let payButton = UIButton(type: .system)
    private let termsLabel = UILabel()
    
    init() {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 7
        layout.minimumLineSpacing = 7
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        setupNav()
        setupCollection()
        setupBottomView()
        setupTerms()
        setupPayButton()
    }
    
    private func setupNav() {
        let backButton = UIBarButtonItem(
            image: UIImage(systemName: "chevron.left"),
            style: .plain,
            target: self,
            action: #selector(back)
        )
        backButton.tintColor = .segmentButtonBackground
        navigationItem.leftBarButtonItem = backButton
        
        let titleLabel = UILabel()
        titleLabel.text = NSLocalizedString("Choose a payment method", comment: "")
        titleLabel.font = .systemFont(ofSize: 17, weight: .bold)
        titleLabel.textColor = .segmentButtonBackground
        titleLabel.textAlignment = .center
        
        navigationItem.titleView = titleLabel
    }
    
    @objc private func back() {
        navigationController?.popViewController(animated: true)
    }
    
    private func setupCollection() {
        collectionView.register(PaymentCell.self, forCellWithReuseIdentifier: PaymentCell.reuseIdentifier)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .clear
        
        view.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -150)
        ])
    }
    
    private func setupBottomView() {
        bottomView.backgroundColor = .segmentPayCellBackground
        
        view.addSubview(bottomView)
        bottomView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            bottomView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            bottomView.heightAnchor.constraint(equalToConstant: 186)
        ])
    }
    
    private func setupTerms() {
        termsLabel.text = "Совершая покупку, вы соглашаетесь с условиями Пользовательского соглашения"
        
        termsLabel.font = .systemFont(ofSize: 13, weight: .regular)
        termsLabel.numberOfLines = 2
        termsLabel.textColor = .segmentButtonBackground
        
        view.addSubview(termsLabel)
        termsLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            termsLabel.topAnchor.constraint(equalTo: bottomView.topAnchor, constant: 16),
            termsLabel.leadingAnchor.constraint(equalTo: bottomView.leadingAnchor, constant: 16),
            termsLabel.trailingAnchor.constraint(equalTo: bottomView.trailingAnchor, constant: -16)
        ])
    }
    
    private func setupPayButton() {
        payButton.setTitle(NSLocalizedString("Pay", comment: ""), for: .normal)
        payButton.titleLabel?.font = .systemFont(ofSize: 17, weight: .bold)
        payButton.backgroundColor = .segmentButtonBackground
        payButton.tintColor = .segmentButtonText
        payButton.layer.cornerRadius = 16
        
        view.addSubview(payButton)
        payButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            payButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            payButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -12),
            payButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            payButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
}

extension PaymentViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel.items.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: PaymentCell.reuseIdentifier,
            for: indexPath
        ) as! PaymentCell
        
        cell.configure(with: viewModel.items[indexPath.item])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {
        viewModel.selectItem(at: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width = (collectionView.frame.width - 7) / 2
        return CGSize(width: width, height: 46)
    }
}

#Preview {
    PaymentViewController()
}
