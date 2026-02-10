import UIKit
import WebKit

final class WebViewViewController: UIViewController {
    
    private let webView: WKWebView = {
        let webView = WKWebView()
        return webView
    }()
    
    private let progressView: UIProgressView = {
        let progressView = UIProgressView(progressViewStyle: .default)
        progressView.translatesAutoresizingMaskIntoConstraints = false
        progressView.progressTintColor = .closeButton
        progressView.trackTintColor = .clear
        progressView.isHidden = true
        return progressView
    }()
    
    private var progressObserver: NSKeyValueObservation?
    
    private var urlString: String
    
    init(urlString: String) {
        self.urlString = urlString
        super .init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .forViewBackground
        
        navigationController?.navigationBar.tintColor = .closeButton
        
        setupWebView()
        setupProgressView()
        observeLoadingProgress()
        loadPage()
    }
    
    private func setupWebView() {
        webView = WKWebView(frame: .zero)
        view.addSubview(webView)
        
        webView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            webView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
        ])
    }
    
    private func setupProgressView() {
        view.addSubview(progressView)
        
        NSLayoutConstraint.activate([
            progressView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            progressView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            progressView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            progressView.heightAnchor.constraint(equalToConstant: 2)
        ])
    }
    
    private func observeLoadingProgress() {
        progressObserver = webView.observe(
            \.estimatedProgress,
             options: [.new]
        ) { [weak self] webView, _ in
            guard let self = self else { return }
            
            let progress = Float(webView.estimatedProgress)
            self.progressView.isHidden = false
            self.progressView.setProgress(progress, animated: true)
            
            if progress >= 1.0 {
                UIView.animate(withDuration: 0.3, delay: 0.2, options: .curveEaseOut) {
                    self.progressView.alpha = 0
                } completion: { _ in
                    self.progressView.isHidden = true
                    self.progressView.alpha = 1
                    self.progressView.progress = 0
                }
            }
        }
    }
    
    private func loadPage() {
        let urlString = self.urlString
        guard let url = URL(string: urlString) else { return }
        webView.load(URLRequest(url: url))
    }
}

