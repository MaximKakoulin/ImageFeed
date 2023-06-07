//
//  KeyChainManager.swift
//  ImageFeed
//
//  Created by Максим on 07.06.2023.
//

import Foundation
import Security


final class KeychainManager {

    enum KeychainError: Error {
        case noValue
        case unexpectedValueData
        case unexpectedItemData
        case unhandledError(status: OSStatus)
    }

    private let appTag: Data

    init(appTag: Data) {
        self.appTag = appTag
    }

    func set(token: String) throws {
        guard let tokenData = token.data(using: .utf8) else {
            throw KeychainError.unexpectedItemData
        }

        var addQuery: [String: Any] = [
            kSecClass as String: kSecClassKey,
            kSecAttrApplicationTag as String: appTag,
            kSecValueRef as String: tokenData
        ]

        let status = SecItemAdd(addQuery as CFDictionary, nil)
        guard status == errSecSuccess else {
            throw KeychainError.unhandledError(status: status)
        }
    }

    func get() throws -> String? {
        var query: [String: Any] = [
            kSecClass as String: kSecClassKey,
            kSecMatchLimit as String: kSecMatchLimitOne,
            kSecAttrApplicationTag as String: appTag,
            kSecReturnData as String: true
        ]

        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        guard status == errSecSuccess,
                let existingItem = item as? [String: Any],
                let tokenData = existingItem[kSecValueData as String] as? Data,
                let token = String(data: tokenData, encoding: .utf8) else {
            throw KeychainError.unhandledError(status: status)
        }
        return token
    }

    func delete() throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassKey,
            kSecAttrApplicationTag as String: appTag
        ]

        let status = SecItemDelete(query as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw KeychainError.unhandledError(status: status)
        }
    }
}
