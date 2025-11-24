import UIKit

final class CatalogViewController: UIViewController {
    
    private lazy var sortButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(resource: .sortButton), for: .normal)
        button.tintColor = .segmentActive
        button.imageView?.contentMode = .scaleAspectFit
        button.addTarget(self, action: #selector(sortButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.background
        setupSortButton()
    }
    
    func setupSortButton() {
        view.addSubview(sortButton)
        
        NSLayoutConstraint.activate([
            sortButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            sortButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -9),
            sortButton.heightAnchor.constraint(equalToConstant: 42),
            sortButton.widthAnchor.constraint(equalToConstant: 42)
        ])
    }
    
    @objc func sortButtonTapped() {
        print("Sort Button Tapped")
    }
}
