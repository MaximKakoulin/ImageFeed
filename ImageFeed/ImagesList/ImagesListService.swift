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
    let likedByUser: Bool
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
    let likedByUser: Bool
}

struct LikeResult: Codable {
    let photo: PhotoResult
    let user: User
}

struct User: Codable {
    let id: String
    let username: String
    let name: String
}

struct UrlsResult: Codable {
    let raw: String
    let full: String
    let regular: String
    let small: String
    let thumb: String
}

//MARK: - Расширение для декодинга
extension Photo {
    init(photoResult: PhotoResult) {
        id = photoResult.id
        size = CGSize(width: photoResult.width, height: photoResult.height)
        let dateFormatter = ISO8601DateFormatter()
        createdAt = dateFormatter.date(from: photoResult.createdAt)
        welcomeDescription = photoResult.description
        thumbImageURL = photoResult.urls.thumb
        largeImageURL = photoResult.urls.regular
        likedByUser = false
    }
}

//MARK: - ImagesListService
final class ImagesListService {
    private let tokenStorage = OAuth2TokenStorage()
    static let didChangeNotification = Notification.Name(rawValue: "imagesListServiceDidChange")

    private var task: URLSessionTask?
    private let urlSession = URLSession.shared
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
        if let token = tokenStorage.token {
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

    func changeLike(photoId: String, isLike: Bool, _ completion: @escaping (Result<Void, Error>) -> Void) {
        // Проверяем, есть ли фотография с заданным ID в массиве photos
        guard let index = self.photos.firstIndex(where: { $0.id == photoId }) else { return }

        // Меняем значение likedbyuser у фотографии
        let photo = self.photos[index]
        let newPhoto = Photo(
            id: photo.id,
            size: photo.size,
            createdAt: photo.createdAt,
            welcomeDescription: photo.welcomeDescription,
            thumbImageURL: photo.thumbImageURL,
            largeImageURL: photo.largeImageURL,
            likedByUser: !photo.likedByUser
        )

        // Обновляем массив photos на главном потоке
        DispatchQueue.main.async {
            self.photos[index] = newPhoto
        }

        // Отправляем запрос на лайк или удаление лайка фотографии
        let urlString = "https://api.unsplash.com/photos/\(photoId)/like"
        guard let url = URL(string: urlString) else { return }
        var request = URLRequest(url: url)
        guard let token = tokenStorage.token else { return }
        if newPhoto.likedByUser {
            // Отправляем запрос на лайк фотографии
            request.httpMethod = "POST"
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    print("Error: \(error.localizedDescription)")
                    return
                }
                guard let httpResponse = response as? HTTPURLResponse,
                      (200...299).contains(httpResponse.statusCode) else {
                    print("Error: Invalid response")
                    if let data = data, let responseString = String(data: data, encoding: .utf8) {
                        print("Response: \(responseString)")
                    }
                    return
                }
                print("Photo liked successfully")
            }
            task.resume()
        } else {
            // Отправляем запрос на удаление лайка фотографии
            request.httpMethod = "DELETE"
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    print("Error: \(error.localizedDescription)")
                    return
                }
                guard let httpResponse = response as? HTTPURLResponse,
                      (200...299).contains(httpResponse.statusCode) else {
                    print("Error: Invalid response")
                    return
                }
                print("Like removed successfully")
            }
            task.resume()
        }
    }
}
