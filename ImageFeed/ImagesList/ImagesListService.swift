//
//  ImagesListService.swift
//  ImageFeed
//
//  Created by Максим on 01.06.2023.
//

import Foundation


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

    //MARK: - Функция лайка
    func changeLike(photoId: String, isLike: Bool, _ completion: @escaping (Result<Void, Error>) -> Void) {
        var urlComponents = URLComponents(string: "https://api.unsplash.com")
        urlComponents?.path = "/photos/\(photoId)/like"

        guard let url = urlComponents?.url else {return}

        var request = URLRequest(url: url)
        guard let token = tokenStorage.token else {return}
        request.httpMethod = isLike ? "POST" : "DELETE"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        let dataTask = URLSession.shared.dataTask(with: request) { [weak self] (data, response, error) in
            guard let self = self else {return}
            if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }
            if let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) {
                if let index = self.photos.firstIndex(where: {$0.id == photoId}) {
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
                    self.photos[index] = newPhoto
                    DispatchQueue.main.async {
                        completion(.success(()))
                    }
                }
            } else {
                DispatchQueue.main.async {
                    completion(.failure(error ?? NSError(domain: "Unknown error", code: -1, userInfo: nil)))
                }
            }
        }
        dataTask.resume()
    }
}
