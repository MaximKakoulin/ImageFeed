//
//  OAuth2TokenStorage.swift
//  ImageFeed
//
//  Created by Максим on 28.04.2023.
//

import UIKit
import SwiftKeychainWrapper






class OAuth2TokenStorage {
    private let keychainWrapper = KeychainWrapper.standard

    var token: String? {
        get {
            return keychainWrapper.string(forKey: "token")
        }
        set {
            if let newToken = newValue {
                keychainWrapper.set(newToken, forKey: "token")
            } else {
                keychainWrapper.removeObject(forKey: "token")
            }
        }
    }
}

