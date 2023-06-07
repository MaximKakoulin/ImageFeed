//
//  SplashViewController.swift
//  ImageFeed
//
//  Created by Максим on 01.05.2023.
//

import UIKit
import ProgressHUD




final class SplashViewController: UIViewController {
    private let showAuthenticationScreenSegueIdentifier = "ShowAuthenticationScreen"
    private let tokenStorage = OAuth2TokenStorage()
    private let oauth2Service = OAuth2Service()
    private let profileService = ProfileService.shared
    private let profileImageService = ProfileImageService.shared

    private var splashLogoImage: UIImageView!

    //MARK: - LifeCycle
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        createSplashLogoImage(safeArea: view.safeAreaLayoutGuide)

        if let token = tokenStorage.token {
            fetchProfile(token: token)
        } else {
            presentAuthViewController()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNeedsStatusBarAppearanceUpdate()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }

    //MARK: - Methods
    func switchToTabBarController() {
        guard let window = UIApplication.shared.windows.first else {
            assertionFailure("Invalid config")
            showAlertViewController()
            return
        }

        let tabBarController = TabBarController()
        window.rootViewController = tabBarController
    }

    private func presentAuthViewController() {           // Переход на AuthViewController
        let authViewController = AuthViewController()
        authViewController.delegate = self
        authViewController.modalPresentationStyle = .fullScreen
        present(authViewController, animated: true, completion: nil)
    }
}

//MARK: - Create splash logo image
extension SplashViewController {
    private func createSplashLogoImage(safeArea: UILayoutGuide) {
        view.backgroundColor = .YPBlack
        splashLogoImage = UIImageView()
        splashLogoImage.image = UIImage(named: "splash_screen_logo")
        splashLogoImage.contentMode = .scaleToFill
        splashLogoImage.clipsToBounds = true

        splashLogoImage.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(splashLogoImage)

        NSLayoutConstraint.activate([
            splashLogoImage.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            splashLogoImage.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
}

//MARK: - Delegate
extension SplashViewController: AuthViewControllerDelegate {
    func authViewController(_ vc: AuthViewController, didAuthenticateWithCode code: String) {
        dismiss(animated: true) { [weak self] in
            guard let self = self else { return }
            self.fetchOAuthToken(code)
        }
        UIBlockingProgressHUD.show()
    }

    private func fetchOAuthToken(_ code: String) {
        oauth2Service.fetchOAuthToken(code) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success (let token):
                self.fetchProfile(token: token)
            case .failure:
                showAlertViewController()
                break
            }
            UIBlockingProgressHUD.dismiss()
        }
    }

    private func fetchProfile(token: String) {
        profileService.fetchProfile(token) {[weak self] result in
            DispatchQueue.main.async {
                guard let self = self else {return}
                switch result {
                case .success (let result):
                    self.profileImageService.fetchProfileImageURL(userName: result.userName) { _ in }
                    self.switchToTabBarController()
                case .failure:
                    self.showAlertViewController()
                    break
                }
                UIBlockingProgressHUD.dismiss()
            }
        }
    }

    private func showAlertViewController() {
        let alertVC = UIAlertController(
            title: "Что-то пошло не так",
            message: "Не удалось войти в систему",
            preferredStyle: .alert
        )
        let action = UIAlertAction(title: "OK", style: .default)
        alertVC.addAction(action)
    }
}

