//
//  DatabaseService.swift
//  MobileDiceRoller
//
//  Created on 2025-11-08.
//

import Foundation
import SQLite

/// Service for managing the encrypted SQLite database
///
/// This implementation provides:
/// - AES-256 encryption via SQLCipher
/// - Automatic schema migrations
/// - WAL mode for better concurrent performance
/// - Foreign key constraints
/// - Database integrity checking
///
/// ## Encryption
/// The database is encrypted using SQLCipher with AES-256. The encryption key
/// is stored securely in the iOS Keychain with hardware backing on supported devices.
///
/// ## Schema Versioning
/// Schema versions are tracked in a `schema_version` table. Migrations are
/// applied sequentially when a newer version is detected.
///
/// ## Usage
/// ```swift
/// let database = DatabaseService(
///     keychainManager: KeychainManager(),
///     configuration: DatabaseConfiguration()
/// )
/// try await database.initialize()
/// ```
public final class DatabaseService: DatabaseServiceProtocol {
    // MARK: - Properties

    private let keychainManager: KeychainManaging
    private let configuration: DatabaseConfiguration
    private var connection: Connection?

    /// The current schema version
    /// Update this when making schema changes
    private let currentSchemaVersion = 1

    // MARK: - Initialization

    public init(
        keychainManager: KeychainManaging,
        configuration: DatabaseConfiguration = DatabaseConfiguration()
    ) {
        self.keychainManager = keychainManager
        self.configuration = configuration
    }

    // MARK: - DatabaseServiceProtocol Implementation

    public func initialize() async throws {
        // Get or create encryption key
        let encryptionKey = try keychainManager.getOrCreateDatabaseEncryptionKey()

        // Get database file path
        let databasePath = try getDatabasePath()

        // Open encrypted connection
        do {
            connection = try Connection(databasePath)

            // Set encryption key (PRAGMA key must be first command)
            try setEncryptionKey(encryptionKey)

            // Configure database
            try configureDatabase()

            // Verify we can read the database
            try verifyDatabaseAccess()

            // Run migrations if needed
            try await runMigrationsIfNeeded()

        } catch {
            throw DatabaseError.initializationFailed(error.localizedDescription)
        }
    }

    public func close() throws {
        connection = nil
    }

    public func migrate(to targetVersion: Int) async throws {
        guard let connection = connection else {
            throw DatabaseError.noConnection
        }

        let currentVersion = try getCurrentVersion()

        guard targetVersion > currentVersion else {
            return // Already at or above target version
        }

        // Run migrations sequentially
        for version in (currentVersion + 1)...targetVersion {
            do {
                try await runMigration(version: version, connection: connection)
                try setSchemaVersion(version)
            } catch {
                throw DatabaseError.migrationFailed("Failed to migrate to version \(version): \(error.localizedDescription)")
            }
        }
    }

    public func getCurrentVersion() throws -> Int {
        guard let connection = connection else {
            throw DatabaseError.noConnection
        }

        // Check if schema_version table exists
        let tableExists = try connection.scalar(
            "SELECT COUNT(*) FROM sqlite_master WHERE type='table' AND name='schema_version'"
        ) as! Int64

        if tableExists == 0 {
            return 0 // No schema version table means version 0
        }

        // Get current version
        let version = try connection.scalar("SELECT version FROM schema_version LIMIT 1") as? Int64
        return Int(version ?? 0)
    }

    public func checkIntegrity() throws -> Bool {
        guard let connection = connection else {
            throw DatabaseError.noConnection
        }

        let result = try connection.scalar("PRAGMA integrity_check") as? String
        return result == "ok"
    }

    public func vacuum() throws {
        guard let connection = connection else {
            throw DatabaseError.noConnection
        }

        try connection.execute("VACUUM")
    }

    public func getDatabaseSize() throws -> UInt64 {
        let databasePath = try getDatabasePath()
        let attributes = try FileManager.default.attributesOfItem(atPath: databasePath)
        return attributes[.size] as? UInt64 ?? 0
    }

