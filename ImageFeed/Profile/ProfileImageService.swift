//
//  ProfileImageService.swift
//  ImageFeed
//
//  Created by Максим on 14.05.2023.
//

import UIKit





final class ProfileImageService {
    static let shared = ProfileImageService()
    private let networkClient = NetworkClient.shared

    private (set) var avatarUrl: String?
    private var currentTask: URLSessionTask?
    static let didChangeNotification = Notification.Name("ProfileImageProviderDidChange")

    func fetchProfileImageURL(userName: String, completion: @escaping (Result<String, Error>) -> Void) {
        assert(Thread.isMainThread)
        if currentTask != nil {
            currentTask?.cancel()
        } else {
            guard let urlRequestProfileData = makeUserPhotoProfileRequest(userName: userName)
            else { return }
            let task = networkClient.getObject(dataType: UserResult.self, for: urlRequestProfileData) { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success(let profilePhoto):
                    guard let mediumPhoto = profilePhoto.profileImage.medium else { return }
                    self.avatarUrl = mediumPhoto
                    NotificationCenter.default.post(
                        name: ProfileImageService.didChangeNotification,
                        object: self,
                        userInfo: ["URL": mediumPhoto]
                    )
                    completion(.success(mediumPhoto))
                case .failure(let error):
                    completion(.failure(error))
                }
                self.currentTask = nil
            }
            self.currentTask = task
            task.resume()
        }
    }

    private func makeUserPhotoProfileRequest (userName: String) -> URLRequest? {
        URLRequest.makeHTTPRequest (path: "/users/\(userName)", httpMethod: "GET", baseURL: defaultBaseURL)
    }
}

struct ProfileImage: Codable {
    let small: String?
    let medium: String?
}

struct UserResult: Codable {
    let profileImage: ProfileImage

    enum CodingKeys: String, CodingKey {
        case profileImage = "profile_image"
    }
}

/*
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
 */
