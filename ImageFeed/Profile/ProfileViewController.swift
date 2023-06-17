import Kingfisher
import UIKit
import WebKit


final class ProfileViewController: UIViewController {

    private var nameLabel: UILabel!
    private var loginNameLabel: UILabel!
    private var descriptionLabel: UILabel!
    private var avatarImage: UIImageView!
    private var logoutButton: UIButton!

    private let profileService = ProfileService.shared
    private let profileImageService = ProfileImageService.shared
    private let tokenStorage = OAuth2TokenStorage()

    private var profileImageServiceObserver: NSObjectProtocol? // Объявляем проперти для хранения обсервера
    private var animationLayers = Set<CALayer>()
    override var preferredStatusBarStyle: UIStatusBarStyle { return .lightContent }

    // MARK: - LifeCicle
    override func viewDidLoad() {
        super.viewDidLoad()
        profileUISetup()
    }

    //MARK: - Methods
    private func configureConstraints() {
        NSLayoutConstraint.activate([
            avatarImage.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32),
            avatarImage.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            avatarImage.widthAnchor.constraint(equalToConstant: 70),
            avatarImage.heightAnchor.constraint(equalToConstant: 70),

            nameLabel.topAnchor.constraint(equalTo: avatarImage.bottomAnchor, constant: 20),
            nameLabel.leadingAnchor.constraint(equalTo: avatarImage.leadingAnchor),

            loginNameLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            loginNameLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),

            descriptionLabel.topAnchor.constraint(equalTo: loginNameLabel.bottomAnchor, constant: 8),
            descriptionLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),

            logoutButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            logoutButton.centerYAnchor.constraint(equalTo: avatarImage.centerYAnchor)
        ])
    }

    private func createAvatarImage(safeArea: UILayoutGuide) {
        avatarImage = UIImageView()
        avatarImage.image = UIImage(named: "MockPhoto")
        avatarImage.contentMode = .scaleAspectFill
        avatarImage.clipsToBounds = true

        avatarImage.layer.cornerRadius = 35
        avatarImage.layer.masksToBounds = true
        avatarImage.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(avatarImage)
    }

    private func createNameLabel(safeArea: UILayoutGuide) {
        nameLabel = UILabel()
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(nameLabel)
        nameLabel.text = "Екатерина Новикова"
        nameLabel.accessibilityIdentifier = "NameLabel"
        nameLabel.font = UIFont.systemFont(ofSize: 23, weight: .bold)
        nameLabel.textColor = UIColor.YPWhite
    }

    private func createLoginNameLabel(safeArea: UILayoutGuide) {
        loginNameLabel = UILabel()
        loginNameLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(loginNameLabel)
        loginNameLabel.text = "@nov_ekaterina"
        loginNameLabel.accessibilityIdentifier = "loginNameLabel"
        loginNameLabel.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        loginNameLabel.textColor = UIColor.YPGrey
    }

    private func createDescriptionLabel(safeArea: UILayoutGuide) {
        descriptionLabel = UILabel()
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(descriptionLabel)
        descriptionLabel.text = "Hello, World!"
        descriptionLabel.accessibilityIdentifier = "DescriptionLabel"
        descriptionLabel.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        descriptionLabel.textColor = UIColor.YPWhite
    }

    private func createLogoutButton(safeArea: UILayoutGuide) {
        let logoutButton = UIButton()
        logoutButton.translatesAutoresizingMaskIntoConstraints = false
        logoutButton.setTitle("", for: .normal)
        logoutButton.setImage(UIImage(named: "logout_button"), for: .normal)
        logoutButton.accessibilityIdentifier = "LogoutButton"
        logoutButton.imageView?.contentMode = .scaleAspectFill
        logoutButton.addTarget(nil, action: #selector(logoutButtonTapped), for: .touchUpInside)
        view.addSubview(logoutButton)
        logoutButton.tintColor = .YPRed
        self.logoutButton = logoutButton
    }

    private func profileUISetup() {
        view.backgroundColor = .YPBlack

        createAvatarImage(safeArea: view.safeAreaLayoutGuide)
        createNameLabel(safeArea: view.safeAreaLayoutGuide)
        createLoginNameLabel(safeArea: view.safeAreaLayoutGuide)
        createDescriptionLabel(safeArea: view.safeAreaLayoutGuide)
        createLogoutButton(safeArea: view.safeAreaLayoutGuide)

        configureConstraints()
        updateProfileDetails(profile: profileService.profile)
        updateAvatar()
        subscribeForAvatarUpdates()

        setAvatarGradient()
        setNameGradient()
        setLoginGradient()
        setDescriptionGradient()
    }

    private func updateProfileDetails(profile: Profile?) {
        if let profile = profile {
            nameLabel.text = profile.name
            loginNameLabel.text = profile.loginName
            descriptionLabel.text = profile.bio
        } else {
            nameLabel.text = "Error"
            loginNameLabel.text = "Error"
            descriptionLabel.text = "Error"
        }
    }


    private func updateAvatar() {
        guard let profileImageURL = profileImageService.avatarURL,
              let url = URL(string: profileImageURL)
        else { return }
        let processor = RoundCornerImageProcessor(radius: .point(61))
        avatarImage.kf.setImage(with: url, options: [.processor(processor)]) { [weak self] result in
            switch result {
            case .success:
                self?.removeGradient()
            case .failure:
                self?.avatarImage.image = UIImage(named: "MockPhoto")
            }
        }
    }

    private func subscribeForAvatarUpdates() {
        profileImageServiceObserver = NotificationCenter.default.addObserver(
            forName: ProfileImageService.didChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            guard let self = self else { return }
            self.updateAvatar()
        }
        updateAvatar()
    }

    //MARK: - Алерт по кнопку выхода
    @objc private func logoutButtonTapped() {
        let alert = UIAlertController(title: "Пока, Пока!", message: "Уверены, что хотите выйти?", preferredStyle: .alert)

        let yesAction = UIAlertAction(title: "Да", style: .default) { [weak self] _ in
            guard let self = self else {return}
            self.accountLogout()
        }
        yesAction.accessibilityIdentifier = "yesAction"
        let noAction = UIAlertAction(title: "Нет", style: .cancel, handler: nil)
        alert.addAction(yesAction)
        alert.addAction(noAction)
        present(alert, animated: true, completion: nil)

    }

    //MARK: - Логаут из аккаунта
    private func accountLogout() {
        tokenStorage.deleteToken()
        UIBlockingProgressHUD.show()
        //Чистим куки из хранилища
        HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
        WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
            //Массив полученных записей удаляем из хранилища
            records.forEach { record in
                WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record], completionHandler: {})
            }
        }
        let window = UIApplication.shared.windows.first
        let splashVC = SplashViewController()
        window?.rootViewController = splashVC
        UIBlockingProgressHUD.dismiss()
    }
}

