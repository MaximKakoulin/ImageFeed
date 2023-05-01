//
//  OAuth2TokenStorage.swift
//  ImageFeed
//
//  Created by Максим on 28.04.2023.
//

import UIKit






class OAuth2TokenStorage {
    let tokenKey = "bearerToken"

    var token: String? {
        get {
            return UserDefaults.standard.string(forKey: tokenKey)
        }
        set(newToken) {
            UserDefaults.standard.set(newToken, forKey: tokenKey)
        }
    }
}

