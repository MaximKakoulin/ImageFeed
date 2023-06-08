//
//  OAuth2Service.swift
//  ImageFeed
//
//  Created by Максим on 27.04.2023.
//

import UIKit

//MARK: - Struct OAuthTokenResponseBody
struct OAuthTokenResponseBody: Codable {
    let accessToken: String
    let tokenType: String
    let scope: String
    let createdAt: Int
}

//MARK: - Класс-Сервис -> Слой Доступа к сервису (Service Access Layer)
final class OAuth2Service {
    //MARK: - Properties
    static let shared = OAuth2Service()

    //MARK: - Private Properties
    private let urlSession = URLSession.shared

    private var task: URLSessionTask?

    private var lastCode: String?

    private let tokenStorage = OAuth2TokenStorage()

    private (set)  var authToken: String? {
        get {
            return tokenStorage.token
        }
        set {
            tokenStorage.token = newValue
        }
    }


    //MARK: - Methods
    ///Объявление метода fetchAuthToken для выполнения запроса на получение токена аутентификации.
    func fetchOAuthToken(_ code: String, completion: @escaping(Result<String, Error>) -> Void ) {
        assert(Thread.isMainThread)

        if lastCode == code {
            return
        }
        guard task == nil else { return }
        lastCode = code

        var urlComponents = URLComponents(string: tokenURL)!
        urlComponents.queryItems = [
            URLQueryItem(name: "client_id", value: accessKey),
            URLQueryItem(name: "client_secret", value: secretKey),
            URLQueryItem(name: "redirect_uri", value: redirectURI),
            URLQueryItem(name: "code", value: code),
            URLQueryItem(name: "grant_type", value: "authorization_code")
        ]
        var request = URLRequest(url: urlComponents.url!)
        request.httpMethod = "POST"

        let dataTask = urlSession.objectTask(for: request) { [weak self] (result: Result<OAuthTokenResponseBody, Error>) in
            guard let self else { print("self is not exist"); return }
            switch result {
            case .success(let data):
                let authToken = data.accessToken
                self.authToken = authToken
                completion(.success(authToken))
                self.task = nil
            case .failure(let error):
                completion(.failure(error))
                self.task = nil
                self.lastCode = nil
            }
        }
        task = dataTask
        task?.resume()
    }
}



















