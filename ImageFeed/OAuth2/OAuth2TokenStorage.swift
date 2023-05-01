//
//  OAuth2TokenStorage.swift
//  ImageFeed
//
//  Created by Максим on 28.04.2023.
//

import UIKit






class OAuth2TokenStorage {
    private let userDefaults = UserDefaults.standard

    var token: String?
    {
        get {
            return userDefaults.string(forKey: "token")
        }
        set {
            return userDefaults.set(newValue, forKey: "token")
        }
    }
}

