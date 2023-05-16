//
//  ProfileImageService.swift
//  ImageFeed
//
//  Created by Максим on 14.05.2023.
//

import UIKit





final class ProfileImageService {
    static let shared = ProfileImageService()
    private (set) var avatarUrl: String?
    private var task: URLSessionDataTask?

    struct UserResult: Codable {
        let profileImage: ProfileImage

        enum CodingKeys: String, CodingKey {
            case profileImage = "profile_image"
        }
    }

    struct ProfileImage: Codable {
        let small: String
    }

    func fetchProfileImageURL(username: String, _ completion: @escaping (Result<String, Error>) -> Void) {

        guard avatarUrl == nil else {
            completion(.success(avatarUrl!))
            return
        }

        guard let token = OAuth2TokenStorage().token else {
            completion(.failure(ProfileImageServiceError.unauthorized))
            return
        }

        let url = URL(string: "https://api.unsplash.com/users/\(username)")!
        var request = URLRequest(url: url)
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        task?.cancel()
        task = URLSession.shared.dataTask(with: request) { (data, response, error) in

            guard error == nil else {
                completion(.failure(error!))
                return
            }

            guard let data = data else {
                completion(.failure(ProfileImageServiceError.noData))
                return
            }

            do {
                let userResult = try JSONDecoder().decode(UserResult.self, from: data)
                self.avatarUrl = userResult.profileImage.small
                completion(.success(userResult.profileImage.small))
            } catch {
                completion(.failure(error))
            }
        }
        task?.resume()
    }

    enum ProfileImageServiceError: Error {
        case unauthorized
        case noData
    }
}
