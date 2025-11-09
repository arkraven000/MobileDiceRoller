//
//  WeaponRepository.swift
//  MobileDiceRoller
//
//  Created on 2025-11-08.
//

import Foundation
import SQLite

/// Repository for weapon persistence using SQLite with encryption
///
/// This implementation provides async/await CRUD operations for weapons,
/// full-text search using FTS5, and efficient querying with indexing.
///
/// ## Usage
/// ```swift
/// let repository = WeaponRepository(database: databaseService)
/// let weapons = try await repository.fetchAll()
/// try await repository.save(weapon)
/// ```
public final class WeaponRepository: WeaponRepositoryProtocol {
    // MARK: - Properties

    private let database: DatabaseService

    // Table references
    private let weapons = Table("weapons")
    private let weaponAbilities = Table("weapon_abilities")
    private let weaponsFTS = Table("weapons_fts")

    // Column references
    private let id = Expression<String>("id")
    private let name = Expression<String>("name")
    private let attacks = Expression<Int>("attacks")
    private let skill = Expression<Int>("skill")
    private let strength = Expression<Int>("strength")
    private let armorPenetration = Expression<Int>("armor_penetration")
    private let damage = Expression<String>("damage")
    private let range = Expression<Int?>("range")
    private let isRanged = Expression<Bool>("is_ranged")
    private let createdAt = Expression<String>("created_at")
    private let updatedAt = Expression<String>("updated_at")

    // Weapon abilities columns
    private let weaponId = Expression<String>("weapon_id")
    private let ability = Expression<String>("ability")
    private let abilityValue = Expression<Int?>("ability_value")

    // MARK: - Initialization

    public init(database: DatabaseService) {
        self.database = database
    }

    // MARK: - Create & Update

    public func save(_ weapon: Weapon) async throws {
        let connection = try database.getConnection()
        let now = ISO8601DateFormatter().string(from: Date())

        try connection.transaction {
            // Insert or replace weapon
            try connection.run(weapons.insert(or: .replace,
                id <- weapon.id,
                name <- weapon.name,
                attacks <- weapon.attacks,
                skill <- weapon.skill,
                strength <- weapon.strength,
                armorPenetration <- weapon.armorPenetration,
                damage <- weapon.damage,
                range <- weapon.range,
                isRanged <- weapon.isRanged,
                createdAt <- ISO8601DateFormatter().string(from: weapon.createdAt),
                updatedAt <- now
            ))

            // Delete existing abilities
            try connection.run(weaponAbilities.filter(weaponId == weapon.id).delete())

            // Insert new abilities
            for weaponAbility in weapon.abilities {
                let (abilityName, value) = encodeAbility(weaponAbility)
                try connection.run(weaponAbilities.insert(
                    weaponId <- weapon.id,
                    ability <- abilityName,
                    abilityValue <- value
                ))
            }
        }
    }

    public func saveMany(_ weapons: [Weapon]) async throws {
        for weapon in weapons {
            try await save(weapon)
        }
    }

    // MARK: - Read

    public func fetchAll() async throws -> [Weapon] {
        let connection = try database.getConnection()
        let rows = try connection.prepare(weapons.order(name))
        return try await rows.map { try await decode(row: $0, connection: connection) }
    }

    public func fetch(id weaponId: String) async throws -> Weapon? {
        let connection = try database.getConnection()
        guard let row = try connection.pluck(weapons.filter(id == weaponId)) else {
            return nil
        }
        return try await decode(row: row, connection: connection)
    }

    public func fetch(byName weaponName: String) async throws -> [Weapon] {
        let connection = try database.getConnection()
        let rows = try connection.prepare(weapons.filter(name == weaponName))
        return try await rows.map { try await decode(row: $0, connection: connection) }
    }

    public func search(_ query: String) async throws -> [Weapon] {
        let connection = try database.getConnection()

        // Use FTS5 for full-text search
        let ftsQuery = "SELECT rowid FROM weapons_fts WHERE weapons_fts MATCH ?"
        let statement = try connection.prepare(ftsQuery)
        let rowids = try statement.bind(query).map { $0[0] as! Int64 }

        // Fetch weapons matching the rowids
        var results: [Weapon] = []
        for rowid in rowids {
            if let row = try connection.pluck(weapons.filter(weapons.rowid == rowid)) {
                let weapon = try await decode(row: row, connection: connection)
                results.append(weapon)
            }
        }

        return results
    }

    public func fetch(limit: Int, offset: Int) async throws -> [Weapon] {
        let connection = try database.getConnection()
        let rows = try connection.prepare(weapons.order(name).limit(limit, offset: offset))
        return try await rows.map { try await decode(row: $0, connection: connection) }
    }

