//
//  SuccessViewController.swift
//  FakeNFT
//
//  Created by Svetlana Varenova on 04.12.2025.
//

import UIKit

final class SuccessViewController: UIViewController {
    
    private let imageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "56_digital_art_x4"))
        imageView.tintColor = .clear
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    private let labelText: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("Success! Your payment has been completed. Congratulations on your purchase!", comment: "")
        label.font = .systemFont(ofSize: 22, weight: .bold)
        label.numberOfLines = 2
        label.textAlignment = .center
        return label
    }()
    private let buttonToCart: UIButton = {
        let button = UIButton()
        button.setTitle(NSLocalizedString("Return to Cart", comment: ""), for: .normal)
        button.backgroundColor = .segmentButtonBackground
        button.layer.cornerRadius = 16
        button.setTitleColor(.segmentButtonText, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .bold)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        setupUI()
        
        navigationItem.hidesBackButton = true
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        
        buttonToCart.addTarget(self, action: #selector(didTapBack), for: .touchUpInside)
    }
    
    private func setupUI() {
        view.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(labelText)
        labelText.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(buttonToCart)
        buttonToCart.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            
            imageView.topAnchor.constraint(equalTo: view.topAnchor, constant: 196),
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.widthAnchor.constraint(equalToConstant: 278),
            imageView.heightAnchor.constraint(equalToConstant: 278),
            
            labelText.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 20),
            labelText.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 35),
            labelText.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -36),
            
            buttonToCart.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            buttonToCart.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            buttonToCart.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            buttonToCart.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    @objc private func didTapBack() {
        tabBarController?.selectedIndex = 1
        if let nav = tabBarController?.viewControllers?[1] as? UINavigationController,
           let cartVC = nav.viewControllers.first as? CartViewController {
            cartVC.clearCart()
            cartVC.updateEmptyStateUI()
            nav.popToRootViewController(animated: true)
        }
        navigationController?.popViewController(animated: true)
    }
}

#Preview {
    SuccessViewController()
}
