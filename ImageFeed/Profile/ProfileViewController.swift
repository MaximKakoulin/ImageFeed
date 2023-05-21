import UIKit



final class ProfileViewController: UIViewController {

    private var nameLabel: UILabel!
    private var loginNameLabel: UILabel!
    private var descriptionLabel: UILabel!

    private let profileService = ProfileService.shared
    private let profileImageService = ProfileImageService.shared
    let tokenStorage = OAuth2TokenStorage()

    private var profileImageServiceObserver: NSObjectProtocol? // Объявляем проперти для хранения обсервера

    override var preferredStatusBarStyle: UIStatusBarStyle { return .lightContent }

    // MARK: - LifeCicle
    override func viewDidLoad() {
        super.viewDidLoad()

        profileService.fetchProfile(tokenStorage.token!) { result in
            switch result {
            case .success(let profile):
                self.updateProfileDetails(profile: profile)
            case .failure(let error):
                print(error)
            }
        }

        updateProfileDetails(profile: profileService.profile)
        subscribeForAvatarUpdates()
        updateAvatar()

        //MARK: - Methods

        func configureConstraints() {
            NSLayoutConstraint.activate([
                imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
                imageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
                imageView.widthAnchor.constraint(equalToConstant: 70),
                imageView.heightAnchor.constraint(equalToConstant: 70),

                nameLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 20),
                nameLabel.leadingAnchor.constraint(equalTo: imageView.leadingAnchor),

                loginNameLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
                loginNameLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),

                descriptionLabel.topAnchor.constraint(equalTo: loginNameLabel.bottomAnchor, constant: 8),
                descriptionLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),

                logoutButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
                logoutButton.centerYAnchor.constraint(equalTo: imageView.centerYAnchor)
            ])
        }

        let profileImage = UIImage(named: "MockPhoto")
        let imageView = UIImageView(image: profileImage)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(imageView)



        let nameLabel = UILabel()
        nameLabel.text = "Екатерина Новикова"
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(nameLabel)
        nameLabel.textColor = .white
        nameLabel.font = UIFont.systemFont(ofSize: 23, weight: .bold)


        self.nameLabel = nameLabel

        let loginNameLabel = UILabel()
        loginNameLabel.text = "@ekaterina_nov"
        loginNameLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(loginNameLabel)
        loginNameLabel.textColor = .lightGray
        loginNameLabel.font = UIFont.systemFont(ofSize: 13)

        self.loginNameLabel = loginNameLabel

        let descriptionLabel = UILabel()
        descriptionLabel.text = "Hello,world!"
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.textColor = .white
        view.addSubview(descriptionLabel)
        descriptionLabel.font = UIFont.systemFont(ofSize: 13)

        self.descriptionLabel = descriptionLabel

        let logoutButton = UIButton(type: .custom)
        logoutButton.setImage(UIImage(named: "ipad.and.arrow.forward"), for: .normal)
        logoutButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(logoutButton)
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
        guard let profileImageURL = ProfileImageService.shared.avatarURL,
              let url = URL(string: profileImageURL)
        else { return }
        // TODO 11 KF
    }

    private func subscribeForAvatarUpdates() {
        profileImageServiceObserver = NotificationCenter.default.addObserver(
            forName: ProfileImageService.didChangeNotification,
            object: nil,                                                     // nil так как хотим получать уведомления от любых источников.
            queue: .main                                                     // Очередь, на которой мы хотим получать уведомления.
        ) { [weak self] _ in
            guard let self = self else { return }
            self.updateAvatar()
        }
        updateAvatar()
    }
}


