//
//  WeaponTests.swift
//  MobileDiceRoller
//
//  Created on 2025-11-08.
//

import XCTest
@testable import MobileDiceRoller

/// Unit tests for the Weapon domain model
///
/// Following TDD approach: Tests written first, implementation follows.
/// Target: 80%+ code coverage
final class WeaponTests: XCTestCase {

    // MARK: - Initialization Tests

    func testWeaponInitialization() {
        // Arrange & Act
        let weapon = Weapon(
            name: "Bolt Rifle",
            attacks: 2,
            skill: 3,
            strength: 4,
            armorPenetration: -1,
            damage: "1",
            abilities: [],
            range: 24
        )

        // Assert
        XCTAssertEqual(weapon.name, "Bolt Rifle")
        XCTAssertEqual(weapon.attacks, 2)
        XCTAssertEqual(weapon.skill, 3)
        XCTAssertEqual(weapon.strength, 4)
        XCTAssertEqual(weapon.armorPenetration, -1)
        XCTAssertEqual(weapon.damage, "1")
        XCTAssertTrue(weapon.abilities.isEmpty)
        XCTAssertEqual(weapon.range, 24)
    }

    func testMeleeWeaponInitialization() {
        // Arrange & Act
        let weapon = Weapon(
            name: "Chainsword",
            attacks: 4,
            skill: 3,
            strength: 4,
            armorPenetration: -1,
            damage: "1",
            abilities: [],
            range: nil
        )

        // Assert
        XCTAssertEqual(weapon.name, "Chainsword")
        XCTAssertNil(weapon.range)
        XCTAssertFalse(weapon.isRanged)
    }

    // MARK: - Computed Property Tests

    func testIsRangedForRangedWeapon() {
        // Arrange
        let weapon = Weapon(
            name: "Bolter",
            attacks: 2,
            skill: 3,
            strength: 4,
            armorPenetration: 0,
            damage: "1",
            range: 24
        )

        // Act & Assert
        XCTAssertTrue(weapon.isRanged)
    }

    func testIsRangedForMeleeWeapon() {
        // Arrange
        let weapon = Weapon(
            name: "Power Sword",
            attacks: 3,
            skill: 2,
            strength: 5,
            armorPenetration: -2,
            damage: "1",
            range: nil
        )

        // Act & Assert
        XCTAssertFalse(weapon.isRanged)
    }

    func testIsValidForCombatWithValidWeapon() {
        // Arrange
        let weapon = Weapon(
            name: "Valid Weapon",
            attacks: 1,
            skill: 3,
            strength: 4,
            armorPenetration: 0,
            damage: "1"
        )

        // Act & Assert
        XCTAssertTrue(weapon.isValidForCombat)
    }

    func testIsValidForCombatWithZeroAttacks() {
        // Arrange
        let weapon = Weapon(
            name: "Zero Attacks",
            attacks: 0,
            skill: 3,
            strength: 4,
            armorPenetration: 0,
            damage: "1"
        )

        // Act & Assert
        XCTAssertFalse(weapon.isValidForCombat)
    }

    func testIsValidForCombatWithInvalidSkillTooLow() {
        // Arrange
        let weapon = Weapon(
            name: "Invalid Skill",
            attacks: 2,
            skill: 1,
            strength: 4,
            armorPenetration: 0,
            damage: "1"
        )

        // Act & Assert
        XCTAssertFalse(weapon.isValidForCombat)
    }

    func testIsValidForCombatWithInvalidSkillTooHigh() {
        // Arrange
        let weapon = Weapon(
            name: "Invalid Skill",
            attacks: 2,
            skill: 7,
            strength: 4,
            armorPenetration: 0,
            damage: "1"
        )

        // Act & Assert
        XCTAssertFalse(weapon.isValidForCombat)
    }

    // MARK: - Equatable Tests

    func testEquatableWithIdenticalWeapons() {
        // Arrange
        let weapon1 = Weapon(
            name: "Bolter",
            attacks: 2,
            skill: 3,
            strength: 4,
            armorPenetration: 0,
            damage: "1",
            range: 24
        )

        let weapon2 = Weapon(
            name: "Bolter",
            attacks: 2,
            skill: 3,
            strength: 4,
            armorPenetration: 0,
            damage: "1",
            range: 24
        )

        // Act & Assert
        XCTAssertEqual(weapon1, weapon2)
    }

