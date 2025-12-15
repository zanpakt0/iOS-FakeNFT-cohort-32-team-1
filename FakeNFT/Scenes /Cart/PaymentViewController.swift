import UIKit
import ProgressHUD

final class PaymentViewController: UIViewController {
    
    private let viewModel: PaymentViewModel
    private let collectionView: UICollectionView
    private let bottomView = UIView()
    private let payButton = UIButton(type: .system)
    private let termsTextView: UITextView = {
        let tv = UITextView()
        tv.isEditable = false
        tv.isScrollEnabled = false
        tv.backgroundColor = .clear
        tv.font = .systemFont(ofSize: 13, weight: .regular)
        tv.textColor = .segmentButtonBackground
        tv.isUserInteractionEnabled = true
        return tv
    }()
    
    init(paymentService: PaymentService, nftIds: [String]) {
        self.viewModel = PaymentViewModel(paymentService: paymentService, nftIds: nftIds)
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 7
        layout.minimumLineSpacing = 7
        self.collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupNav()
        setupCollection()
        setupBottomView()
        setupTerms()
        setupPayButton()
        bindViewModel()
        
        ProgressHUD.show()
        viewModel.loadCurrencies()
    }
    
    private func setupNav() {
        let backButton = UIBarButtonItem(image: UIImage(systemName: "chevron.left"),
                                         style: .plain,
                                         target: self,
                                         action: #selector(back))
        backButton.tintColor = .segmentButtonBackground
        navigationItem.leftBarButtonItem = backButton
        
        let titleLabel = UILabel()
        titleLabel.text = NSLocalizedString("Choose a payment method", comment: "")
        titleLabel.font = .boldSystemFont(ofSize: 17)
        titleLabel.textColor = .segmentButtonBackground
        titleLabel.textAlignment = .center
        navigationItem.titleView = titleLabel
    }
    
    @objc private func back() { navigationController?.popViewController(animated: true) }
    
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
            bottomView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            bottomView.heightAnchor.constraint(equalToConstant: 186)
        ])
    }
    
    private func setupTerms() {
        let fullText = NSLocalizedString("By making a purchase, you agree to the terms of the User Agreement", comment: "")
        let highlightText = NSLocalizedString("User Agreement", comment: "")
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.minimumLineHeight = 18
        paragraphStyle.maximumLineHeight = 18
        
        let attributedString = NSMutableAttributedString(
            string: fullText,
            attributes: [
                .paragraphStyle: paragraphStyle,
                .kern: -0.08,
                .font: UIFont.systemFont(ofSize: 13),
                .foregroundColor: UIColor.segmentButtonBackground
            ]
        )
        
        let termsRange = (fullText as NSString).range(of: highlightText)
        attributedString.addAttribute(.link, value: "https://yandex.ru/legal/practicum_termsofuse", range: termsRange)
        
        termsTextView.attributedText = attributedString
        termsTextView.isEditable = false
        termsTextView.isSelectable = true
        termsTextView.isScrollEnabled = false
        termsTextView.backgroundColor = .clear
        termsTextView.textContainerInset = .zero
        termsTextView.linkTextAttributes = [.foregroundColor: UIColor.systemBlue]
        
        view.addSubview(termsTextView)
        termsTextView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            termsTextView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            termsTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            termsTextView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -100)
        ])
        
        termsTextView.delegate = self
    }
    
    private func setupPayButton() {
        payButton.setTitle(NSLocalizedString("Pay", comment: ""), for: .normal)
        payButton.titleLabel?.font = .systemFont(ofSize: 17, weight: .bold)
        payButton.backgroundColor = .segmentButtonBackground
        payButton.tintColor = .segmentButtonText
        payButton.layer.cornerRadius = 16
        payButton.addTarget(self, action: #selector(didTapPay), for: .touchUpInside)
        view.addSubview(payButton)
        payButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            payButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            payButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -12),
            payButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            payButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    private func bindViewModel() {
        viewModel.onItemsLoaded = { [weak self] in
            DispatchQueue.main.async {
                ProgressHUD.dismiss()
                self?.collectionView.reloadData()
            }
        }
        
        viewModel.onSuccess = { [weak self] in
            DispatchQueue.main.async {
                ProgressHUD.dismiss()
                self?.navigationController?.pushViewController(SuccessViewController(), animated: true)
            }
        }
        
        viewModel.onError = { error in
            DispatchQueue.main.async {
                ProgressHUD.dismiss()
            }
        }
    }
    
    @objc private func didTapPay() {
        ProgressHUD.show()
        viewModel.pay()
    }
}

extension PaymentViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel.items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PaymentCell.reuseIdentifier, for: indexPath) as? PaymentCell else {
            return UICollectionViewCell()
        }
        cell.configure(with: viewModel.items[indexPath.item])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        viewModel.selectItem(at: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.frame.width - 7) / 2
        return CGSize(width: width, height: 46)
    }
}

extension PaymentViewController: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange) -> Bool {
        let webVC = WebViewViewController(urlString: URL.absoluteString)
        navigationController?.pushViewController(webVC, animated: true)
        return false
    }
}
