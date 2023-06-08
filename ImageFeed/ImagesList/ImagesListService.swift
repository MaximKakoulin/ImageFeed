//
//  ImagesListService.swift
//  ImageFeed
//
//  Created by Максим on 01.06.2023.
//

import Foundation

//MARK: - Models
struct Photo {
    let id: String
    let size: CGSize
    let createdAt: Date?
    let welcomeDescription: String?
    let thumbImageURL: String
    let largeImageURL: String
    let isLiked: Bool
}

struct PhotoResult: Codable {
    let id: String
    let createdAt: String
    let updatedAt: String
    let width: Int
    let height: Int
    let color: String?
    let description: String?
    let urls: UrlsResult
}

struct UrlsResult: Codable {
    let raw: String
    let full: String
    let regular: String
    let small: String
    let thumb: String
}

extension Photo {
    init(photoResult: PhotoResult) {
        id = photoResult.id
        size = CGSize(width: photoResult.width, height: photoResult.height)
        let dateFormatter = ISO8601DateFormatter()
        createdAt = dateFormatter.date(from: photoResult.createdAt)
        welcomeDescription = photoResult.description
        thumbImageURL = photoResult.urls.thumb
        largeImageURL = photoResult.urls.regular
        isLiked = false
    }
}

//MARK: - ImagesListService
final class ImagesListService {
    private let oAuthTokenStorage = OAuth2TokenStorage()
    static let didChangeNotification = Notification.Name(rawValue: "imagesListServiceDidChange")

    private var currentPage = 1
    private var isFetching = false

    private (set) var photos: [Photo] = [] {
        didSet {
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: ImagesListService.didChangeNotification, object: self)
            }
        }
    }

    //MARK: - Methods
    func fetchPhotosNextPage() {
        guard !isFetching else { return }
        isFetching = true

        let url = URL(string: "https://api.unsplash.com/photos?page=\(currentPage)&per_page=10")!
        var request = URLRequest(url: url)
        if let token = oAuthTokenStorage.token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

            URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
                guard let data = data, error == nil else {
                    print("Error fetching photos: \(error?.localizedDescription ?? "Unknown error")")
                    self?.isFetching = false
                    return
                }

                do {
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    let photoResults = try decoder.decode([PhotoResult].self, from: data)
                    let newPhotos = photoResults.map { Photo(photoResult: $0) }

                    DispatchQueue.main.async {
                        self?.photos.append(contentsOf: newPhotos)
                        self?.currentPage += 1
                        self?.isFetching = false
                    }
                } catch {
                    print("Error decoding photos: \(error.localizedDescription)")
                    self?.isFetching = false
                }
            }.resume()
        }
    }
}
