import UIKit



final class ProfileViewController: UIViewController {

    private var nameLabel: UILabel!
    private var loginNameLabel: UILabel!
    private var descriptionLabel: UILabel!

    let profileService = ProfileService()
    let tokenStorage = OAuth2TokenStorage()

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        guard let token = tokenStorage.token else { return }

        profileService.fetchProfile(token) { [weak self] result in
            switch result {
            case .success(let profile):
                DispatchQueue.main.async {
                    self?.nameLabel.text = profile.name
                    self?.loginNameLabel.text = profile.loginName
                    self?.descriptionLabel.text = profile.bio
                }
            case .failure(let error):
                print("Error fetching profile: \(error.localizedDescription)")
            }
        }

        let profileImage = UIImage(named: "MockPhoto")
        let imageView = UIImageView(image: profileImage)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(imageView)

        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            imageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            imageView.widthAnchor.constraint(equalToConstant: 70),
            imageView.heightAnchor.constraint(equalToConstant: 70)
        ])

        let nameLabel = UILabel()
        nameLabel.text = "Екатерина Новикова"
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(nameLabel)
        nameLabel.textColor = .white
        nameLabel.font = UIFont.systemFont(ofSize: 23, weight: .bold)

        NSLayoutConstraint.activate([
            nameLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 20),
            nameLabel.leadingAnchor.constraint(equalTo: imageView.leadingAnchor)
        ])
        self.nameLabel = nameLabel

        let loginNameLabel = UILabel()
        loginNameLabel.text = "@ekaterina_nov"
        loginNameLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(loginNameLabel)
        loginNameLabel.textColor = .lightGray
        loginNameLabel.font = UIFont.systemFont(ofSize: 13)

        NSLayoutConstraint.activate([
            loginNameLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            loginNameLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor)
        ])
        self.loginNameLabel = loginNameLabel

        let descriptionLabel = UILabel()
        descriptionLabel.text = "Hello,world!"
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.textColor = .white
        view.addSubview(descriptionLabel)
        descriptionLabel.font = UIFont.systemFont(ofSize: 13)

        NSLayoutConstraint.activate([
            descriptionLabel.topAnchor.constraint(equalTo: loginNameLabel.bottomAnchor, constant: 8),
            descriptionLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor)
        ])
        self.descriptionLabel = descriptionLabel

        let logoutButton = UIButton(type: .custom)
        logoutButton.setImage(UIImage(named: "ipad.and.arrow.forward"), for: .normal)
        logoutButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(logoutButton)

        NSLayoutConstraint.activate([
            logoutButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            logoutButton.centerYAnchor.constraint(equalTo: imageView.centerYAnchor)
        ])
    }
}


