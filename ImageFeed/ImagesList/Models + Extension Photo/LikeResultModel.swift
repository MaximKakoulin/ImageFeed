//
//  LikeResultModel.swift
//  ImageFeed
//
//  Created by Максим on 13.06.2023.
//

import Foundation


struct LikeResult: Codable {
    let photo: PhotoResult
    let user: User
}

struct User: Codable {
    let id: String
    let username: String
    let name: String
}
