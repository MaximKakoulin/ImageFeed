import UIKit



final class SingleImageViewController: UIViewController {

    //MARK: - Properties

    var fullImageUrl: URL?

    //MARK: - Properties
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.minimumZoomScale = 0.1
        scrollView.maximumZoomScale = 1.25
        return scrollView
    }()

    private let imageView: UIImageView =  {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()

    private let backButton: UIButton = {
        let backButton = UIButton()
        backButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.accessibilityIdentifier = "BackButton"
        backButton.setTitle("", for: .normal)
        backButton.setImage(UIImage(named: "backButton"), for: .normal)
        backButton.imageView?.contentMode = .scaleAspectFill
        backButton.addTarget(nil, action: #selector(didTapBackButton), for: .touchUpInside)
        return backButton
    }()

    private let shareButton: UIButton = {
        let shareButton = UIButton()
        shareButton.translatesAutoresizingMaskIntoConstraints = false
        shareButton.setTitle("", for: .normal)
        shareButton.setImage(UIImage(named: "shareButton"), for: .normal)
        shareButton.addTarget(nil, action: #selector(didtapShareButton), for: .touchUpInside)
        return shareButton
    }()

    //MARK: - LifeCycle

    init(fullImageUrl: URL? = nil) {
        super.init(nibName: nil, bundle: nil)
        self.fullImageUrl = fullImageUrl
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.delegate = self
        fetchFullImage()
    }



    //MARK: - Private Methods
    @objc private func didTapBackButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

    @objc private func didtapShareButton(_ sender: UIButton) {
        guard let image = imageView.image else { return }
        let vc = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        ///Показ UIActivityViewController
        if let popoverPresentationController = vc.popoverPresentationController {
            popoverPresentationController.sourceView = sender
            popoverPresentationController.sourceRect = sender.bounds
        }
        present(vc, animated: true)
    }

    private func rescaleAndCenterImageInScrollView(image: UIImage) {
        let minZoomScale = scrollView.minimumZoomScale
        let maxZoomScale = scrollView.maximumZoomScale
        view.layoutIfNeeded()
        let visibleRectSize = scrollView.bounds.size
        let imageSize = image.size
        let hScale = visibleRectSize.width / imageSize.width
        let vScale = visibleRectSize.height / imageSize.height
        let scale = min(maxZoomScale, max(minZoomScale, max(hScale, vScale)))
        scrollView.setZoomScale(scale, animated: false)
        scrollView.layoutIfNeeded()
        let newContentSize = scrollView.contentSize
        let x = (newContentSize.width - visibleRectSize.width) / 2
        let y = (newContentSize.height - visibleRectSize.height) / 2
        scrollView.setContentOffset(CGPoint(x: x, y: y), animated: false)
    }

    func fetchFullImage() {
        guard let fullImageUrl = fullImageUrl else { return }
        UIBlockingProgressHUD.show()
        imageView.kf.setImage(with: fullImageUrl) { [weak self] result in
            guard let self = self else {return}
            UIBlockingProgressHUD.dismiss()
            switch result {
            case .success(let resultImage):
                createSingleImageView()
                self.rescaleAndCenterImageInScrollView(image: resultImage.image)
            case .failure:
                self.showError()
            }
        }

    }

    private func createSingleImageView() {
        view.backgroundColor = .YPBlack

        view.addSubview(scrollView)
        scrollView.addSubview(imageView)
        view.addSubview(backButton)
        view.addSubview(shareButton)

        NSLayoutConstraint.activate([

            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            imageView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            imageView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),

            backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 15),
            backButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 9),
            backButton.widthAnchor.constraint(equalToConstant: 24),
            backButton.heightAnchor.constraint(equalToConstant: 24),

            shareButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -51),
            shareButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            shareButton.widthAnchor.constraint(equalToConstant: 50),
            shareButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }

    private func showError() {
        let alertVC = UIAlertController(
            title: "Что-то пошло не так",
            message: "Повторим еще раз?",
            preferredStyle: .alert)
        let actionNo = UIAlertAction(title: "Не надо", style: .default) { [weak self] _ in
            self?.dismiss(animated: true)
        }
        let actionAgain = UIAlertAction(title: "Повторить", style: .default) { [weak self] _ in
            self?.fetchFullImage()
        }

        alertVC.addAction(actionNo)
        alertVC.addAction(actionAgain)
        present(alertVC, animated: true)
    }

}

//MARK: UIScrollViewDelegate - Centring
extension SingleImageViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }

    // Центрирование IMAGE после Зумирования
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        centerImageInScrollView()
    }

    private func centerImageInScrollView() {
        guard let image = imageView.image else { return }
        _ = image.size
        let boundsSize = scrollView.bounds.size

        var frameToCenter = imageView.frame

        if frameToCenter.size.width < boundsSize.width {
            frameToCenter.origin.x = (boundsSize.width - frameToCenter.size.width) / 2.0
        } else {
            frameToCenter.origin.x = 0
        }

        if frameToCenter.size.height < boundsSize.height {
            frameToCenter.origin.y = (boundsSize.height - frameToCenter.size.height) / 2.0
        } else {
            frameToCenter.origin.y = 0
        }

        imageView.frame = frameToCenter
    }
}

