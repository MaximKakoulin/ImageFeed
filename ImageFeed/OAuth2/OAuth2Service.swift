//
//  OAuth2Service.swift
//  ImageFeed
//
//  Created by Максим on 27.04.2023.
//

import UIKit




struct oAuOAuthTokenResponseBody: Codable {
    let accessToken: String?
    let tokenType: String?
    let scope: String?
    let createdAt: Int?
}


class OAuth2Service {
    private let tokenStorage = OAuth2TokenStorage()
    private let splashViewController = SplashViewController()

    func fetchAuthToken(code: String, completion: @escaping (Result<String, Error>) -> Void) {
        let urlString = "https://unsplash.com/oauth/token"
        let params = [
            "grant_type": "authorization_code",
            "client_id": accessKey,
            "client_secret": secretKey,
            "redirect_uri": redirectURI,
            "code": code
        ]
        
        var components = URLComponents(string: urlString)!
        components.queryItems = params.map {
            URLQueryItem(name: $0.key, value: $0.value)
        }
        
        var request = URLRequest(url: components.url!)
        request.httpMethod = "POST"
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let httpResponse = response as? HTTPURLResponse,(200...299).contains(httpResponse.statusCode),
                  let data = data else {
                DispatchQueue.main.async {
                    completion(.failure(error ?? NSError(domain: "OAuth2Servise", code: -1, userInfo: nil)))
                    self.splashViewController.switchToTabBarController()
                }
                return
            }
            let token = String(data: data, encoding: .utf8)!

            self.tokenStorage.token = token // save token to OAuth2TokenStorage

            DispatchQueue.main.async {
                completion(.success(token))
            }
        }
    }
}








