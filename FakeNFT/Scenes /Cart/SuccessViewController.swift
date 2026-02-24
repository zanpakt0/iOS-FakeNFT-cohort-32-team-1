import UIKit

enum SuccessViewLayout {
    static let imageViewTop: CGFloat = 196
    static let imageViewSizes: CGFloat = 278
    static let labelTextTop: CGFloat = 20
    static let labelTextLeading: CGFloat = 35
    static let labelTextTrailing: CGFloat = -36
    static let buttonToCartLeading: CGFloat = 16
    static let buttonToCartTrailing: CGFloat = -16
    static let buttonToCartBottom: CGFloat = -16
    static let buttonToCartHeight: CGFloat = 60
}
enum SuccessViewStyle {
    static let buttonToCartCornerRadius: CGFloat = 16
    static let titleFont: UIFont = .systemFont(ofSize: 22, weight: .bold)
    static let buttonFont: UIFont = .systemFont(ofSize: 17, weight: .bold)
}

final class SuccessViewController: UIViewController {
    
    private let paymentService: PaymentService
    init(paymentService: PaymentService) {
        self.paymentService = paymentService
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let imageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "56_digital_art_x4"))
        imageView.tintColor = .clear
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    private let labelText: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("cart.successMessage", comment: "")
        label.font = SuccessViewStyle.titleFont
        label.numberOfLines = 2
        label.textAlignment = .center
        return label
    }()
    private let buttonToCart: UIButton = {
        let button = UIButton()
        button.setTitle(NSLocalizedString("cart.returnButton", comment: ""), for: .normal)
        button.backgroundColor = .segmentButtonBackground
        button.layer.cornerRadius = SuccessViewStyle.buttonToCartCornerRadius
        button.setTitleColor(.segmentButtonText, for: .normal)
        button.titleLabel?.font = SuccessViewStyle.buttonFont
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
            
            imageView.topAnchor.constraint(equalTo: view.topAnchor, constant: SuccessViewLayout.imageViewTop),
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.widthAnchor.constraint(equalToConstant: SuccessViewLayout.imageViewSizes),
            imageView.heightAnchor.constraint(equalToConstant: SuccessViewLayout.imageViewSizes),
            
            labelText.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: SuccessViewLayout.labelTextTop),
            labelText.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: SuccessViewLayout.labelTextLeading),
            labelText.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: SuccessViewLayout.labelTextTrailing),
            
            buttonToCart.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: SuccessViewLayout.buttonToCartLeading),
            buttonToCart.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: SuccessViewLayout.buttonToCartTrailing),
            buttonToCart.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: SuccessViewLayout.buttonToCartBottom),
            buttonToCart.heightAnchor.constraint(equalToConstant: SuccessViewLayout.buttonToCartHeight)
        ])
    }
    
    @objc private func didTapBack() {
        tabBarController?.selectedIndex = 1
        if let nav = tabBarController?.viewControllers?[1] as? UINavigationController,
           let cartVC = nav.viewControllers.first as? CartViewController {
            
            let allIds = cartVC.cartViewModel.items.map { $0.id }
            
            let group = DispatchGroup()
            
            for id in allIds {
                group.enter()
                paymentService.deleteAllNFT(id: id) { _ in
                    group.leave()
                }
            }
            
            group.notify(queue: .main) {
                cartVC.clearCart()
                cartVC.updateEmptyStateUI()
                nav.popToRootViewController(animated: true)
            }
        }
    }
}
