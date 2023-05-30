import UIKit

final class ImagesListViewController: UIViewController {

    //MARK: - Properties
    private let showSingleImageSegueIdentifier = "ShowSingleImage"
    private let photosName: [String] = Array(0..<20).map{ "\($0)" }

    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()

    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    //MARK: - LifeCircle
    override func viewDidLoad() {
        super.viewDidLoad()
        createTableViewLayout()

        ///Настраиваем ячейку таблицы "из кода" (обычно это делается из viewDidLoad)
        tableView.register(ImagesListCell.self, forCellReuseIdentifier: "ImagesListCell")
        tableView.contentInset = UIEdgeInsets(top: 16, left: 0, bottom: 16, right: 0 )
        tableView.delegate = self
        tableView.dataSource = self
    }

    //MARK: - Methods

    private func createTableViewLayout() {

        view.addSubview(tableView)
        tableView.backgroundColor = UIColor(red: 26/255, green: 27/255, blue: 34/255, alpha: 0.5)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }

    private func presentSingleImageView(for indexPath: IndexPath) {
        let singleImageVC = SingleImageViewController()
        let image = UIImage(named: photosName[indexPath.row])
        singleImageVC.image = image
        singleImageVC.modalPresentationStyle = .fullScreen
        present(singleImageVC, animated: true, completion: nil)
    }
}

//MARK: - UITableViewDataSource
extension ImagesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return photosName.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifier, for: indexPath)

        guard let imageListCell = cell as? ImagesListCell else {
            return UITableViewCell()
        }

        configCell(for: imageListCell, with: indexPath)

        return imageListCell
    }
}

//MARK: - Extension ImagesListViewController
extension ImagesListViewController {
    func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
        let imageName = "\(indexPath.row)"

        guard let image = UIImage(named: imageName) else { return }
        let date =  dateFormatter.string(from: Date())
        let isLiked = indexPath.row % 2 == 0
        guard let likedImage = isLiked ? UIImage(named: "Button like ON") : UIImage(named: "Button like OFF") else {
            return
        }
        cell.configureCellElements(image: image, date: date, likeImage: likedImage)

        let selectedView = UIView()
        selectedView.backgroundColor = UIColor.lightGray.withAlphaComponent(0.2)
        cell.selectedBackgroundView = selectedView
    }
}

    //MARK: - UITableViewDelegate
extension ImagesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? ImagesListCell {
            cell.isSelected = false
        }
        presentSingleImageView(for: indexPath)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let image = UIImage(named: photosName[indexPath.row]) else {
            return 0
        }

        let imageInsets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
        let imageViewWidth = tableView.bounds.width - imageInsets.left - imageInsets.right
        let imageWidth = image.size.width
        let scale = imageViewWidth / imageWidth
        let cellHeight = image.size.height * scale + imageInsets.top + imageInsets.bottom
        return cellHeight
    }
}