    func testEquatableWithDifferentNames() {
        // Arrange
        let weapon1 = Weapon(name: "Bolter", attacks: 2, skill: 3, strength: 4, armorPenetration: 0, damage: "1")
        let weapon2 = Weapon(name: "Plasma Gun", attacks: 2, skill: 3, strength: 4, armorPenetration: 0, damage: "1")

        // Act & Assert
        XCTAssertNotEqual(weapon1, weapon2)
    }

    func testEquatableWithDifferentStats() {
        // Arrange
        let weapon1 = Weapon(name: "Bolter", attacks: 2, skill: 3, strength: 4, armorPenetration: 0, damage: "1")
        let weapon2 = Weapon(name: "Bolter", attacks: 3, skill: 3, strength: 4, armorPenetration: 0, damage: "1")

        // Act & Assert
        XCTAssertNotEqual(weapon1, weapon2)
    }

    // MARK: - Codable Tests

    func testEncodingWeapon() throws {
        // Arrange
        let weapon = Weapon(
            name: "Bolt Rifle",
            attacks: 2,
            skill: 3,
            strength: 4,
            armorPenetration: -1,
            damage: "1",
            range: 24
        )

        // Act
        let encoder = JSONEncoder()
        let data = try encoder.encode(weapon)

        // Assert
        XCTAssertFalse(data.isEmpty)
    }

    func testDecodingWeapon() throws {
        // Arrange
        let json = """
        {
            "name": "Bolt Rifle",
            "attacks": 2,
            "skill": 3,
            "strength": 4,
            "armorPenetration": -1,
            "damage": "1",
            "abilities": [],
            "range": 24
        }
        """.data(using: .utf8)!

        // Act
        let decoder = JSONDecoder()
        let weapon = try decoder.decode(Weapon.self, from: json)

        // Assert
        XCTAssertEqual(weapon.name, "Bolt Rifle")
        XCTAssertEqual(weapon.attacks, 2)
        XCTAssertEqual(weapon.skill, 3)
        XCTAssertEqual(weapon.strength, 4)
        XCTAssertEqual(weapon.armorPenetration, -1)
        XCTAssertEqual(weapon.damage, "1")
        XCTAssertEqual(weapon.range, 24)
    }

    func testRoundTripEncoding() throws {
        // Arrange
        let original = Weapon(
            name: "Plasma Gun",
            attacks: 1,
            skill: 3,
            strength: 8,
            armorPenetration: -3,
            damage: "2",
            range: 24
        )

        // Act
        let encoder = JSONEncoder()
        let data = try encoder.encode(original)

        let decoder = JSONDecoder()
        let decoded = try decoder.decode(Weapon.self, from: data)

        // Assert
        XCTAssertEqual(original, decoded)
    }

    // MARK: - Edge Case Tests

    func testWeaponWithVariableDamage() {
        // Arrange
        let weapon = Weapon(
            name: "Lascannon",
            attacks: 1,
            skill: 3,
            strength: 12,
            armorPenetration: -3,
            damage: "D6"
        )

        // Act & Assert
        XCTAssertEqual(weapon.damage, "D6")
    }

    func testWeaponWithMultipleAbilities() {
        // Arrange
        let abilities: [WeaponAbility] = [.lethalHits, .rapidFire(1)]
        let weapon = Weapon(
            name: "Special Bolter",
            attacks: 2,
            skill: 3,
            strength: 4,
            armorPenetration: -1,
            damage: "1",
            abilities: abilities,
            range: 24
        )

        // Act & Assert
        XCTAssertEqual(weapon.abilities.count, 2)
    }

    func testWeaponWithHighStrength() {
        // Arrange
        let weapon = Weapon(
            name: "Titan Weapon",
            attacks: 10,
            skill: 3,
            strength: 20,
            armorPenetration: -6,
            damage: "D6+6"
        )

        // Act & Assert
        XCTAssertEqual(weapon.strength, 20)
        XCTAssertTrue(weapon.isValidForCombat)
    }

    // MARK: - Factory Method Tests

    func testBoltRifleFactoryMethod() {
        // Act
        let boltRifle = Weapon.boltRifle()

        // Assert
        XCTAssertEqual(boltRifle.name, "Bolt Rifle")
        XCTAssertEqual(boltRifle.attacks, 2)
        XCTAssertEqual(boltRifle.skill, 3)
        XCTAssertEqual(boltRifle.strength, 4)
        XCTAssertEqual(boltRifle.armorPenetration, -1)
        XCTAssertEqual(boltRifle.damage, "1")
        XCTAssertEqual(boltRifle.range, 24)
        XCTAssertTrue(boltRifle.isValidForCombat)
    }
}
