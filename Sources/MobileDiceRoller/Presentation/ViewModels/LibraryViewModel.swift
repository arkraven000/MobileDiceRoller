//
//  LibraryViewModel.swift
//  MobileDiceRoller
//
//  Created on 2025-11-08.
//

import Foundation
import Observation

/// ViewModel for the weapon and defender library screen
///
/// This ViewModel manages the library of saved weapons and defenders,
/// with support for pagination, search, filtering, and CRUD operations.
/// Uses @Observable for reactive state management.
///
/// ## Features
/// - Async/await for all database operations
/// - Pagination for performance with large datasets
/// - Full-text search
/// - Clone functionality with transaction safety
/// - Error handling
///
/// ## Usage
/// ```swift
/// let viewModel = LibraryViewModel(
///     weaponRepository: weaponRepo,
///     defenderRepository: defenderRepo
/// )
/// await viewModel.loadWeapons()
/// await viewModel.saveWeapon(boltRifle)
/// ```
@Observable
public final class LibraryViewModel {
    // MARK: - Dependencies

    private let weaponRepository: WeaponRepositoryProtocol
    private let defenderRepository: DefenderRepositoryProtocol

    // MARK: - State

    /// Currently loaded weapons
    public var weapons: [Weapon] = []

    /// Currently loaded defenders
    public var defenders: [Defender] = []

    /// Search query
    public var searchQuery: String = ""

    /// Whether data is currently loading
    public var isLoading: Bool = false

    /// Error message if an operation fails
    public var errorMessage: String?

    /// Current page for weapons pagination
    public var weaponsPage: Int = 0

    /// Current page for defenders pagination
    public var defendersPage: Int = 0

    /// Page size for pagination
    public let pageSize: Int = 20

    /// Whether there are more weapons to load
    public var hasMoreWeapons: Bool = true

    /// Whether there are more defenders to load
    public var hasMoreDefenders: Bool = true

    // MARK: - Computed Properties

    /// Filtered weapons based on search query
    public var filteredWeapons: [Weapon] {
        if searchQuery.isEmpty {
            return weapons
        }
        return weapons.filter { $0.name.localizedCaseInsensitiveContains(searchQuery) }
    }

    /// Filtered defenders based on search query
    public var filteredDefenders: [Defender] {
        if searchQuery.isEmpty {
            return defenders
        }
        return defenders.filter { $0.name.localizedCaseInsensitiveContains(searchQuery) }
    }

    // MARK: - Initialization

    public init(
        weaponRepository: WeaponRepositoryProtocol,
        defenderRepository: DefenderRepositoryProtocol
    ) {
        self.weaponRepository = weaponRepository
        self.defenderRepository = defenderRepository
    }

    // MARK: - Weapon Operations

    /// Loads weapons from the repository
    public func loadWeapons(reset: Bool = false) async {
        if reset {
            weapons = []
            weaponsPage = 0
            hasMoreWeapons = true
        }

        guard hasMoreWeapons && !isLoading else { return }

        isLoading = true
        errorMessage = nil

        do {
            let offset = weaponsPage * pageSize
            let newWeapons = try await weaponRepository.fetch(limit: pageSize, offset: offset)

            weapons.append(contentsOf: newWeapons)
            weaponsPage += 1
            hasMoreWeapons = newWeapons.count == pageSize

            isLoading = false
        } catch {
            errorMessage = "Failed to load weapons: \(error.localizedDescription)"
            isLoading = false
        }
    }

    /// Saves a weapon to the repository
    public func saveWeapon(_ weapon: Weapon) async {
        isLoading = true
        errorMessage = nil

        do {
            try await weaponRepository.save(weapon)
            await loadWeapons(reset: true)
        } catch {
            errorMessage = "Failed to save weapon: \(error.localizedDescription)"
            isLoading = false
        }
    }

    /// Deletes a weapon from the repository
    public func deleteWeapon(_ weapon: Weapon) async {
        isLoading = true
        errorMessage = nil

        do {
            try await weaponRepository.delete(weapon)
            weapons.removeAll { $0.id == weapon.id }
            isLoading = false
        } catch {
            errorMessage = "Failed to delete weapon: \(error.localizedDescription)"
            isLoading = false
        }
    }

