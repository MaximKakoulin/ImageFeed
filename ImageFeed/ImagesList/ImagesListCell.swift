import UIKit
import Kingfisher

protocol ImagesListCellDelegate: AnyObject {
    func imageListCellDidTapLike(_ cell: ImagesListCell)
}

final class ImagesListCell: UITableViewCell {
    //MARK: - Properties
    static let reuseIdentifier = "ImagesListCell"
    weak var delegate: ImagesListCellDelegate?

    private let dateLabel: UILabel = {
        let dateLabel = UILabel()
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.font = .systemFont(ofSize: 13)
        dateLabel.textColor = .YPWhite
        return dateLabel
    }()
     let cellImage: UIImageView = {
        let cellImage = UIImageView()
        cellImage.translatesAutoresizingMaskIntoConstraints = false
        cellImage.layer.cornerRadius = 16
        cellImage.layer.masksToBounds = true
        return cellImage
    }()
    private let likeButton: UIButton = {
        let likeButton = UIButton()
        likeButton.translatesAutoresizingMaskIntoConstraints = false
        likeButton.setTitle("", for: .normal)
        likeButton.addTarget(nil, action: #selector(likeButtonClicked), for: .touchUpInside)
        return likeButton
    }()

    private let animatedGradient: CAGradientLayer = {
       let animatedGradient = CAGradientLayer()
        animatedGradient.locations = [0, 0.1, 0.3]
        animatedGradient.colors = [
            UIColor(red: 0.682, green: 0.686, blue: 0.706, alpha: 1).cgColor,
            UIColor(red: 0.531, green: 0.533, blue: 0.553, alpha: 1).cgColor,
            UIColor(red: 0.431, green: 0.433, blue: 0.453, alpha: 1).cgColor
        ]
        animatedGradient.startPoint = CGPoint(x: 0, y: 0.5)
        animatedGradient.endPoint = CGPoint(x: 1, y: 0.5)
        animatedGradient.cornerRadius = 16
        animatedGradient.masksToBounds = true
        return animatedGradient
    }()

    private var gradientLayer: CAGradientLayer!
    private var animationLayers = Set<CALayer>()

    //MARK: - Methods
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        createCell()
        createGradientLayer()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        assertionFailure("Error")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = CGRect(x: 0, y: cellImage.bounds.height - 35, width: cellImage.bounds.width, height: 35)
        animatedGradient.frame = cellImage.bounds
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        //отменяем загрузку во избежании багов
        cellImage.kf.cancelDownloadTask()
    }

    func configureCellElements(image: UIImage, date: String, likeImage: Bool) {
        cellImage.image = image
        dateLabel.text = date
        setIsLiked(likeImage)
        removeAnimatedGradient()
    }

    func setAnimatedGradient() {
        animationLayers.insert(animatedGradient)
        cellImage.layer.addSublayer(animatedGradient)
        let gradientChangeAnimation = CABasicAnimation(keyPath: "locations")
        gradientChangeAnimation.duration = 1
        gradientChangeAnimation.repeatCount = .infinity
        gradientChangeAnimation.fromValue = [0, 0.1, 0.3]
        gradientChangeAnimation.toValue = [0, 0.8, 1]
        animatedGradient.add(gradientChangeAnimation, forKey: "locationsChange")
    }

    private func createGradientLayer() {
        ///Задаем градиентный слой ячейкам
        gradientLayer = CAGradientLayer()
        gradientLayer.colors = [UIColor.YPGradient0?.cgColor as Any, UIColor.YPGradient20?.cgColor as Any]
        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.startPoint = CGPoint(x: 0.25, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 0.75, y: 0.5)
        gradientLayer.transform = CATransform3DMakeAffineTransform(CGAffineTransform(a: 0, b: 0.54, c: -0.54, d: 0, tx: 0.77, ty: 0))
        //Добавляем градиентный слой
        cellImage.layer.addSublayer(gradientLayer)
    }

    private func createCell() {
        contentView.addSubview(cellImage)
        contentView.addSubview(dateLabel)
        contentView.addSubview(likeButton)

        NSLayoutConstraint.activate([
            dateLabel.leadingAnchor.constraint(equalTo: cellImage.leadingAnchor, constant: 5),
            dateLabel.trailingAnchor.constraint(equalTo: cellImage.trailingAnchor, constant: -8),
            dateLabel.bottomAnchor.constraint(equalTo: cellImage.bottomAnchor, constant: -8),

            likeButton.trailingAnchor.constraint(equalTo: cellImage.trailingAnchor),
            likeButton.topAnchor.constraint(equalTo: cellImage.topAnchor),
            likeButton.heightAnchor.constraint(equalToConstant: 42),
            likeButton.widthAnchor.constraint(equalToConstant: 42),
            
            cellImage.topAnchor.constraint(equalTo: topAnchor, constant: 4),
            cellImage.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -4),
            cellImage.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            cellImage.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16)
        ])
    }

    func setIsLiked(_ isLiked: Bool) {
        if isLiked {
            likeButton.setImage(UIImage(named: "isLiked"), for: .normal)
        } else {
            likeButton.setImage(UIImage(named:"isUnliked"), for: .normal)
        }
    }

    @objc private func likeButtonClicked() {
        delegate?.imageListCellDidTapLike(self)
    }

    private func removeAnimatedGradient() {
        animationLayers.forEach { layers in
            layers.removeFromSuperlayer()
        }
    }
}


