//
//  PhotoModel + Extension.swift
//  ImageFeed
//
//  Created by Максим on 13.06.2023.
//

import Foundation


struct Photo {
    let id: String
    let size: CGSize
    let createdAt: Date?
    let welcomeDescription: String?
    let thumbImageURL: String
    let largeImageURL: String
    let likedByUser: Bool
}

//MARK: - Расширение для декодинга
extension Photo {
    init(photoResult: PhotoResult) {
        id = photoResult.id
        size = CGSize(width: photoResult.width, height: photoResult.height)
        let dateFormatter = ISO8601DateFormatter()
        createdAt = dateFormatter.date(from: photoResult.createdAt)
        welcomeDescription = photoResult.description
        thumbImageURL = photoResult.urls.thumb
        largeImageURL = photoResult.urls.regular
        likedByUser = false
    }
}

