//
//  DefenderTests.swift
//  MobileDiceRoller
//
//  Created on 2025-11-08.
//

import XCTest
@testable import MobileDiceRoller

/// Unit tests for the Defender domain model
///
/// Following TDD approach: Tests written first, implementation follows.
/// Target: 80%+ code coverage
final class DefenderTests: XCTestCase {

    // MARK: - Initialization Tests

    func testDefenderInitialization() {
        // Arrange & Act
        let defender = Defender(
            name: "Space Marine",
            toughness: 4,
            save: 3,
            invulnerableSave: nil,
            feelNoPain: nil,
            wounds: 2,
            modelCount: 10
        )

        // Assert
        XCTAssertEqual(defender.name, "Space Marine")
        XCTAssertEqual(defender.toughness, 4)
        XCTAssertEqual(defender.save, 3)
        XCTAssertNil(defender.invulnerableSave)
        XCTAssertNil(defender.feelNoPain)
        XCTAssertEqual(defender.wounds, 2)
        XCTAssertEqual(defender.modelCount, 10)
    }

    func testDefenderWithInvulnerableSave() {
        // Arrange & Act
        let defender = Defender(
            name: "Terminator",
            toughness: 5,
            save: 2,
            invulnerableSave: 4,
            feelNoPain: nil,
            wounds: 3,
            modelCount: 5
        )

        // Assert
        XCTAssertEqual(defender.invulnerableSave, 4)
        XCTAssertTrue(defender.hasInvulnerableSave)
    }

    func testDefenderWithFeelNoPain() {
        // Arrange & Act
        let defender = Defender(
            name: "Death Guard Marine",
            toughness: 5,
            save: 3,
            invulnerableSave: nil,
            feelNoPain: 5,
            wounds: 2,
            modelCount: 10
        )

        // Assert
        XCTAssertEqual(defender.feelNoPain, 5)
        XCTAssertTrue(defender.hasFeelNoPain)
    }

    // MARK: - Computed Property Tests

    func testHasInvulnerableSaveWhenPresent() {
        // Arrange
        let defender = Defender(
            name: "Storm Shield Marine",
            toughness: 4,
            save: 3,
            invulnerableSave: 4,
            feelNoPain: nil,
            wounds: 2,
            modelCount: 5
        )

        // Act & Assert
        XCTAssertTrue(defender.hasInvulnerableSave)
    }

    func testHasInvulnerableSaveWhenAbsent() {
        // Arrange
        let defender = Defender(
            name: "Guardsman",
            toughness: 3,
            save: 5,
            invulnerableSave: nil,
            feelNoPain: nil,
            wounds: 1,
            modelCount: 10
        )

        // Act & Assert
        XCTAssertFalse(defender.hasInvulnerableSave)
    }

    func testHasFeelNoPainWhenPresent() {
        // Arrange
        let defender = Defender(
            name: "Plague Marine",
            toughness: 5,
            save: 3,
            invulnerableSave: nil,
            feelNoPain: 5,
            wounds: 2,
            modelCount: 7
        )

        // Act & Assert
        XCTAssertTrue(defender.hasFeelNoPain)
    }

    func testHasFeelNoPainWhenAbsent() {
        // Arrange
        let defender = Defender(
            name: "Scout",
            toughness: 4,
            save: 4,
            invulnerableSave: nil,
            feelNoPain: nil,
            wounds: 1,
            modelCount: 5
        )

        // Act & Assert
        XCTAssertFalse(defender.hasFeelNoPain)
    }

    func testTotalWounds() {
        // Arrange
        let defender = Defender(
            name: "Intercessor Squad",
            toughness: 4,
            save: 3,
            invulnerableSave: nil,
            feelNoPain: nil,
            wounds: 2,
            modelCount: 5
        )

        // Act
        let total = defender.totalWounds

        // Assert
        XCTAssertEqual(total, 10) // 5 models × 2 wounds each
    }

    func testIsValidWithValidDefender() {
        // Arrange
        let defender = Defender(
            name: "Valid Unit",
            toughness: 4,
            save: 3,
            invulnerableSave: nil,
            feelNoPain: nil,
            wounds: 1,
            modelCount: 1
        )

        // Act & Assert
        XCTAssertTrue(defender.isValid)
    }

    func testIsValidWithZeroWounds() {
        // Arrange
        let defender = Defender(
            name: "Invalid Unit",
            toughness: 4,
            save: 3,
            invulnerableSave: nil,
            feelNoPain: nil,
            wounds: 0,
            modelCount: 5
        )

        // Act & Assert
        XCTAssertFalse(defender.isValid)
    }

    func testIsValidWithZeroModels() {
        // Arrange
        let defender = Defender(
            name: "Dead Unit",
            toughness: 4,
            save: 3,
            invulnerableSave: nil,
            feelNoPain: nil,
            wounds: 2,
            modelCount: 0
        )

        // Act & Assert
        XCTAssertFalse(defender.isValid)
    }

    func testIsValidWithInvalidSaveTooLow() {
        // Arrange
        let defender = Defender(
            name: "Invalid Save",
            toughness: 4,
            save: 1,
            invulnerableSave: nil,
            feelNoPain: nil,
            wounds: 1,
            modelCount: 1
        )

        // Act & Assert
        XCTAssertFalse(defender.isValid)
    }

