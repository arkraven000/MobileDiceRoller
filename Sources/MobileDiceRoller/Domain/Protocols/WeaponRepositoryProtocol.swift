//
//  WeaponRepositoryProtocol.swift
//  MobileDiceRoller
//
//  Created on 2025-11-08.
//

import Foundation

/// Protocol for weapon data persistence and retrieval
///
/// This protocol follows the Repository pattern, abstracting the data layer
/// and providing a clean interface for weapon CRUD operations. All operations
/// are asynchronous to avoid blocking the main thread.
///
/// ## Usage
/// ```swift
/// let repository: WeaponRepositoryProtocol = WeaponRepository(database: db)
/// let weapons = try await repository.fetchAll()
/// try await repository.save(weapon)
/// ```
public protocol WeaponRepositoryProtocol {
    // MARK: - Create & Update

    /// Saves a weapon to the database (insert or update)
    ///
    /// If a weapon with the same ID already exists, it will be updated.
    /// Otherwise, a new weapon will be inserted.
    ///
    /// - Parameter weapon: The weapon to save
    /// - Throws: DatabaseError if the operation fails
    func save(_ weapon: Weapon) async throws

    /// Saves multiple weapons in a single transaction
    ///
    /// This is more efficient than calling save() multiple times.
    ///
    /// - Parameter weapons: The weapons to save
    /// - Throws: DatabaseError if the operation fails
    func saveMany(_ weapons: [Weapon]) async throws

    // MARK: - Read

    /// Fetches all weapons from the database
    ///
    /// - Returns: An array of all weapons, ordered by name
    /// - Throws: DatabaseError if the operation fails
    func fetchAll() async throws -> [Weapon]

    /// Fetches a weapon by its ID
    ///
    /// - Parameter id: The ID of the weapon to fetch
    /// - Returns: The weapon, or nil if not found
    /// - Throws: DatabaseError if the operation fails
    func fetch(id: String) async throws -> Weapon?

    /// Fetches weapons by name (exact match)
    ///
    /// - Parameter name: The name to search for
    /// - Returns: An array of weapons with matching names
    /// - Throws: DatabaseError if the operation fails
    func fetch(byName name: String) async throws -> [Weapon]

    /// Searches weapons using full-text search
    ///
    /// Uses FTS5 for fast full-text searching. Supports:
    /// - Partial word matches
    /// - Multiple words
    /// - Quoted phrases
    ///
    /// - Parameter query: The search query
    /// - Returns: An array of weapons matching the query
    /// - Throws: DatabaseError if the operation fails
    func search(_ query: String) async throws -> [Weapon]

    /// Fetches weapons with pagination
    ///
    /// - Parameters:
    ///   - limit: Maximum number of weapons to return
    ///   - offset: Number of weapons to skip
    /// - Returns: An array of weapons
    /// - Throws: DatabaseError if the operation fails
    func fetch(limit: Int, offset: Int) async throws -> [Weapon]

    /// Fetches weapons filtered by specific criteria
    ///
    /// - Parameter filter: The filter to apply
    /// - Returns: An array of weapons matching the filter
    /// - Throws: DatabaseError if the operation fails
    func fetch(filter: WeaponFilter) async throws -> [Weapon]

    // MARK: - Delete

    /// Deletes a weapon from the database
    ///
    /// - Parameter weapon: The weapon to delete
    /// - Throws: DatabaseError if the operation fails
    func delete(_ weapon: Weapon) async throws

    /// Deletes a weapon by its ID
    ///
    /// - Parameter id: The ID of the weapon to delete
    /// - Throws: DatabaseError if the operation fails
    func delete(id: String) async throws

    /// Deletes all weapons from the database
    ///
    /// ⚠️ WARNING: This cannot be undone!
    ///
    /// - Throws: DatabaseError if the operation fails
    func deleteAll() async throws

    // MARK: - Counts

    /// Gets the total count of weapons in the database
    ///
    /// - Returns: The number of weapons
    /// - Throws: DatabaseError if the operation fails
    func count() async throws -> Int
}

// MARK: - Weapon Filter

/// Filter criteria for querying weapons
public struct WeaponFilter {
    /// Minimum attacks
    public var minAttacks: Int?

    /// Maximum attacks
    public var maxAttacks: Int?

    /// Minimum skill (BS/WS)
    public var minSkill: Int?

    /// Maximum skill (BS/WS)
    public var maxSkill: Int?

    /// Minimum strength
    public var minStrength: Int?

    /// Maximum strength
    public var maxStrength: Int?

    /// Filter by weapon type (ranged/melee)
    public var isRanged: Bool?

    /// Filter by specific abilities
    public var hasAbilities: [WeaponAbility]?

    /// Sort order
    public var sortBy: SortField
    public var sortOrder: SortOrder

    public init(
        minAttacks: Int? = nil,
        maxAttacks: Int? = nil,
        minSkill: Int? = nil,
        maxSkill: Int? = nil,
        minStrength: Int? = nil,
        maxStrength: Int? = nil,
        isRanged: Bool? = nil,
        hasAbilities: [WeaponAbility]? = nil,
        sortBy: SortField = .name,
        sortOrder: SortOrder = .ascending
    ) {
        self.minAttacks = minAttacks
        self.maxAttacks = maxAttacks
        self.minSkill = minSkill
        self.maxSkill = maxSkill
        self.minStrength = minStrength
        self.maxStrength = maxStrength
        self.isRanged = isRanged
        self.hasAbilities = hasAbilities
        self.sortBy = sortBy
        self.sortOrder = sortOrder
    }

    public enum SortField {
        case name
        case attacks
        case skill
        case strength
        case createdAt
        case updatedAt
    }

    public enum SortOrder {
        case ascending
        case descending
    }
}
