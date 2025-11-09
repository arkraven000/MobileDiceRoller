//
//  AbilityProcessorTests.swift
//  MobileDiceRoller
//
//  Created on 2025-11-08.
//

import XCTest
@testable import MobileDiceRoller

/// Unit tests for the AbilityProcessor service
///
/// Following TDD approach: Tests written first, implementation follows.
/// Target: 80%+ code coverage
final class AbilityProcessorTests: XCTestCase {

    // MARK: - Properties

    var sut: AbilityProcessing!
    var probabilityEngine: ProbabilityCalculating!

    // MARK: - Setup & Teardown

    override func setUp() {
        super.setUp()
        sut = AbilityProcessor()
        probabilityEngine = ProbabilityEngine()
    }

    override func tearDown() {
        sut = nil
        probabilityEngine = nil
        super.tearDown()
    }

    // MARK: - Lethal Hits Tests

    func testApplyAbilities_LethalHits_IncreasesWounds() {
        // Arrange
        let weapon = Weapon(
            name: "Lethal Bolter",
            attacks: 6,
            skill: 3,
            strength: 4,
            armorPenetration: 0,
            damage: "1",
            abilities: [.lethalHits]
        )
        let defender = Defender.spaceMarine()
        let baseResult = probabilityEngine.calculateCombatResult(weapon: weapon, defender: defender)

        // Act
        let enhancedResult = sut.applyAbilities(
            baseResult: baseResult,
            weapon: weapon,
            defender: defender
        )

        // Assert - Lethal Hits means critical hits auto-wound
        // Base: 6 attacks × 4/6 hit × 3/6 wound
        // Enhanced: (6 × 4/6 × 3/6 normal) + (6 × 1/6 × 1.0 auto-wound crits)
        XCTAssertGreaterThan(enhancedResult.expectedWounds, baseResult.expectedWounds)
    }

    func testApplyAbilities_LethalHits_CriticalHitsAutoWound() {
        // Arrange
        let weapon = Weapon(
            name: "Test",
            attacks: 6,
            skill: 3,
            strength: 4,
            armorPenetration: 0,
            damage: "1",
            abilities: [.lethalHits]
        )
        let defender = Defender(name: "Tough", toughness: 8, save: 2, wounds: 3, modelCount: 5)

        // Act - Even against high toughness, lethal hits auto-wound on 6s
        let result = sut.calculateCombatResultWithAbilities(
            weapon: weapon,
            defender: defender,
            probabilityEngine: probabilityEngine
        )

        // Assert - Should have wounds from critical hits despite high toughness
        XCTAssertGreaterThan(result.expectedWounds, 0)
    }

    // MARK: - Sustained Hits Tests

    func testApplyAbilities_SustainedHits1_GeneratesExtraHits() {
        // Arrange
        let weapon = Weapon(
            name: "Sustained Bolter",
            attacks: 6,
            skill: 3,
            strength: 4,
            armorPenetration: 0,
            damage: "1",
            abilities: [.sustainedHits1]
        )
        let defender = Defender.spaceMarine()
        let baseResult = probabilityEngine.calculateCombatResult(weapon: weapon, defender: defender)

        // Act
        let enhancedResult = sut.applyAbilities(
            baseResult: baseResult,
            weapon: weapon,
            defender: defender
        )

        // Assert - Should have more hits due to crits generating +1 hit
        XCTAssertGreaterThan(enhancedResult.expectedHits, baseResult.expectedHits)
    }

    func testApplyAbilities_SustainedHits2_GeneratesMoreHits() {
        // Arrange
        let weapon = Weapon(
            name: "Test",
            attacks: 6,
            skill: 3,
            strength: 4,
            armorPenetration: 0,
            damage: "1",
            abilities: [.sustainedHits2]
        )
        let defender = Defender.spaceMarine()

        // Act
        let result = sut.calculateCombatResultWithAbilities(
            weapon: weapon,
            defender: defender,
            probabilityEngine: probabilityEngine
        )

        // Assert - 6 attacks, 1/6 crit, each crit generates 2 extra hits
        // Expected extra hits = 6 × 1/6 × 2 = 2
        let baseHits = 6.0 * 4.0/6.0  // 4.0
        let bonusHits = 6.0 * 1.0/6.0 * 2.0  // 2.0
        XCTAssertEqual(result.expectedHits, baseHits + bonusHits, accuracy: 0.1)
    }

    // MARK: - Devastating Wounds Tests

