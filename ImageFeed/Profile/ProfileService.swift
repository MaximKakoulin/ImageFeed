//
//  ProfileService.swift
//  ImageFeed
//
//  Created by Максим on 13.05.2023.
//

import UIKit



final class ProfileService {
    static let shared = ProfileService()
    private(set) var profile: Profile?
    private var fetchProfileTask: URLSessionTask?
    private let urlSession = URLSession.shared

    private init() {}

    //MARK: - Metoths
    func fetchProfile(_ token: String, completion: @escaping (Result<Profile, Error>) -> Void) {
        fetchProfileTask?.cancel()

        let url = URL(string: "https://api.unsplash.com/me")!
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        fetchProfileTask = urlSession.objectTask(for: request) {[weak self] (result: Result<ProfileResult, Error>) in
            switch result {
            case .success(let profileResult):
                let profile = Profile(
                    userName: profileResult.userName,
                    name: "\(profileResult.firstName) \(profileResult.lastName)",
                    loginName: "@\(profileResult.userName)",
                    bio: profileResult.bio
                )
                self?.profile = profile
                completion(.success(profile))
            case .failure(_):
                completion(.failure(ProfileServiceError.decodingFailed))
            }
        }
        fetchProfileTask?.resume()
    }
}

//MARK: - Structs
struct ProfileResult: Codable {
    let userName: String
    let firstName: String
    let lastName: String
    let bio: String?

    ///Определяем свойства структуры, которые соответствуют полям ответа сервера.
    enum CodingKeys: String, CodingKey {
        case userName = "username"
        case firstName = "first_name"
        case lastName = "last_name"
        case bio = "bio"
    }
}

struct Profile: Codable {
    var userName: String
    var name: String
    var loginName: String
    var bio: String?
}

enum ProfileServiceError: Error {
    case invalidURL
    case invalidData
    case decodingFailed
}