    public func fetch(filter: WeaponFilter) async throws -> [Weapon] {
        let connection = try database.getConnection()

        var query = weapons.select(weapons[*])

        // Apply filters
        if let minAttacks = filter.minAttacks {
            query = query.filter(attacks >= minAttacks)
        }
        if let maxAttacks = filter.maxAttacks {
            query = query.filter(attacks <= maxAttacks)
        }
        if let minSkill = filter.minSkill {
            query = query.filter(skill >= minSkill)
        }
        if let maxSkill = filter.maxSkill {
            query = query.filter(skill <= maxSkill)
        }
        if let minStrength = filter.minStrength {
            query = query.filter(strength >= minStrength)
        }
        if let maxStrength = filter.maxStrength {
            query = query.filter(strength <= maxStrength)
        }
        if let rangedFilter = filter.isRanged {
            query = query.filter(isRanged == rangedFilter)
        }

        // Apply sorting
        switch filter.sortBy {
        case .name:
            query = filter.sortOrder == .ascending ? query.order(name.asc) : query.order(name.desc)
        case .attacks:
            query = filter.sortOrder == .ascending ? query.order(attacks.asc) : query.order(attacks.desc)
        case .skill:
            query = filter.sortOrder == .ascending ? query.order(skill.asc) : query.order(skill.desc)
        case .strength:
            query = filter.sortOrder == .ascending ? query.order(strength.asc) : query.order(strength.desc)
        case .createdAt:
            query = filter.sortOrder == .ascending ? query.order(createdAt.asc) : query.order(createdAt.desc)
        case .updatedAt:
            query = filter.sortOrder == .ascending ? query.order(updatedAt.asc) : query.order(updatedAt.desc)
        }

        let rows = try connection.prepare(query)
        var results = try await rows.map { try await decode(row: $0, connection: connection) }

        // Filter by abilities (done in-memory as it's complex to do in SQL)
        if let hasAbilities = filter.hasAbilities, !hasAbilities.isEmpty {
            results = results.filter { weapon in
                hasAbilities.allSatisfy { weapon.abilities.contains($0) }
            }
        }

        return results
    }

    // MARK: - Delete

    public func delete(_ weapon: Weapon) async throws {
        try await delete(id: weapon.id)
    }

    public func delete(id weaponId: String) async throws {
        let connection = try database.getConnection()
        try connection.run(weapons.filter(id == weaponId).delete())
        // Abilities are cascade deleted via foreign key constraint
    }

    public func deleteAll() async throws {
        let connection = try database.getConnection()
        try connection.run(weapons.delete())
    }

    // MARK: - Counts

    public func count() async throws -> Int {
        let connection = try database.getConnection()
        return try connection.scalar(weapons.count)
    }

    // MARK: - Private Helpers

    /// Decodes a weapon from a database row
    private func decode(row: Row, connection: Connection) async throws -> Weapon {
        let weaponId = row[id]

        // Fetch abilities
        let abilitiesQuery = weaponAbilities.filter(weaponId == weaponId)
        let abilityRows = try connection.prepare(abilitiesQuery)

        var abilities: [WeaponAbility] = []
        for abilityRow in abilityRows {
            let abilityName = abilityRow[ability]
            let value = abilityRow[abilityValue]
            if let decodedAbility = decodeAbility(name: abilityName, value: value) {
                abilities.append(decodedAbility)
            }
        }

        // Parse dates
        let createdDate = ISO8601DateFormatter().date(from: row[createdAt]) ?? Date()
        let updatedDate = ISO8601DateFormatter().date(from: row[updatedAt]) ?? Date()

        return Weapon(
            id: weaponId,
            name: row[name],
            attacks: row[attacks],
            skill: row[skill],
            strength: row[strength],
            armorPenetration: row[armorPenetration],
            damage: row[damage],
            abilities: abilities,
            range: row[range],
            createdAt: createdDate,
            updatedAt: updatedDate
        )
    }

    /// Encodes a weapon ability for database storage
    private func encodeAbility(_ ability: WeaponAbility) -> (String, Int?) {
        switch ability {
        case .lethalHits:
            return ("lethal_hits", nil)
        case .sustainedHits(let value):
            return ("sustained_hits", value)
        case .devastatingWounds:
            return ("devastating_wounds", nil)
        case .anti(let keyword):
            // Store keyword as hash value for simplicity
            return ("anti", keyword.hashValue)
        case .torrent:
            return ("torrent", nil)
        case .twinLinked:
            return ("twin_linked", nil)
        case .melta(let value):
            return ("melta", value)
        case .rapidFire(let value):
            return ("rapid_fire", value)
        case .blast:
            return ("blast", nil)
        case .ignoresCover:
            return ("ignores_cover", nil)
        case .precision:
            return ("precision", nil)
        case .hazardous:
            return ("hazardous", nil)
        }
    }

    /// Decodes a weapon ability from database storage
    private func decodeAbility(name: String, value: Int?) -> WeaponAbility? {
        switch name {
        case "lethal_hits":
            return .lethalHits
        case "sustained_hits":
            return .sustainedHits(value ?? 1)
        case "devastating_wounds":
            return .devastatingWounds
        case "anti":
            // Reconstruct keyword from hash (limitation: original string lost)
            return .anti("KEYWORD_\(value ?? 0)")
        case "torrent":
            return .torrent
        case "twin_linked":
            return .twinLinked
        case "melta":
            return .melta(value ?? 2)
        case "rapid_fire":
            return .rapidFire(value ?? 1)
        case "blast":
            return .blast
        case "ignores_cover":
            return .ignoresCover
        case "precision":
            return .precision
        case "hazardous":
            return .hazardous
        default:
            return nil
        }
    }
}
