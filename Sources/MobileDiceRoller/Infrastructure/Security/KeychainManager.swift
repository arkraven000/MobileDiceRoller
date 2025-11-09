//
//  KeychainManager.swift
//  MobileDiceRoller
//
//  Created on 2025-11-08.
//

import Foundation
import Security

/// Service for secure storage and retrieval of sensitive data using iOS Keychain
///
/// This implementation provides a secure way to store encryption keys and other
/// sensitive data using the iOS Keychain. On devices with Secure Enclave, the
/// keys are hardware-backed and cannot be extracted even with a jailbroken device.
///
/// ## Security Properties
/// - Uses kSecAttrAccessibleAfterFirstUnlock for availability
/// - Data is encrypted at rest by iOS
/// - Hardware-backed on devices with Secure Enclave
/// - Survives app reinstallation
///
/// ## Usage
/// ```swift
/// let keychain = KeychainManager(service: "com.example.MobileDiceRoller")
/// let key = try keychain.generateEncryptionKey()
/// try keychain.save(key: "database_encryption_key", data: key)
/// let retrieved = try keychain.retrieve(key: "database_encryption_key")
/// ```
public final class KeychainManager: KeychainManaging {
    // MARK: - Properties

    /// The service identifier for this app's keychain items
    /// This ensures keychain items from different apps don't conflict
    private let service: String

    /// Access group for keychain sharing (optional)
    private let accessGroup: String?

    // MARK: - Initialization

    /// Creates a new KeychainManager
    ///
    /// - Parameters:
    ///   - service: The service identifier (typically the app bundle ID)
    ///   - accessGroup: Optional access group for keychain sharing between apps
    public init(
        service: String = "com.mobilediceroller.app",
        accessGroup: String? = nil
    ) {
        self.service = service
        self.accessGroup = accessGroup
    }

    // MARK: - KeychainManaging Implementation

    /// Saves data to the Keychain
    public func save(key: String, data: Data) throws {
        // First, try to delete any existing item
        try? delete(key: key)

        // Build the query for adding the item
        var query = baseQuery(for: key)
        query[kSecValueData as String] = data
        query[kSecAttrAccessible as String] = kSecAttrAccessibleAfterFirstUnlock

        // Add the item
        let status = SecItemAdd(query as CFDictionary, nil)

        guard status == errSecSuccess else {
            if status == errSecDuplicateItem {
                throw KeychainError.duplicateItem
            }
            throw KeychainError.operationFailed(status)
        }
    }

    /// Retrieves data from the Keychain
    public func retrieve(key: String) throws -> Data? {
        var query = baseQuery(for: key)
        query[kSecReturnData as String] = true
        query[kSecMatchLimit as String] = kSecMatchLimitOne

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        if status == errSecItemNotFound {
            return nil
        }

        guard status == errSecSuccess else {
            throw KeychainError.operationFailed(status)
        }

        guard let data = result as? Data else {
            throw KeychainError.invalidData
        }

        return data
    }

    /// Deletes data from the Keychain
    public func delete(key: String) throws {
        let query = baseQuery(for: key)
        let status = SecItemDelete(query as CFDictionary)

        // Success if deleted or if item didn't exist
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw KeychainError.operationFailed(status)
        }
    }

    /// Checks if a key exists in the Keychain
    public func exists(key: String) -> Bool {
        var query = baseQuery(for: key)
        query[kSecReturnData as String] = false
        query[kSecMatchLimit as String] = kSecMatchLimitOne

        let status = SecItemCopyMatching(query as CFDictionary, nil)
        return status == errSecSuccess
    }

    // MARK: - Private Helpers

    /// Builds the base query dictionary for Keychain operations
    private func baseQuery(for key: String) -> [String: Any] {
        var query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key
        ]

        if let accessGroup = accessGroup {
            query[kSecAttrAccessGroup as String] = accessGroup
        }

        return query
    }
}

// MARK: - Convenience Methods

public extension KeychainManager {
    /// Retrieves or generates an encryption key for database encryption
    ///
    /// This method will retrieve an existing key if one exists, or generate
    /// a new one and store it if not. This ensures the same key is used
    /// consistently across app launches.
    ///
    /// - Parameter keyIdentifier: The identifier for the encryption key (default: "database_encryption_key")
    /// - Returns: The encryption key
    /// - Throws: KeychainError if the operation fails
    func getOrCreateDatabaseEncryptionKey(keyIdentifier: String = "database_encryption_key") throws -> Data {
        // Try to retrieve existing key
        if let existingKey = try retrieve(key: keyIdentifier) {
            return existingKey
        }

        // Generate new key
        let newKey = try generateEncryptionKey(length: 32) // 256 bits for AES-256

        // Save it for future use
        try save(key: keyIdentifier, data: newKey)

        return newKey
    }

    /// Clears all database-related keys from the Keychain
    ///
    /// ⚠️ WARNING: This will make existing encrypted databases unreadable!
    /// Only use this for testing or when explicitly requested by the user.
    ///
    /// - Throws: KeychainError if the operation fails
    func clearDatabaseKeys() throws {
        try delete(key: "database_encryption_key")
    }
}