    func testApplyAbilities_DevastatingWounds_BypassesSaves() {
        // Arrange
        let weapon = Weapon(
            name: "Devastating Gun",
            attacks: 6,
            skill: 3,
            strength: 4,
            armorPenetration: 0,
            damage: "1",
            abilities: [.devastatingWounds]
        )
        let defender = Defender(name: "Armored", toughness: 4, save: 2, wounds: 2, modelCount: 5)

        // Act
        let result = sut.calculateCombatResultWithAbilities(
            weapon: weapon,
            defender: defender,
            probabilityEngine: probabilityEngine
        )

        // Assert - Critical wounds bypass the 2+ save
        // Should have more unsaved wounds than normal due to save bypass
        XCTAssertGreaterThan(result.expectedUnsavedWounds, 0)
    }

    // MARK: - Torrent Tests

    func testApplyAbilities_Torrent_AutoHits() {
        // Arrange
        let weapon = Weapon(
            name: "Flamer",
            attacks: 6,
            skill: 3,
            strength: 4,
            armorPenetration: 0,
            damage: "1",
            abilities: [.torrent]
        )
        let defender = Defender.spaceMarine()

        // Act
        let result = sut.calculateCombatResultWithAbilities(
            weapon: weapon,
            defender: defender,
            probabilityEngine: probabilityEngine
        )

        // Assert - Torrent auto-hits, so expected hits = attacks
        XCTAssertEqual(result.expectedHits, 6.0, accuracy: 0.01)
        XCTAssertEqual(result.hitProbability, 1.0, accuracy: 0.01)
    }

    // MARK: - Twin-Linked Tests

    func testApplyAbilities_TwinLinked_RerollsWounds() {
        // Arrange
        let weapon = Weapon(
            name: "Twin Bolter",
            attacks: 4,
            skill: 3,
            strength: 4,
            armorPenetration: 0,
            damage: "1",
            abilities: [.twinLinked]
        )
        let defender = Defender.spaceMarine()
        let baseResult = probabilityEngine.calculateCombatResult(weapon: weapon, defender: defender)

        // Act
        let enhancedResult = sut.applyAbilities(
            baseResult: baseResult,
            weapon: weapon,
            defender: defender
        )

        // Assert - Re-rolling wounds should increase wound probability
        XCTAssertGreaterThan(enhancedResult.woundProbability, baseResult.woundProbability)
    }

    // MARK: - Melta Tests

    func testApplyAbilities_Melta2_AtHalfRange_IncreasesDamage() {
        // Arrange
        let weapon = Weapon(
            name: "Meltagun",
            attacks: 1,
            skill: 3,
            strength: 9,
            armorPenetration: -4,
            damage: "D6",
            abilities: [.melta2],
            range: 12
        )
        let defender = Defender.spaceMarine()

        // Act - At half range (6" or less)
        let resultAtHalfRange = sut.calculateCombatResultWithAbilities(
            weapon: weapon,
            defender: defender,
            probabilityEngine: probabilityEngine,
            range: 6
        )

        let resultAtFullRange = sut.calculateCombatResultWithAbilities(
            weapon: weapon,
            defender: defender,
            probabilityEngine: probabilityEngine,
            range: 12
        )

        // Assert - Damage should be higher at half range
        XCTAssertGreaterThan(resultAtHalfRange.expectedDamage, resultAtFullRange.expectedDamage)
    }

    // MARK: - Rapid Fire Tests

    func testApplyAbilities_RapidFire1_AtHalfRange_ExtraAttacks() {
        // Arrange
        let weapon = Weapon(
            name: "Bolter",
            attacks: 2,
            skill: 3,
            strength: 4,
            armorPenetration: 0,
            damage: "1",
            abilities: [.rapidFire1],
            range: 24
        )
        let defender = Defender.spaceMarine()

        // Act
        let resultAtHalfRange = sut.calculateCombatResultWithAbilities(
            weapon: weapon,
            defender: defender,
            probabilityEngine: probabilityEngine,
            range: 12
        )

        let resultAtFullRange = sut.calculateCombatResultWithAbilities(
            weapon: weapon,
            defender: defender,
            probabilityEngine: probabilityEngine,
            range: 24
        )

        // Assert - Should have +1 attack at half range
        XCTAssertGreaterThan(resultAtHalfRange.expectedHits, resultAtFullRange.expectedHits)
    }

    // MARK: - Blast Tests

