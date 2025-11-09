//
//  DefenderRepository.swift
//  MobileDiceRoller
//
//  Created on 2025-11-08.
//

import Foundation
import SQLite

/// Repository for defender persistence using SQLite with encryption
public final class DefenderRepository: DefenderRepositoryProtocol {
    // MARK: - Properties

    private let database: DatabaseService
    private let defenders = Table("defenders")
    private let defendersFTS = Table("defenders_fts")

    // Columns
    private let id = Expression<String>("id")
    private let name = Expression<String>("name")
    private let toughness = Expression<Int>("toughness")
    private let save = Expression<Int>("save")
    private let invulnerableSave = Expression<Int?>("invulnerable_save")
    private let feelNoPain = Expression<Int?>("feel_no_pain")
    private let wounds = Expression<Int>("wounds")
    private let modelCount = Expression<Int>("model_count")
    private let createdAt = Expression<String>("created_at")
    private let updatedAt = Expression<String>("updated_at")

    // MARK: - Initialization

    public init(database: DatabaseService) {
        self.database = database
    }

    // MARK: - CRUD Operations

    public func save(_ defender: Defender) async throws {
        let connection = try database.getConnection()
        let now = ISO8601DateFormatter().string(from: Date())

        try connection.run(defenders.insert(or: .replace,
            id <- defender.id,
            name <- defender.name,
            toughness <- defender.toughness,
            save <- defender.save,
            invulnerableSave <- defender.invulnerableSave,
            feelNoPain <- defender.feelNoPain,
            wounds <- defender.wounds,
            modelCount <- defender.modelCount,
            createdAt <- ISO8601DateFormatter().string(from: defender.createdAt),
            updatedAt <- now
        ))
    }

    public func saveMany(_ defenders: [Defender]) async throws {
        for defender in defenders {
            try await save(defender)
        }
    }

    public func fetchAll() async throws -> [Defender] {
        let connection = try database.getConnection()
        let rows = try connection.prepare(defenders.order(name))
        return rows.map { decode(row: $0) }
    }

    public func fetch(id defenderId: String) async throws -> Defender? {
        let connection = try database.getConnection()
        guard let row = try connection.pluck(defenders.filter(id == defenderId)) else {
            return nil
        }
        return decode(row: row)
    }

    public func fetch(byName defenderName: String) async throws -> [Defender] {
        let connection = try database.getConnection()
        let rows = try connection.prepare(defenders.filter(name == defenderName))
        return rows.map { decode(row: $0) }
    }

    public func search(_ query: String) async throws -> [Defender] {
        let connection = try database.getConnection()
        let ftsQuery = "SELECT rowid FROM defenders_fts WHERE defenders_fts MATCH ?"
        let statement = try connection.prepare(ftsQuery)
        let rowids = try statement.bind(query).map { $0[0] as! Int64 }

        var results: [Defender] = []
        for rowid in rowids {
            if let row = try connection.pluck(defenders.filter(defenders.rowid == rowid)) {
                results.append(decode(row: row))
            }
        }
        return results
    }

    public func fetch(limit: Int, offset: Int) async throws -> [Defender] {
        let connection = try database.getConnection()
        let rows = try connection.prepare(defenders.order(name).limit(limit, offset: offset))
        return rows.map { decode(row: $0) }
    }

    public func delete(_ defender: Defender) async throws {
        try await delete(id: defender.id)
    }

    public func delete(id defenderId: String) async throws {
        let connection = try database.getConnection()
        try connection.run(defenders.filter(id == defenderId).delete())
    }

    public func deleteAll() async throws {
        let connection = try database.getConnection()
        try connection.run(defenders.delete())
    }

    public func count() async throws -> Int {
        let connection = try database.getConnection()
        return try connection.scalar(defenders.count)
    }

    // MARK: - Private Helpers

    private func decode(row: Row) -> Defender {
        let createdDate = ISO8601DateFormatter().date(from: row[createdAt]) ?? Date()
        let updatedDate = ISO8601DateFormatter().date(from: row[updatedAt]) ?? Date()

        return Defender(
            id: row[id],
            name: row[name],
            toughness: row[toughness],
            save: row[save],
            invulnerableSave: row[invulnerableSave],
            feelNoPain: row[feelNoPain],
            wounds: row[wounds],
            modelCount: row[modelCount],
            createdAt: createdDate,
            updatedAt: updatedDate
        )
    }
}
