//
//  Constants.swift
//  ImageFeed
//
//  Created by Максим on 15.04.2023.
//

import UIKit

let AccessKey = "38hgALz1ns91MqL-WOeT8P2mtfcP0N2vr0DnLKPVZPI"
let SecretKey = "UOEX3BxjL2ut-miJSTNWKb6xJ_GhyO3qrMcaOfhLFHE"
let RedirectURI = "urn:ietf:wg:oauth:2.0:oob"
let AccessScope = "public+read_user+write_likes"
let DefaultBaseURL = URL(string: "https://api.unsplash.com")!
let UnsplashAuthorizedURLString = "https://unsplash.com/oauth/authorize"


struct AuthConfiguration {
    let accessKey: String
    let secretKey: String
    let redirectURI: String
    let accessScope: String
    let defaultBaseURL: URL
    let authURLString: String

    init(accessKey: String, secretKey: String, redirectURI: String, accessScope: String, authURLString: String, defaultBaseURL: URL) {
        self.accessKey = accessKey
        self.secretKey = secretKey
        self.redirectURI = redirectURI
        self.accessScope = accessScope
        self.defaultBaseURL = defaultBaseURL
        self.authURLString = authURLString
    }

    static var standard: AuthConfiguration {
        return AuthConfiguration(accessKey: AccessKey,
                                 secretKey: SecretKey,
                                 redirectURI: RedirectURI,
                                 accessScope: AccessScope,
                                 authURLString: UnsplashAuthorizedURLString,
                                 defaultBaseURL: DefaultBaseURL)
    }
}