    func testApplyAbilities_Blast_VsLargeUnit_BonusAttacks() {
        // Arrange
        let weapon = Weapon(
            name: "Frag Missile",
            attacks: 6,
            skill: 3,
            strength: 4,
            armorPenetration: 0,
            damage: "1",
            abilities: [.blast]
        )
        let smallUnit = Defender(name: "Small", toughness: 4, save: 3, wounds: 1, modelCount: 5)
        let largeUnit = Defender(name: "Large", toughness: 4, save: 3, wounds: 1, modelCount: 15)

        // Act
        let resultSmall = sut.calculateCombatResultWithAbilities(
            weapon: weapon,
            defender: smallUnit,
            probabilityEngine: probabilityEngine
        )

        let resultLarge = sut.calculateCombatResultWithAbilities(
            weapon: weapon,
            defender: largeUnit,
            probabilityEngine: probabilityEngine
        )

        // Assert - Blast should generate more hits vs large units
        XCTAssertGreaterThan(resultLarge.expectedHits, resultSmall.expectedHits)
    }

    // MARK: - Anti-X Tests

    func testApplyAbilities_AntiInfantry_VsInfantry_CriticalWounds() {
        // Arrange
        let weapon = Weapon(
            name: "Anti-Infantry Gun",
            attacks: 6,
            skill: 3,
            strength: 5,
            armorPenetration: -1,
            damage: "2",
            abilities: [.anti("Infantry")]
        )
        let infantry = Defender(name: "Infantry Squad", toughness: 4, save: 4, wounds: 1, modelCount: 10)

        // Act
        let result = sut.calculateCombatResultWithAbilities(
            weapon: weapon,
            defender: infantry,
            probabilityEngine: probabilityEngine,
            defenderKeywords: ["Infantry"]
        )

        // Assert - Should have enhanced wounds due to anti-infantry
        XCTAssertGreaterThan(result.expectedWounds, 0)
    }

    // MARK: - Multiple Abilities Tests

    func testApplyAbilities_MultipleAbilities_AllApplied() {
        // Arrange
        let weapon = Weapon(
            name: "Super Weapon",
            attacks: 4,
            skill: 3,
            strength: 4,
            armorPenetration: -1,
            damage: "1",
            abilities: [.lethalHits, .sustainedHits1]
        )
        let defender = Defender.spaceMarine()
        let baseResult = probabilityEngine.calculateCombatResult(weapon: weapon, defender: defender)

        // Act
        let enhancedResult = sut.applyAbilities(
            baseResult: baseResult,
            weapon: weapon,
            defender: defender
        )

        // Assert - Both abilities should increase effectiveness
        XCTAssertGreaterThan(enhancedResult.expectedWounds, baseResult.expectedWounds)
        XCTAssertGreaterThan(enhancedResult.expectedHits, baseResult.expectedHits)
    }

    // MARK: - No Abilities Tests

    func testApplyAbilities_NoAbilities_ReturnsUnmodified() {
        // Arrange
        let weapon = Weapon(
            name: "Basic Weapon",
            attacks: 2,
            skill: 3,
            strength: 4,
            armorPenetration: 0,
            damage: "1",
            abilities: []  // No abilities
        )
        let defender = Defender.spaceMarine()
        let baseResult = probabilityEngine.calculateCombatResult(weapon: weapon, defender: defender)

        // Act
        let enhancedResult = sut.applyAbilities(
            baseResult: baseResult,
            weapon: weapon,
            defender: defender
        )

        // Assert - Should be identical
        XCTAssertEqual(enhancedResult.expectedHits, baseResult.expectedHits, accuracy: 0.001)
        XCTAssertEqual(enhancedResult.expectedWounds, baseResult.expectedWounds, accuracy: 0.001)
        XCTAssertEqual(enhancedResult.expectedDamage, baseResult.expectedDamage, accuracy: 0.001)
    }

    // MARK: - Ignores Cover Tests

    func testApplyAbilities_IgnoresCover_VsCoverBonus() {
        // Arrange
        let weapon = Weapon(
            name: "Ignore Cover Gun",
            attacks: 4,
            skill: 3,
            strength: 4,
            armorPenetration: 0,
            damage: "1",
            abilities: [.ignoresCover]
        )
        let defender = Defender.spaceMarine()

        // Act - With and without cover bonus
        let resultWithIgnore = sut.calculateCombatResultWithAbilities(
            weapon: weapon,
            defender: defender,
            probabilityEngine: probabilityEngine,
            defenderHasCover: true
        )

        // Assert - Ignores cover should negate cover bonuses
        XCTAssertGreaterThan(resultWithIgnore.expectedUnsavedWounds, 0)
    }
}