    /// Clones a weapon with a new ID
    public func cloneWeapon(_ weapon: Weapon) async {
        let cloned = Weapon(
            id: UUID().uuidString,
            name: "\(weapon.name) (Copy)",
            attacks: weapon.attacks,
            skill: weapon.skill,
            strength: weapon.strength,
            armorPenetration: weapon.armorPenetration,
            damage: weapon.damage,
            abilities: weapon.abilities,
            range: weapon.range,
            createdAt: Date(),
            updatedAt: Date()
        )

        await saveWeapon(cloned)
    }

    /// Searches weapons using full-text search
    public func searchWeapons(_ query: String) async {
        guard !query.isEmpty else {
            await loadWeapons(reset: true)
            return
        }

        isLoading = true
        errorMessage = nil

        do {
            weapons = try await weaponRepository.search(query)
            hasMoreWeapons = false // Search returns all results
            isLoading = false
        } catch {
            errorMessage = "Search failed: \(error.localizedDescription)"
            isLoading = false
        }
    }

    // MARK: - Defender Operations

    /// Loads defenders from the repository
    public func loadDefenders(reset: Bool = false) async {
        if reset {
            defenders = []
            defendersPage = 0
            hasMoreDefenders = true
        }

        guard hasMoreDefenders && !isLoading else { return }

        isLoading = true
        errorMessage = nil

        do {
            let offset = defendersPage * pageSize
            let newDefenders = try await defenderRepository.fetch(limit: pageSize, offset: offset)

            defenders.append(contentsOf: newDefenders)
            defendersPage += 1
            hasMoreDefenders = newDefenders.count == pageSize

            isLoading = false
        } catch {
            errorMessage = "Failed to load defenders: \(error.localizedDescription)"
            isLoading = false
        }
    }

    /// Saves a defender to the repository
    public func saveDefender(_ defender: Defender) async {
        isLoading = true
        errorMessage = nil

        do {
            try await defenderRepository.save(defender)
            await loadDefenders(reset: true)
        } catch {
            errorMessage = "Failed to save defender: \(error.localizedDescription)"
            isLoading = false
        }
    }

    /// Deletes a defender from the repository
    public func deleteDefender(_ defender: Defender) async {
        isLoading = true
        errorMessage = nil

        do {
            try await defenderRepository.delete(defender)
            defenders.removeAll { $0.id == defender.id }
            isLoading = false
        } catch {
            errorMessage = "Failed to delete defender: \(error.localizedDescription)"
            isLoading = false
        }
    }

    /// Clones a defender with a new ID
    public func cloneDefender(_ defender: Defender) async {
        let cloned = Defender(
            id: UUID().uuidString,
            name: "\(defender.name) (Copy)",
            toughness: defender.toughness,
            save: defender.save,
            invulnerableSave: defender.invulnerableSave,
            feelNoPain: defender.feelNoPain,
            wounds: defender.wounds,
            modelCount: defender.modelCount,
            createdAt: Date(),
            updatedAt: Date()
        )

        await saveDefender(cloned)
    }

    /// Searches defenders using full-text search
    public func searchDefenders(_ query: String) async {
        guard !query.isEmpty else {
            await loadDefenders(reset: true)
            return
        }

        isLoading = true
        errorMessage = nil

        do {
            defenders = try await defenderRepository.search(query)
            hasMoreDefenders = false // Search returns all results
            isLoading = false
        } catch {
            errorMessage = "Search failed: \(error.localizedDescription)"
            isLoading = false
        }
    }

    // MARK: - General Operations

    /// Updates the search query
    public func updateSearchQuery(_ query: String) {
        searchQuery = query
    }

    /// Refreshes both weapons and defenders
    public func refresh() async {
        await loadWeapons(reset: true)
        await loadDefenders(reset: true)
    }

    /// Resets all state
    public func reset() {
        weapons = []
        defenders = []
        searchQuery = ""
        isLoading = false
        errorMessage = nil
        weaponsPage = 0
        defendersPage = 0
        hasMoreWeapons = true
        hasMoreDefenders = true
    }
}
