import UIKit
import ProgressHUD
import Kingfisher


final class ImagesListViewController: UIViewController {

    //MARK: - Properties
    private var photos: [Photo] = []
    private let imageListService = ImagesListService()
    private let showSingleImageSegueIdentifier = "ShowSingleImage"
    private let photosName: [String] = Array(0..<20).map{ "\($0)" }

    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()

    override var preferredStatusBarStyle: UIStatusBarStyle { return .lightContent }

    //MARK: - LifeCircle
    override func viewDidLoad() {
        super.viewDidLoad()
        createTableViewLayout()

        tableView.register(ImagesListCell.self, forCellReuseIdentifier: "ImagesListCell")
        tableView.contentInset = UIEdgeInsets(top: 16, left: 0, bottom: 16, right: 0 )
        tableView.delegate = self
        tableView.dataSource = self

        if photos.count == 0 {
            imageListService.fetchPhotosNextPage()
        }

        NotificationCenter.default.addObserver(
            forName: ImagesListService.DidChangeNotification,
            object: nil,
            queue: .main) { [weak self] _ in
                guard let self else {return}
                self.updateTableViewAnimated()
            }
    }

    //MARK: - Methods

    private func createTableViewLayout() {
        view.addSubview(tableView)
        tableView.backgroundColor = .YPBlack

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }

    private func presentSingleImageView(for indexPath: IndexPath) {
        guard let url = URL(string: photos[indexPath.row].largeImageURL) else {return}
        let singleImageVC = SingleImageViewController(fullImageUrl: url)
        singleImageVC.modalPresentationStyle = .fullScreen
        present(singleImageVC, animated: true, completion: nil)
    }

    private func updateTableViewAnimated() {
        let oldCount = photos.count
        let newCount = imageListService.photos.count
        photos = imageListService.photos
        if oldCount != newCount {
            tableView.performBatchUpdates {
                let indexPaths = (oldCount..<newCount).map { i in
                    IndexPath(row: i, section: 0)
                }
                tableView.insertRows(at: indexPaths, with: .automatic)
            } completion: { _ in }
        }
    }
}

//MARK: - UITableViewDataSource
// Данный метод определяет кол-во ячеек в секции таблицы
extension ImagesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return photos.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ImagesListCell", for: indexPath)

        guard let imageListCell = cell as? ImagesListCell else {
            return UITableViewCell()
        }

        imageListCell.backgroundColor = .YPBlack
        imageListCell.delegate = self
        configCell(for: imageListCell, with: indexPath)
        return imageListCell
    }
}

//MARK: - берем данные из класса ImageListCell
extension ImagesListViewController {
    func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
        guard let date = photos[indexPath.row].createdAt else { return }
        let dateString = date.dateTimeString

        guard let url = URL(string: photos[indexPath.row].thumbImageURL) else {return}
        cell.cellImage.kf.indicatorType = .activity
        cell.cellImage.kf.setImage(with: url, placeholder: UIImage(named: "image_placeholder")) { [weak self] result in
            guard let self = self else {return}
            switch result {
            case .success(let image):
                cell.configureCellElements(image: image.image, date: dateString, isLiked: photos[indexPath.row].likedByUser)
                self.tableView.reloadRows(at: [indexPath], with: .automatic)
            case .failure(_):
                guard let placeholderImage = UIImage(named: "image_placeholder") else { return }
                cell.configureCellElements(image: placeholderImage, date: "Error", isLiked: false)
            }
        }

        let selectedView = UIView()
        selectedView.backgroundColor = UIColor.lightGray.withAlphaComponent(0.2)
        cell.selectedBackgroundView = selectedView
    }
}

//MARK: - UITableViewDelegate
extension ImagesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Этот метод ответчает за действия, которые будут выполнены при тапе по ячейке (адрес ячейки содержиться в indexPath и передается в качестве аргумента)
        if let cell = tableView.cellForRow(at: indexPath) as? ImagesListCell {
            cell.isSelected = false
        }
        presentSingleImageView(for: indexPath)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let image = photos[indexPath.row]
        let imageInsets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
        let imageViewWidth = tableView.bounds.width - imageInsets.left - imageInsets.right
        let imageWidth = image.size.width
        let scale = imageViewWidth / imageWidth
        let cellHeight = image.size.height * scale + imageInsets.top + imageInsets.bottom
        return cellHeight
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard indexPath.row + 1 == imageListService.photos.count else { return }
        imageListService.fetchPhotosNextPage()
    }
}

//MARK: - Delegate for button like
extension ImagesListViewController: ImagesListCellDelegate {
    func imageListCellDidTapLike(_ cell: ImagesListCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }

        let photo = photos[indexPath.row]
        /// show Loader
        UIBlockingProgressHUD.show()
        imageListService.changeLike(photoId: photo.id, isLike: !photo.likedByUser) { [weak self] result in
            guard let self = self else {return}
            switch result {
            case .success:
                DispatchQueue.main.async {
                    self.photos = self.imageListService.photos
                    cell.setIsLiked(self.photos[indexPath.row].likedByUser)
                    UIBlockingProgressHUD.dismiss()
                }
            case .failure:
                DispatchQueue.main.async {
                    UIBlockingProgressHUD.dismiss()
                    self.showAlertViewController()
                }
            }
        }
    }

    private func showAlertViewController() {
        let alertVC = UIAlertController(
            title: "Что-то пошло не так",
            message: "Не удалось поставить лайк",
            preferredStyle: .alert)
        let action = UIAlertAction(title: "Ok", style: .default)
        alertVC.addAction(action)
        present(alertVC, animated: true)
    }
}
