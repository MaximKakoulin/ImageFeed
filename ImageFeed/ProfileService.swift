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
    private let semaphore = DispatchSemaphore(value: 1)

    func fetchProfile(_ token: String, completion: @escaping (Result<Profile, Error>) -> Void) {
        guard let url = URL(string: "https://api.unsplash.com/me") else {
            completion(.failure(ProfileServiceError.invalidURL))
            return
        }

        semaphore.wait()

        var request = URLRequest(url: url)
        request.setValue("Bearer \(OAuth2TokenStorage())", forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: request) { (data, response, error) in
            defer { self.semaphore.signal() }

            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(ProfileServiceError.invalidData))
                return
            }

            do {
                let userProfile = try JSONDecoder().decode(ProfileResult.self, from: data)
                let profile = self.createProfile(from: userProfile)
                completion(.success(profile))
            } catch {
                completion(.failure(error))
            }
        }.resume()
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
    let profileImage: ProfileImage
    let links: Links
}

struct ProfileImage: Codable {
    let small: String
    let medium: String
    let large: String
}

struct Links: Codable {
    let selfLink: String
    let html: String
    let photos: String
    let likes: String
    let portfolio: String
}

struct Profile {
    let userName: String
    let name: String
    let loginName: String
    let bio: String?
}
