//
//  ProfileImageService.swift
//  ImageFeed
//
//  Created by Максим on 14.05.2023.
//

import UIKit





final class ProfileImageService {
    static let shared = ProfileImageService()
    private let tokenStorage = OAuth2TokenStorage()


    private (set) var avatarURL: String?
    private let urlSession = URLSession.shared
    private var task: URLSessionTask?
    static let didChangeNotification = Notification.Name("ProfileImageProviderDidChange")

// MARK: - Methods
    func fetchProfileImageURL(username: String, _ completion: @escaping (Result<String, Error>) -> Void) {
        guard let token = tokenStorage.token else {return}

        let urlString = "https://api.unsplash.com/users/\(username)"
        guard let url = URL(string: urlString) else { return}

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        let dataTask = urlSession.objectTask(for: request) { [weak self] (result: Result<UserResult, Error>) in
            switch result {
            case .success(let userResult):
                self?.avatarURL = userResult.profileImage.small
                if let avatarURL = self?.avatarURL {
                    completion(.success(userResult.profileImage.small))
                    NotificationCenter.default.post(name: ProfileImageService.didChangeNotification,
                                                      object: self,
                                                      userInfo:  ["URL": userResult.profileImage.small])
                } else {
                    completion(.failure(ProfileServiceError.invalidData))
                }
                self?.task = nil
            case .failure(_):
                completion(.failure(ProfileServiceError.decodingFailed))            }
        }
        task = dataTask
        task?.resume()
    }
}

// MARK: - Structs
struct ProfileImage: Codable {
    let small: String
    let medium: String
}

struct UserResult: Codable {
    let profileImage: ProfileImage

    enum CodingKeys: String, CodingKey {
        case profileImage = "profile_image"
    }
}


