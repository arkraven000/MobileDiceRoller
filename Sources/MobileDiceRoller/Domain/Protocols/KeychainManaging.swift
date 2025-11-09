//
//  KeychainManaging.swift
//  MobileDiceRoller
//
//  Created on 2025-11-08.
//

import Foundation
import Security

/// Protocol for secure storage and retrieval of sensitive data using Keychain
///
/// This protocol defines the interface for storing sensitive data like
/// encryption keys in the iOS Keychain. The Keychain provides hardware-backed
/// security for sensitive data.
///
/// ## Security Features
/// - Hardware-backed encryption on devices with Secure Enclave
/// - Data persists across app reinstalls (unless explicitly deleted)
/// - Protected by device passcode/biometrics
/// - Encrypted at rest
///
/// ## Usage
/// ```swift
/// let keychain: KeychainManaging = KeychainManager()
/// let key = try keychain.generateEncryptionKey()
/// try keychain.save(key: "database_key", data: key)
/// ```
public protocol KeychainManaging {
    /// Saves data to the Keychain
    ///
    /// - Parameters:
    ///   - key: The identifier for this data
    ///   - data: The data to store securely
    /// - Throws: KeychainError if the operation fails
    func save(key: String, data: Data) throws

    /// Retrieves data from the Keychain
    ///
    /// - Parameter key: The identifier for the data to retrieve
    /// - Returns: The stored data, or nil if not found
    /// - Throws: KeychainError if the operation fails
    func retrieve(key: String) throws -> Data?

    /// Deletes data from the Keychain
    ///
    /// - Parameter key: The identifier for the data to delete
    /// - Throws: KeychainError if the operation fails
    func delete(key: String) throws

    /// Checks if a key exists in the Keychain
    ///
    /// - Parameter key: The identifier to check
    /// - Returns: true if the key exists, false otherwise
    func exists(key: String) -> Bool

    /// Generates a cryptographically secure random encryption key
    ///
    /// - Parameter length: The length of the key in bytes (default: 32 for AES-256)
    /// - Returns: A random key of the specified length
    /// - Throws: KeychainError if random generation fails
    func generateEncryptionKey(length: Int) throws -> Data
}

// MARK: - Keychain Error Types

/// Errors that can occur during Keychain operations
public enum KeychainError: Error, LocalizedError {
    /// The operation failed with a specific OSStatus code
    case operationFailed(OSStatus)

    /// The requested item was not found in the Keychain
    case itemNotFound

    /// The data could not be converted to the expected format
    case invalidData

    /// Random number generation failed
    case randomGenerationFailed

    /// Duplicate item already exists
    case duplicateItem

    public var errorDescription: String? {
        switch self {
        case .operationFailed(let status):
            return "Keychain operation failed with status: \(status)"
        case .itemNotFound:
            return "Item not found in Keychain"
        case .invalidData:
            return "Invalid data format"
        case .randomGenerationFailed:
            return "Failed to generate random data"
        case .duplicateItem:
            return "Duplicate item already exists in Keychain"
        }
    }
}

// MARK: - Default Implementation

public extension KeychainManaging {
    /// Generates a cryptographically secure random encryption key
    func generateEncryptionKey(length: Int = 32) throws -> Data {
        var keyData = Data(count: length)
        let result = keyData.withUnsafeMutableBytes { buffer in
            SecRandomCopyBytes(kSecRandomDefault, length, buffer.baseAddress!)
        }

        guard result == errSecSuccess else {
            throw KeychainError.randomGenerationFailed
        }

        return keyData
    }
}
