//
//  UserResultModel.swift
//  ImageFeed
//
//  Created by Максим on 17.06.2023.
//

import Foundation


struct UserResult: Codable {
    let profileImage: ProfileImage

    enum CodingKeys: String, CodingKey {
        case profileImage =  "profile_image"
    }

    struct ProfileImage: Codable {
        let small: String
    }
}
