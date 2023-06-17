//
//  ProfileModel.swift
//  ImageFeed
//
//  Created by Максим on 17.06.2023.
//

import Foundation


struct Profile: Codable {
    var userName: String
    var name: String
    var loginName: String
    var bio: String?
}
