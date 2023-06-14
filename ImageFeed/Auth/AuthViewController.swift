//
//  AuthViewController.swift
//  ImageFeed
//
//  Created by Максим on 16.04.2023.
//

import UIKit


protocol AuthViewControllerDelegate: AnyObject {
    func authViewController(_ vc: AuthViewController, didAuthenticateWithCode code: String)
}

final class AuthViewController: UIViewController {
    //MARK: - Properties
    weak var delegate: AuthViewControllerDelegate?
    private let oAuth2Service = OAuth2Service.shared

    private let ShowWebViewSegueIdentifier = "ShowWebView"
    //MARK: - LifeCircle
    override func viewDidLoad() {
        super.viewDidLoad()
        createAuthViewLayout()
    }

    //MARK: - Methods and UI
    private let authViewLogo: UIImageView = {
        let authLogo = UIImageView()
        authLogo.translatesAutoresizingMaskIntoConstraints = false
        authLogo.image = UIImage(named: "auth_screen_logo")
        authLogo.contentMode = .scaleAspectFill
        return authLogo
    }()

    private let enterButton: UIButton = {
        let enterButton = UIButton()
        enterButton.translatesAutoresizingMaskIntoConstraints = false
        enterButton.backgroundColor = .YPWhite
        enterButton.setTitle("Войти", for: .normal)
        enterButton.accessibilityIdentifier = "enterButton"
        enterButton.setTitleColor(.YPBlack, for: .normal)
        enterButton.titleLabel?.font = .systemFont(ofSize: 17, weight: .bold)
        enterButton.layer.cornerRadius = 16
        enterButton.layer.masksToBounds = true
        enterButton.addTarget(nil, action: #selector(enterButtonTapped), for: .touchUpInside)
        return enterButton
    }()

    @objc func enterButtonTapped() {
        let webViewViewController = WebViewViewController()
        let authHelper = AuthHelper()
        let webViewPresenter = WebViewPresenter(authHelper: authHelper)

        webViewViewController.delegate = self

        webViewViewController.presenter = webViewPresenter
        webViewPresenter.view = webViewViewController

        webViewViewController.modalPresentationStyle = .fullScreen
        present(webViewViewController, animated: true)
    }

    private func createAuthViewLayout() {
        view.backgroundColor = .YPBlack

        view.addSubview(enterButton)
        view.addSubview(authViewLogo)

        NSLayoutConstraint.activate([
            authViewLogo.widthAnchor.constraint(equalToConstant: 60),
            authViewLogo.heightAnchor.constraint(equalToConstant: 60),
            authViewLogo.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            authViewLogo.centerYAnchor.constraint(equalTo: view.centerYAnchor),

            enterButton.heightAnchor.constraint(equalToConstant: 48),
            enterButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            enterButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            enterButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -90)
        ])
    }
}

//MARK: - Extension для AuthViewController
extension AuthViewController: WebViewViewControllerDelegate {

    func webViewViewControllerDidCancel(_ vc: WebViewViewController) {
        dismiss(animated: true)
    }

    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String) {
        delegate?.authViewController(self, didAuthenticateWithCode: code)
    }
}

