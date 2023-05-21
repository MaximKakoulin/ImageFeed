//
//  ProfileService.swift
//  ImageFeed
//
//  Created by Максим on 13.05.2023.
//

import Foundation



final class ProfileService {
    static let shared = ProfileService()
    private(set) var profile: Profile?
    private var fetchProfileTask: URLSessionTask?
    private let urlSession = URLSession.shared

    private let semaphore = DispatchSemaphore(value: 1)

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

    private func createProfile(from userProfile: ProfileResult) -> Profile {
        let name = "\(userProfile.firstName) \(userProfile.lastName)"
        let loginName = "@\(userProfile.userName)"
        let profile = Profile(userName: userProfile.userName, name: name, loginName: loginName, bio: userProfile.bio ?? "")
        return profile
    }
}

enum ProfileServiceError: Error {
    case invalidURL
    case invalidData
    case decodingFailed
}

struct ProfileResult: Codable {
    let id: String
    let userName: String
    let name: String
    let firstName: String
    let lastName: String
    let bio: String?
    let totalLikel: Int
    let totalPhotos: Int
    let totalCollections: Int
}

struct Profile {
    let userName: String
    let name: String
    let loginName: String
    let bio: String?
}
