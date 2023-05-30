//
//  WebViewViewController.swift
//  ImageFeed
//
//  Created by Максим on 16.04.2023.
//

import WebKit
import UIKit




protocol WebViewViewControllerDelegate: AnyObject {
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String)
    func webViewViewControllerDidCancel(_ vc: WebViewViewController)
}

//MARK: - WebViewViewController
final class WebViewViewController: UIViewController {

    private var estimatedProgressObservation: NSKeyValueObservation?
    weak var delegate: WebViewViewControllerDelegate?

    //MARK: - UISetUP
    private let webView: WKWebView = {
        let webView = WKWebView()
        webView.translatesAutoresizingMaskIntoConstraints = false
        return webView
    }()

    private let progressView: UIProgressView = {
        let progressView = UIProgressView()
        progressView.translatesAutoresizingMaskIntoConstraints = false
        let backgroundColor = UIColor(red: 26/255, green: 27/255, blue: 34/255, alpha: 0.5)
        progressView.tintColor = backgroundColor
        return progressView
    }()

    private let backButton: UIButton = {
        let backButton = UIButton()
        backButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.setTitle("", for: .normal)
        backButton.setImage(UIImage(named: "nav_back_button"), for: .normal)
        backButton.imageView?.contentMode = .scaleAspectFill
        backButton.addTarget(nil, action: #selector(didTapBackButton), for: .touchUpInside)
        return backButton
    }()


    //MARK: - ViewLifeCicle
    override func viewDidLoad() {
        super.viewDidLoad()

        createWebViewLayout()

        webView.navigationDelegate = self
        let request = URLRequest(url: createAuthURL())
        webView.load(request)
        configureProgressBarObserver()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }

    //MARK: - Private Methods
    private func updateProgress() {
        progressView.progress = Float(webView.estimatedProgress)
        progressView.isHidden = fabs(webView.estimatedProgress - 1.0) <= 0.0001
    }

    private func createAuthURL() -> URL {
        var urlComponents = URLComponents(string: "https://unsplash.com/oauth/authorize")!
        urlComponents.queryItems = [
            URLQueryItem(name: "client_id", value: accessKey),
            URLQueryItem(name: "redirect_uri", value: redirectURI),
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "scope", value: accessScope)
        ]
        let url  = urlComponents.url!
        return url
    }

    private func configureProgressBarObserver() {        // Обновление шкалы загрузки
        estimatedProgressObservation = webView.observe(
            \.estimatedProgress,
             options: [],
             changeHandler: {[weak self] _, _ in
                 guard let self = self else {return}
                 self.updateProgress()
             })
    }

    private func createWebViewLayout() {
        view.backgroundColor = .white

        view.addSubview(webView)
        view.addSubview(backButton)
        view.addSubview(progressView)

        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            webView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            webView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),

            backButton.widthAnchor.constraint(equalToConstant: 24),
            backButton.heightAnchor.constraint(equalToConstant: 24),
            backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            backButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),

            progressView.centerYAnchor.constraint(equalTo: backButton.centerYAnchor),
            progressView.leadingAnchor.constraint(equalTo: backButton.trailingAnchor, constant: 8),
            progressView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -29)
        ])

    }

        @objc func didTapBackButton(_ sender: Any?) {
        delegate?.webViewViewControllerDidCancel(self)
    }
}

//MARK: - Extension Delegate
extension WebViewViewController: WKNavigationDelegate {
    func webView(
        _ webView: WKWebView,
        decidePolicyFor navigationAction: WKNavigationAction,
        decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
    ) {
        if let code = code(from: navigationAction) {
            delegate?.webViewViewController(self, didAuthenticateWithCode: code)
            decisionHandler(.cancel)
        } else {
            decisionHandler(.allow)
        }
    }

    ///функция code(from:) - она возвращает код авторизации, если он получен
    private func code(from navigationAction: WKNavigationAction) -> String? {
        if
            let url = navigationAction.request.url,
            let urlComponents = URLComponents(string: url.absoluteString),
            urlComponents.path == "/oauth/authorize/native",
            let items = urlComponents.queryItems,
            let codeItem = items.first(where: { $0.name == "code" })
        {
            return codeItem.value
        } else {
            return nil
        }
    }
}