    // MARK: - Private Helpers

    /// Gets the file path for the database
    private func getDatabasePath() throws -> String {
        let fileManager = FileManager.default
        let documentsURL = try fileManager.url(
            for: .documentDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        )
        return documentsURL.appendingPathComponent(configuration.filename).path
    }

    /// Sets the encryption key for SQLCipher
    private func setEncryptionKey(_ key: Data) throws {
        guard let connection = connection else {
            throw DatabaseError.noConnection
        }

        // Convert key to hex string (required by SQLCipher)
        let keyHex = key.map { String(format: "%02x", $0) }.joined()

        // PRAGMA key must be the first statement after opening the database
        try connection.execute("PRAGMA key = \"x'\(keyHex)'\"")

        // Set cipher settings for compatibility and security
        try connection.execute("PRAGMA cipher_page_size = \(configuration.pageSize)")
        try connection.execute("PRAGMA cipher_memory_security = ON")
    }

    /// Configures database settings
    private func configureDatabase() throws {
        guard let connection = connection else {
            throw DatabaseError.noConnection
        }

        // Enable Write-Ahead Logging for better concurrent performance
        if configuration.enableWAL {
            try connection.execute("PRAGMA journal_mode = WAL")
        }

        // Enable foreign key constraints
        if configuration.enableForeignKeys {
            try connection.execute("PRAGMA foreign_keys = ON")
        }

        // Set synchronous mode
        try connection.execute("PRAGMA synchronous = \(configuration.synchronousMode.rawValue)")

        // Set cache size
        try connection.execute("PRAGMA cache_size = -\(configuration.cacheSize)")

        // Enable automatic indexing
        try connection.execute("PRAGMA automatic_index = ON")
    }

    /// Verifies we can access the database (correct key)
    private func verifyDatabaseAccess() throws {
        guard let connection = connection else {
            throw DatabaseError.noConnection
        }

        do {
            // Try to query the SQLite master table
            _ = try connection.scalar("SELECT COUNT(*) FROM sqlite_master")
        } catch {
            throw DatabaseError.invalidEncryptionKey
        }
    }

    /// Runs migrations if needed
    private func runMigrationsIfNeeded() async throws {
        let currentVersion = try getCurrentVersion()

        if currentVersion < currentSchemaVersion {
            try await migrate(to: currentSchemaVersion)
        }
    }

    /// Runs a specific migration version
    private func runMigration(version: Int, connection: Connection) async throws {
        switch version {
        case 1:
            try await migrationV1(connection: connection)
        default:
            throw DatabaseError.migrationFailed("Unknown migration version: \(version)")
        }
    }

    /// Sets the schema version in the database
    private func setSchemaVersion(_ version: Int) throws {
        guard let connection = connection else {
            throw DatabaseError.noConnection
        }

        try connection.run("""
            INSERT OR REPLACE INTO schema_version (id, version, updated_at)
            VALUES (1, \(version), '\(ISO8601DateFormatter().string(from: Date()))')
        """)
    }

    // MARK: - Migrations

