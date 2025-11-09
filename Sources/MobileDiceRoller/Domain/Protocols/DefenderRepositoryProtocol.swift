//
//  DefenderRepositoryProtocol.swift
//  MobileDiceRoller
//
//  Created on 2025-11-08.
//

import Foundation

/// Protocol for defender data persistence and retrieval
///
/// Follows the Repository pattern for clean data layer abstraction.
public protocol DefenderRepositoryProtocol {
    // MARK: - Create & Update
    func save(_ defender: Defender) async throws
    func saveMany(_ defenders: [Defender]) async throws

    // MARK: - Read
    func fetchAll() async throws -> [Defender]
    func fetch(id: String) async throws -> Defender?
    func fetch(byName name: String) async throws -> [Defender]
    func search(_ query: String) async throws -> [Defender]
    func fetch(limit: Int, offset: Int) async throws -> [Defender]

    // MARK: - Delete
    func delete(_ defender: Defender) async throws
    func delete(id: String) async throws
    func deleteAll() async throws

    // MARK: - Counts
    func count() async throws -> Int
}