//MARK: - Наводим градиентную красоту
extension ProfileViewController {
    private func setAvatarGradient() {
        let avatarGradient = CAGradientLayer()
        avatarGradient.frame = CGRect(origin: .zero, size: CGSize(width: 70, height: 70))
        avatarGradient.locations = [0, 0.1, 0.3]
        avatarGradient.colors = [
            UIColor(red: 0.682, green: 0.686, blue: 0.706, alpha: 1).cgColor,
            UIColor(red: 0.531, green: 0.533, blue: 0.553, alpha: 1).cgColor,
            UIColor(red: 0.431, green: 0.433, blue: 0.453, alpha: 1).cgColor
        ]
        avatarGradient.startPoint = CGPoint(x: 0, y: 0.5)
        avatarGradient.endPoint = CGPoint(x: 1, y: 0.5)
        avatarGradient.cornerRadius = 35
        avatarGradient.masksToBounds = true
        animationLayers.insert(avatarGradient)
        avatarImage.layer.addSublayer(avatarGradient)

        let gradientChangeAnimation = CABasicAnimation(keyPath: "locations")
        gradientChangeAnimation.duration = 1
        gradientChangeAnimation.repeatCount = .infinity
        gradientChangeAnimation.fromValue = [0, 0.1, 0.3]
        gradientChangeAnimation.toValue = [0, 0.8, 1]
        avatarGradient.add(gradientChangeAnimation, forKey: "locationsChange")
    }

