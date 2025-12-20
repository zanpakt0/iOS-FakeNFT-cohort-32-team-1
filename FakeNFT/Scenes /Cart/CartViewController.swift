import UIKit
import ProgressHUD

final class CartViewController: UIViewController {
    let cartViewModel: CartViewModel
    private let paymentService: PaymentService
    private let paymentViewModel: PaymentViewModel
    
    init(cartViewModel: CartViewModel, paymentService: PaymentService, paymentViewModel: PaymentViewModel) {
        self.cartViewModel = cartViewModel
        self.paymentService = paymentService
        self.paymentViewModel = paymentViewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) { fatalError()
    }
    
    private let tableView = UITableView()
    private let bottomView = UIView()
    private let countLabel = UILabel()
    private let totalLabel = UILabel()
    private let payButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle(NSLocalizedString("Filter.actionSheet.title.toPay", comment: ""), for: .normal)
        btn.tintColor = UIColor.segmentButtonText
        btn.backgroundColor = UIColor.segmentButtonBackground
        btn.layer.cornerRadius = 18
        btn.titleLabel?.font = .systemFont(ofSize: 18, weight: .bold)
        return btn
    }()
    private let emptyLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("Your cart is empty", comment: "")
        label.font = .systemFont(ofSize: 17, weight: .bold)
        label.textColor = .segmentButtonBackground
        label.textAlignment = .center
        label.isHidden = true
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        payButton.addTarget(self, action: #selector(payButtonTapped), for: .touchUpInside)
        
        setupNavigationBar()
        setupBottom()
        setupTable()
        setupBindings()
        
        ProgressHUD.show()
        cartViewModel.loadCart()
        cartViewModel.updateTotal()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.prefersLargeTitles = true
        
        ProgressHUD.show()
        setupNavigationBar()
        setupBottom()
        setupTable()
        setupBindings()
        cartViewModel.loadCart()
        cartViewModel.updateTotal()
    }
    
    // MARK: - Setup Navigation Bar
    private func setupNavigationBar() {
        let sortButtonItem = UIBarButtonItem(
            image: UIImage(resource: .sortCatalogButton),
            style: .plain,
            target: self,
            action: #selector(sortButtonTapped)
        )
        sortButtonItem.tintColor = UIColor.segmentButtonBackground
        navigationItem.rightBarButtonItem = sortButtonItem
    }
    
    // MARK: - Setup bindings
    private func setupBindings() {
        cartViewModel.onItemsUpdated = { [weak self] in
            guard let self else { return }
            
            self.tableView.reloadData()
            let isEmpty = self.cartViewModel.items.isEmpty
            self.emptyLabel.isHidden = !isEmpty
            self.tableView.isHidden = isEmpty
            self.bottomView.isHidden = isEmpty
            
            ProgressHUD.dismiss()
        }
        
        cartViewModel.onLoadError = { error in
            ProgressHUD.dismiss()
            ProgressHUD.showError("Ошибка загрузки")
        }
        
        cartViewModel.onTotalUpdated = { [weak self] count, total in
            self?.countLabel.text = count
            self?.totalLabel.text = total
        }
    }
    
    @objc private func sortButtonTapped() {
        let priceAction = UIAlertAction(title: "По цене", style: .default) { [weak self] _ in
            self?.cartViewModel.sortByPrice()
        }
        let ratingAction = UIAlertAction(title: "По рейтингу", style: .default) { [weak self] _ in
            self?.cartViewModel.sortByRating()
        }
        let titleAction = UIAlertAction(title: "По названию", style: .default) { [weak self] _ in
            self?.cartViewModel.sortByTitle()
        }
        showFilterActionSheet(firstAction: priceAction, secondAction: ratingAction, thirdAction: titleAction)
    }
    
    // MARK: - Setup Table
    private func setupTable() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(CartTableViewCell.self, forCellReuseIdentifier: CartTableViewCell.reuseIdentifier)
        tableView.separatorStyle = .none
        
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(emptyLabel)
        emptyLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: bottomView.topAnchor),
            
            emptyLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    // MARK: - Setup Bottom
    private func setupBottom() {
        bottomView.backgroundColor = .segmentPayCellBackground
        view.addSubview(bottomView)
        bottomView.addSubview(countLabel)
        bottomView.addSubview(totalLabel)
        bottomView.addSubview(payButton)
        
        bottomView.translatesAutoresizingMaskIntoConstraints = false
        countLabel.translatesAutoresizingMaskIntoConstraints = false
        totalLabel.translatesAutoresizingMaskIntoConstraints = false
        payButton.translatesAutoresizingMaskIntoConstraints = false
        
        countLabel.font = .systemFont(ofSize: 15, weight: .regular)
        totalLabel.font = .systemFont(ofSize: 18, weight: .bold)
        totalLabel.textColor = UIColor.greenUniversal
        
        NSLayoutConstraint.activate([
            bottomView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            bottomView.heightAnchor.constraint(equalToConstant: 76),
            
            countLabel.leadingAnchor.constraint(equalTo: bottomView.leadingAnchor, constant: 16),
            countLabel.topAnchor.constraint(equalTo: bottomView.topAnchor, constant: 18),
            
            totalLabel.leadingAnchor.constraint(equalTo: countLabel.leadingAnchor),
            totalLabel.topAnchor.constraint(equalTo: countLabel.bottomAnchor, constant: 4),
            
            payButton.trailingAnchor.constraint(equalTo: bottomView.trailingAnchor, constant: -16),
            payButton.topAnchor.constraint(equalTo: bottomView.topAnchor, constant: 16),
            payButton.widthAnchor.constraint(equalToConstant: 240),
            payButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    @objc private func payButtonTapped() {
        let paymentVC = PaymentViewController(
            paymentService: paymentService,
            nftIds: cartViewModel.items.map { $0.id }
        )
        navigationController?.pushViewController(paymentVC, animated: true)
    }
    
    func clearCart() {
        self.cartViewModel.removeItemAll()
        self.cartViewModel.onItemsUpdated?()
    }
    
    func updateEmptyStateUI() {
        tableView.isHidden = true
        bottomView.isHidden = true
        navigationItem.rightBarButtonItem = nil
        emptyLabel.isHidden = false
    }
}

// MARK: - TableView
extension CartViewController: UITableViewDataSource, UITableViewDelegate, CartTableViewCellDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        cartViewModel.numberOfItems()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        140
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: CartTableViewCell.reuseIdentifier,
            for: indexPath
        ) as? CartTableViewCell else {
            return UITableViewCell()
        }
        
        let item = cartViewModel.item(at: indexPath.row)
        cell.configure(with: item)
        cell.delegate = self
        return cell
    }
    
    func cartCell(_ cell: CartTableViewCell, didChangeRating rating: Int) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        cartViewModel.updateRating(at: indexPath.row, rating: rating)
    }
    
    func cartCellDidTapDelete(_ cell: CartTableViewCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        let item = cartViewModel.item(at: indexPath.row)
        let itemId = item.id
        
        let vc = DeleteModalViewController(
            imageURL: item.imageUrl,
            title: item.title
        ) { [weak self] finish in
            guard let self else { return }
            
            cartViewModel.deleteNFT(id: itemId) { success in
                if success {
                    self.cartViewModel.removeItem(id: itemId)
                    finish(true)
                    if self.cartViewModel.numberOfItems() == 0 {
                        self.updateEmptyStateUI()
                    }
                } else {
                    self.showError(
                        ErrorModel(
                            message: NSLocalizedString("Не удалось удалить NFT", comment: ""),
                            actionText: NSLocalizedString("Ок", comment: ""),
                            action: {}
                        )
                    )
                    finish(false)
                }
            }
        }
        
        vc.modalPresentationStyle = .overFullScreen
        vc.modalTransitionStyle = .crossDissolve
        present(vc, animated: true)
    }
}
