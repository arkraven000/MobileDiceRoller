//
//  DatabaseServiceProtocol.swift
//  MobileDiceRoller
//
//  Created on 2025-11-08.
//

import Foundation

/// Protocol for database operations and lifecycle management
///
/// This protocol defines the interface for initializing, migrating, and
/// managing the encrypted SQLite database. It follows the Repository pattern
/// by abstracting the underlying database implementation.
///
/// ## Database Security
/// - All data encrypted at rest using AES-256 (SQLCipher)
/// - Encryption key stored in iOS Keychain with hardware backing
/// - Database cannot be read without the encryption key
///
/// ## Usage
/// ```swift
/// let database: DatabaseServiceProtocol = DatabaseService(keychainManager: keychain)
/// try await database.initialize()
/// let connection = try await database.getConnection()
/// ```
public protocol DatabaseServiceProtocol {
    /// Initializes the database and performs any necessary migrations
    ///
    /// This method should be called once during app launch. It will:
    /// 1. Retrieve or generate encryption key from Keychain
    /// 2. Open/create the encrypted database
    /// 3. Run migrations to update schema if needed
    /// 4. Verify database integrity
    ///
    /// - Throws: DatabaseError if initialization fails
    func initialize() async throws

    /// Closes the database connection
    ///
    /// Should be called when the app is terminating or when
    /// switching to a different database (e.g., for testing).
    ///
    /// - Throws: DatabaseError if closing fails
    func close() throws

    /// Performs a database migration to a specific version
    ///
    /// - Parameter targetVersion: The version to migrate to
    /// - Throws: DatabaseError if migration fails
    func migrate(to targetVersion: Int) async throws

    /// Gets the current database schema version
    ///
    /// - Returns: The current schema version number
    /// - Throws: DatabaseError if version cannot be determined
    func getCurrentVersion() throws -> Int

    /// Performs a database integrity check
    ///
    /// - Returns: true if database integrity is OK, false otherwise
    /// - Throws: DatabaseError if check fails
    func checkIntegrity() throws -> Bool

    /// Vacuums the database to reclaim unused space
    ///
    /// This operation can take some time for large databases.
    /// Should be run periodically (e.g., monthly) to optimize storage.
    ///
    /// - Throws: DatabaseError if vacuum fails
    func vacuum() throws

    /// Gets the database file size in bytes
    ///
    /// - Returns: The size of the database file in bytes
    func getDatabaseSize() throws -> UInt64
}

// MARK: - Database Error Types

/// Errors that can occur during database operations
public enum DatabaseError: Error, LocalizedError {
    /// The database could not be initialized
    case initializationFailed(String)

    /// The database migration failed
    case migrationFailed(String)

    /// The database file could not be opened
    case cannotOpenDatabase(String)

    /// The encryption key is invalid or missing
    case invalidEncryptionKey

    /// A query execution failed
    case queryFailed(String)

    /// Database integrity check failed
    case integrityCheckFailed

    /// Database connection is not available
    case noConnection

    /// The requested item was not found
    case itemNotFound

    /// A constraint violation occurred
    case constraintViolation(String)

    public var errorDescription: String? {
        switch self {
        case .initializationFailed(let message):
            return "Database initialization failed: \(message)"
        case .migrationFailed(let message):
            return "Database migration failed: \(message)"
        case .cannotOpenDatabase(let message):
            return "Cannot open database: \(message)"
        case .invalidEncryptionKey:
            return "Invalid or missing encryption key"
        case .queryFailed(let message):
            return "Query failed: \(message)"
        case .integrityCheckFailed:
            return "Database integrity check failed"
        case .noConnection:
            return "Database connection not available"
        case .itemNotFound:
            return "Item not found in database"
        case .constraintViolation(let message):
            return "Constraint violation: \(message)"
        }
    }
}

// MARK: - Database Configuration

/// Configuration for database setup
public struct DatabaseConfiguration {
    /// The filename for the database
    public let filename: String

    /// Whether to enable WAL mode (Write-Ahead Logging)
    /// WAL mode provides better concurrent performance
    public let enableWAL: Bool

    /// Page size for the database (default: 4096)
    public let pageSize: Int

    /// Cache size in pages (default: 2000, ~8MB for 4KB pages)
    public let cacheSize: Int

    /// Whether to enable foreign key constraints
    public let enableForeignKeys: Bool

    /// Synchronous mode (NORMAL is a good balance)
    public let synchronousMode: SynchronousMode

    public init(
        filename: String = "mobile_dice_roller.db",
        enableWAL: Bool = true,
        pageSize: Int = 4096,
        cacheSize: Int = 2000,
        enableForeignKeys: Bool = true,
        synchronousMode: SynchronousMode = .normal
    ) {
        self.filename = filename
        self.enableWAL = enableWAL
        self.pageSize = pageSize
        self.cacheSize = cacheSize
        self.enableForeignKeys = enableForeignKeys
        self.synchronousMode = synchronousMode
    }

    public enum SynchronousMode: String {
        case off = "OFF"
        case normal = "NORMAL"
        case full = "FULL"
        case extra = "EXTRA"
    }
}
