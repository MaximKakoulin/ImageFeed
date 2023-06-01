//
//  NetworkClient.swift
//  ImageFeed
//
//  Created by Максим on 21.05.2023.
//

import Foundation

final class NetworkClient {
    static let shared = NetworkClient()
    private let urlSession = URLSession.shared

    func getObject<T: Decodable>(dataType: T.Type, for request: URLRequest, completion: @escaping (Result<T, Error>) -> Void) -> URLSessionTask {
        let decoder = JSONDecoder()
        return urlSession.data(for: request) { result in
            switch result {
            case .success(let data):
                do {
                    let object = try decoder.decode(T.self, from: data)
                    completion(.success(object))
                } catch let error {
                    completion(.failure(error))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