    private func setNameGradient() {
        let nameGradient = CAGradientLayer()
        let fittingSize = nameLabel.sizeThatFits(CGSize(width: CGFloat.greatestFiniteMagnitude, height: nameLabel.bounds.height))
        let textWidth = fittingSize.width
        let textHeight = fittingSize.height
        nameGradient.frame = CGRect(origin: .zero, size: CGSize(width: textWidth, height: textHeight))
        nameGradient.locations = [0, 0.1, 0.3]
        nameGradient.colors = [
            UIColor(red: 0.682, green: 0.686, blue: 0.706, alpha: 1).cgColor,
            UIColor(red: 0.531, green: 0.533, blue: 0.553, alpha: 1).cgColor,
            UIColor(red: 0.431, green: 0.433, blue: 0.453, alpha: 1).cgColor
        ]
        nameGradient.startPoint = CGPoint(x: 0, y: 0.5)
        nameGradient.endPoint = CGPoint(x: 1, y: 0.5)
        nameGradient.cornerRadius = 9
        nameGradient.masksToBounds = true
        animationLayers.insert(nameGradient)
        nameLabel.layer.addSublayer(nameGradient)

        let gradientChangeAnimation = CABasicAnimation(keyPath: "locations")
        gradientChangeAnimation.duration = 1
        gradientChangeAnimation.repeatCount = .infinity
        gradientChangeAnimation.fromValue = [0, 0.1, 0.3]
        gradientChangeAnimation.toValue = [0, 0.8, 1]
        nameGradient.add(gradientChangeAnimation, forKey: "locationsChange")
    }

    private func setLoginGradient() {
        let loginGradient = CAGradientLayer()
        let fittingSize = loginNameLabel.sizeThatFits(CGSize(width: CGFloat.greatestFiniteMagnitude, height: loginNameLabel.bounds.height))
        let textWidth = fittingSize.width
        let textHeight = fittingSize.height
        loginGradient.frame = CGRect(origin: .zero, size: CGSize(width: textWidth, height: textHeight))
        loginGradient.locations = [0, 0.1, 0.3]
        loginGradient.colors = [
            UIColor(red: 0.682, green: 0.686, blue: 0.706, alpha: 1).cgColor,
            UIColor(red: 0.531, green: 0.533, blue: 0.553, alpha: 1).cgColor,
            UIColor(red: 0.431, green: 0.433, blue: 0.453, alpha: 1).cgColor
        ]
        loginGradient.startPoint = CGPoint(x: 0, y: 0.5)
        loginGradient.endPoint = CGPoint(x: 1, y: 0.5)
        loginGradient.cornerRadius = 9
        loginGradient.masksToBounds = true
        animationLayers.insert(loginGradient)
        loginNameLabel.layer.addSublayer(loginGradient)

        let gradientChangeAnimation = CABasicAnimation(keyPath: "locations")
        gradientChangeAnimation.duration = 1
        gradientChangeAnimation.repeatCount = .infinity
        gradientChangeAnimation.fromValue = [0, 0.1, 0.3]
        gradientChangeAnimation.toValue = [0, 0.8, 1]
        loginGradient.add(gradientChangeAnimation, forKey: "locationsChange")
    }

    private func setDescriptionGradient() {
        let descriptionGradient = CAGradientLayer()
        let fittingSize = descriptionLabel.sizeThatFits(CGSize(width: CGFloat.greatestFiniteMagnitude, height: descriptionLabel.bounds.height))
        let textWidth = fittingSize.width
        let textHeight = fittingSize.height
        descriptionGradient.frame = CGRect(origin: .zero, size: CGSize(width: textWidth, height: textHeight))
        descriptionGradient.locations = [0, 0.1, 0.3]
        descriptionGradient.colors = [
            UIColor(red: 0.682, green: 0.686, blue: 0.706, alpha: 1).cgColor,
            UIColor(red: 0.531, green: 0.533, blue: 0.553, alpha: 1).cgColor,
            UIColor(red: 0.431, green: 0.433, blue: 0.453, alpha: 1).cgColor
        ]
        descriptionGradient.startPoint = CGPoint(x: 0, y: 0.5)
        descriptionGradient.endPoint = CGPoint(x: 1, y: 0.5)
        descriptionGradient.cornerRadius = 9
        descriptionGradient.masksToBounds = true
        animationLayers.insert(descriptionGradient)
        descriptionLabel.layer.addSublayer(descriptionGradient)

        let gradientChangeAnimation = CABasicAnimation(keyPath: "locations")
        gradientChangeAnimation.duration = 1
        gradientChangeAnimation.repeatCount = .infinity
        gradientChangeAnimation.fromValue = [0, 0.1, 0.3]
        gradientChangeAnimation.toValue = [0, 0.8, 1]
        descriptionGradient.add(gradientChangeAnimation, forKey: "locationsChange")
    }

    private func removeGradient() {
        animationLayers.forEach { layer in
            layer.removeFromSuperlayer()
        }
    }
}