    /// Migration V1: Initial schema
    private func migrationV1(connection: Connection) async throws {
        // Create schema_version table
        try connection.run("""
            CREATE TABLE IF NOT EXISTS schema_version (
                id INTEGER PRIMARY KEY CHECK (id = 1),
                version INTEGER NOT NULL,
                updated_at TEXT NOT NULL
            )
        """)

        // Create weapons table
        try connection.run("""
            CREATE TABLE IF NOT EXISTS weapons (
                id TEXT PRIMARY KEY,
                name TEXT NOT NULL,
                attacks INTEGER NOT NULL,
                skill INTEGER NOT NULL,
                strength INTEGER NOT NULL,
                armor_penetration INTEGER NOT NULL,
                damage TEXT NOT NULL,
                range INTEGER,
                is_ranged INTEGER NOT NULL,
                created_at TEXT NOT NULL,
                updated_at TEXT NOT NULL
            )
        """)

        // Create weapon_abilities junction table
        try connection.run("""
            CREATE TABLE IF NOT EXISTS weapon_abilities (
                weapon_id TEXT NOT NULL,
                ability TEXT NOT NULL,
                ability_value INTEGER,
                PRIMARY KEY (weapon_id, ability),
                FOREIGN KEY (weapon_id) REFERENCES weapons(id) ON DELETE CASCADE
            )
        """)

        // Create defenders table
        try connection.run("""
            CREATE TABLE IF NOT EXISTS defenders (
                id TEXT PRIMARY KEY,
                name TEXT NOT NULL,
                toughness INTEGER NOT NULL,
                save INTEGER NOT NULL,
                invulnerable_save INTEGER,
                feel_no_pain INTEGER,
                wounds INTEGER NOT NULL,
                model_count INTEGER NOT NULL,
                created_at TEXT NOT NULL,
                updated_at TEXT NOT NULL
            )
        """)

        // Create indexes for performance
        try connection.run("CREATE INDEX IF NOT EXISTS idx_weapons_name ON weapons(name)")
        try connection.run("CREATE INDEX IF NOT EXISTS idx_defenders_name ON defenders(name)")
        try connection.run("CREATE INDEX IF NOT EXISTS idx_weapon_abilities_weapon_id ON weapon_abilities(weapon_id)")

        // Create FTS5 virtual tables for full-text search
        try connection.run("""
            CREATE VIRTUAL TABLE IF NOT EXISTS weapons_fts USING fts5(
                name,
                content='weapons',
                content_rowid='rowid'
            )
        """)

        try connection.run("""
            CREATE VIRTUAL TABLE IF NOT EXISTS defenders_fts USING fts5(
                name,
                content='defenders',
                content_rowid='rowid'
            )
        """)

        // Create triggers to keep FTS tables in sync
        try connection.run("""
            CREATE TRIGGER IF NOT EXISTS weapons_fts_insert AFTER INSERT ON weapons BEGIN
                INSERT INTO weapons_fts(rowid, name) VALUES (new.rowid, new.name);
            END
        """)

        try connection.run("""
            CREATE TRIGGER IF NOT EXISTS weapons_fts_delete AFTER DELETE ON weapons BEGIN
                INSERT INTO weapons_fts(weapons_fts, rowid, name) VALUES('delete', old.rowid, old.name);
            END
        """)

        try connection.run("""
            CREATE TRIGGER IF NOT EXISTS weapons_fts_update AFTER UPDATE ON weapons BEGIN
                INSERT INTO weapons_fts(weapons_fts, rowid, name) VALUES('delete', old.rowid, old.name);
                INSERT INTO weapons_fts(rowid, name) VALUES (new.rowid, new.name);
            END
        """)

        try connection.run("""
            CREATE TRIGGER IF NOT EXISTS defenders_fts_insert AFTER INSERT ON defenders BEGIN
                INSERT INTO defenders_fts(rowid, name) VALUES (new.rowid, new.name);
            END
        """)

        try connection.run("""
            CREATE TRIGGER IF NOT EXISTS defenders_fts_delete AFTER DELETE ON defenders BEGIN
                INSERT INTO defenders_fts(defenders_fts, rowid, name) VALUES('delete', old.rowid, old.name);
            END
        """)

        try connection.run("""
            CREATE TRIGGER IF NOT EXISTS defenders_fts_update AFTER UPDATE ON defenders BEGIN
                INSERT INTO defenders_fts(defenders_fts, rowid, name) VALUES('delete', old.rowid, old.name);
                INSERT INTO defenders_fts(rowid, name) VALUES (new.rowid, new.name);
            END
        """)
    }

    // MARK: - Internal Access (for Repositories)

    /// Gets the database connection for repositories to use
    ///
    /// Internal visibility so only repositories in this module can access it
    internal func getConnection() throws -> Connection {
        guard let connection = connection else {
            throw DatabaseError.noConnection
        }
        return connection
    }
}