    func testIsValidWithInvalidSaveTooHigh() {
        // Arrange
        let defender = Defender(
            name: "Invalid Save",
            toughness: 4,
            save: 7,
            invulnerableSave: nil,
            feelNoPain: nil,
            wounds: 1,
            modelCount: 1
        )

        // Act & Assert
        XCTAssertFalse(defender.isValid)
    }

    // MARK: - Equatable Tests

    func testEquatableWithIdenticalDefenders() {
        // Arrange
        let defender1 = Defender(
            name: "Space Marine",
            toughness: 4,
            save: 3,
            invulnerableSave: nil,
            feelNoPain: nil,
            wounds: 2,
            modelCount: 5
        )

        let defender2 = Defender(
            name: "Space Marine",
            toughness: 4,
            save: 3,
            invulnerableSave: nil,
            feelNoPain: nil,
            wounds: 2,
            modelCount: 5
        )

        // Act & Assert
        XCTAssertEqual(defender1, defender2)
    }

    func testEquatableWithDifferentNames() {
        // Arrange
        let defender1 = Defender(name: "Space Marine", toughness: 4, save: 3, wounds: 2, modelCount: 5)
        let defender2 = Defender(name: "Terminator", toughness: 4, save: 3, wounds: 2, modelCount: 5)

        // Act & Assert
        XCTAssertNotEqual(defender1, defender2)
    }

    func testEquatableWithDifferentStats() {
        // Arrange
        let defender1 = Defender(name: "Unit", toughness: 4, save: 3, wounds: 2, modelCount: 5)
        let defender2 = Defender(name: "Unit", toughness: 5, save: 3, wounds: 2, modelCount: 5)

        // Act & Assert
        XCTAssertNotEqual(defender1, defender2)
    }

    // MARK: - Codable Tests

    func testEncodingDefender() throws {
        // Arrange
        let defender = Defender(
            name: "Space Marine",
            toughness: 4,
            save: 3,
            invulnerableSave: 4,
            feelNoPain: 6,
            wounds: 2,
            modelCount: 10
        )

        // Act
        let encoder = JSONEncoder()
        let data = try encoder.encode(defender)

        // Assert
        XCTAssertFalse(data.isEmpty)
    }

    func testDecodingDefender() throws {
        // Arrange
        let json = """
        {
            "name": "Space Marine",
            "toughness": 4,
            "save": 3,
            "invulnerableSave": 4,
            "feelNoPain": 6,
            "wounds": 2,
            "modelCount": 10
        }
        """.data(using: .utf8)!

        // Act
        let decoder = JSONDecoder()
        let defender = try decoder.decode(Defender.self, from: json)

        // Assert
        XCTAssertEqual(defender.name, "Space Marine")
        XCTAssertEqual(defender.toughness, 4)
        XCTAssertEqual(defender.save, 3)
        XCTAssertEqual(defender.invulnerableSave, 4)
        XCTAssertEqual(defender.feelNoPain, 6)
        XCTAssertEqual(defender.wounds, 2)
        XCTAssertEqual(defender.modelCount, 10)
    }

    func testRoundTripEncoding() throws {
        // Arrange
        let original = Defender(
            name: "Terminator",
            toughness: 5,
            save: 2,
            invulnerableSave: 4,
            feelNoPain: nil,
            wounds: 3,
            modelCount: 5
        )

        // Act
        let encoder = JSONEncoder()
        let data = try encoder.encode(original)

        let decoder = JSONDecoder()
        let decoded = try decoder.decode(Defender.self, from: data)

        // Assert
        XCTAssertEqual(original, decoded)
    }

    // MARK: - Edge Case Tests

    func testDefenderWithMaximumToughness() {
        // Arrange
        let defender = Defender(
            name: "Knight",
            toughness: 12,
            save: 3,
            invulnerableSave: 5,
            feelNoPain: nil,
            wounds: 24,
            modelCount: 1
        )

        // Act & Assert
        XCTAssertEqual(defender.toughness, 12)
        XCTAssertTrue(defender.isValid)
    }

    func testDefenderWithLargeSquad() {
        // Arrange
        let defender = Defender(
            name: "Guard Squad",
            toughness: 3,
            save: 5,
            invulnerableSave: nil,
            feelNoPain: nil,
            wounds: 1,
            modelCount: 20
        )

        // Act & Assert
        XCTAssertEqual(defender.totalWounds, 20)
    }

    // MARK: - Factory Method Tests

    func testSpaceMarineFactoryMethod() {
        // Act
        let spaceMarine = Defender.spaceMarine()

        // Assert
        XCTAssertEqual(spaceMarine.name, "Space Marine")
        XCTAssertEqual(spaceMarine.toughness, 4)
        XCTAssertEqual(spaceMarine.save, 3)
        XCTAssertNil(spaceMarine.invulnerableSave)
        XCTAssertNil(spaceMarine.feelNoPain)
        XCTAssertEqual(spaceMarine.wounds, 2)
        XCTAssertTrue(spaceMarine.isValid)
    }
}
