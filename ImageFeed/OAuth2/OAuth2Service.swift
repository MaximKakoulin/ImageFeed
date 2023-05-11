//
//  OAuth2Service.swift
//  ImageFeed
//
//  Created by Максим on 27.04.2023.
//

import UIKit



final class OAuth2Service {
    private var task: URLSessionTask?
    private var lastCode: String?
    static let shared = OAuth2Service() // объявляем экземпляра класса OAuth2Service в виде Singleton - означает, что                              // в приложение будет только экземпляр этого класса
    
    private let urlSession = URLSession.shared // Создание экземпляра класса URLSession для выполнения HTTP-запросов.                                       //Этот экземпляр создается один раз при создании объекта OAuth2Services.
    
    private (set) var authToken: String? {     // Свойство для сохранение токена аутентификации
        get {
            return OAuth2TokenStorage().token
        }
        set {
            OAuth2TokenStorage().token = newValue
        }
    }
    
    // Сейчас мы объявляем метод fetchOAuthToken для выполнения запроса на получение токена аутентификации
    func fetchOAuthToken(_ code: String, completion: @escaping(Result<String, Error>) -> Void ) {
        ///проверка что метод вызывается из главного потока
        assert(Thread.isMainThread)
        if lastCode == code {return}
        task?.cancel()
        lastCode = code
        let request = authTokenRequest(code: code)
        let task = object(for: request) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else {return}
                switch result {
                case .success(let body):
                    let authToken = body.accessToken
                    self.authToken = authToken
                    completion(.success(authToken))//в случае успеха, токен аутентификации извлекается из ответа на запрос и сохраняется в OAuth2TokenStorage и в свойстве authToken
                    self.task = nil
                case .failure(let error):
                    completion(.failure(error))
                    self.lastCode = nil
                }
            }
        }
        self.task = task
        task.resume()
    }

    private func makeRequest(code: String) -> URLRequest {
        guard let url = URL(string: "defaultBaseURL\(code)") else { fatalError("Failed to create URL") }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        return request
    }
}

//Функция, которая создает задачу URLSessionTask для выполнения запроса и получения данных.

//Функция использует переданный URLRequest и обработчик завершения для создания URLSessionDataTask, который выполняет запрос и возвращает ответ.

//Если запрос был выполнен успешно, данные из ответа декодируются в экземпляр структуры OAuthTokenResponseBody, и успешный результат передается в обработчик завершения. Если произошла ошибка, она передается в обработчик завершения.
extension OAuth2Service {
    private func object(
        for request: URLRequest,
        completion: @escaping (Result<OAuthTokenResponseBody, Error>) -> Void) -> URLSessionTask {

            let decoder = JSONDecoder()
            return urlSession.data(for: request) { (result: Result<Data, Error>) in
                //Определяем константу response, используя flatMap для извлечения данных из результата выполнения запроса.
                // Затем используем декодер JSON для декодирования ответа сервера в экземпляр структуры OAuthTokenResponseBody. Завершаем задачу, вызывая обработчик завершения completion, передавая результат выполнения запроса в виде объекта Result.
                let response = result.flatMap { data -> Result<OAuthTokenResponseBody, Error> in
                    Result { try decoder.decode(OAuthTokenResponseBody.self, from: data) }
                }
                completion(response)
            }
        }

    // Объявляем ф-ю authTokenRequest, которая возвращает URLRequest и вызываем метод makeHTTPRequest на классе URLRequest, передавая значения пути, метода, и базового URL, а также другие параметры, которые требуются для запроса токена аутентификации.
    private func authTokenRequest(code: String) -> URLRequest {
        URLRequest.makeHTTPRequest(
            path: "/oauth/token"
            + "?client_id=\(accessKey)"
            + "&&client_secret=\(secretKey)"
            + "&&redirect_uri=\(redirectURI)"
            + "&&code=\(code)"
            + "&&grant_type=authorization_code",
            httpMethod: "POST",
            baseURL: URL(string: "https://unsplash.com")!
        )
    }

    private struct OAuthTokenResponseBody: Decodable { // Структура, которая используется для декодирования ответа                                                   // сервера
        let accessToken: String
        let tokenType: String
        let scope: String
        let createdAt: Int

        enum CodingKeys: String, CodingKey { // Свойство структуры, которые соответствуют полям ответа сервера.
            case accessToken = "access_token"
            case tokenType = "token_type"
            case scope
            case createdAt = "created_at"
        }
    }
}

// MARK: - HTTP Request

extension URLRequest {
    static func makeHTTPRequest(path: String, httpMethod: String, baseURL: URL = defaultBaseURL) -> URLRequest {
        var request = URLRequest(url: URL(string: path, relativeTo: baseURL)!)
        request.httpMethod = httpMethod
        return request
    }
}

// MARK: - Network Connection

enum NetworkError: Error {
    case httpStatusCode(Int)
    case urlRequestError(Error)
    case urlSessionError
}

extension URLSession {
    func data(for request: URLRequest,completion: @escaping (Result<Data, Error>) -> Void) -> URLSessionTask {
        //Замыкание fulfillCompletion, которое будет вызываться внутри метода dataTask после завершения запроса. В замыкании определен асинхронный вызов completion на главной очереди, передавая результат в качестве аргумента.
        let fulfillCompletion: (Result<Data, Error>) -> Void = { result in
            DispatchQueue.main.async {
                completion(result)
            }
        }

        //Здесь определяется задача task с использованием метода dataTask(with:completionHandler:). При завершении запроса вызывается замыкание completionHandler, которое принимает параметры data, response и error.

        //Если data, response и statusCode определены и код состояния находится в диапазоне 200-299, то вызывается замыкание fulfillCompletion с результатом в виде .success(data).
        let task = dataTask(with: request, completionHandler: { data, response, error in
            if let data = data,
               let response = response,
               let statusCode = (response as? HTTPURLResponse)?.statusCode {

                if 200 ..< 300 ~= statusCode {
                    fulfillCompletion(.success(data))
                } else {
                    fulfillCompletion(.failure(NetworkError.httpStatusCode(statusCode)))
                }
            } else if let error = error {
                fulfillCompletion(.failure(NetworkError.urlRequestError(error)))
            } else {
                fulfillCompletion(.failure(NetworkError.urlSessionError))
            }
        })
        task.resume()
        return task
    }
}



















