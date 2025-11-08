//
//  ProbabilityEngineTests.swift
//  MobileDiceRoller
//
//  Created on 2025-11-08.
//

import XCTest
@testable import MobileDiceRoller

/// Unit tests for the ProbabilityEngine service
///
/// Following TDD approach: Tests written first, implementation follows.
/// Target: 80%+ code coverage
final class ProbabilityEngineTests: XCTestCase {

    // MARK: - Properties

    var sut: ProbabilityCalculating!

    // MARK: - Setup & Teardown

    override func setUp() {
        super.setUp()
        sut = ProbabilityEngine()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    // MARK: - Hit Roll Tests

    func testCalculateHitProbability_BS2Plus() {
        // Arrange & Act
        let probability = sut.calculateHitProbability(skill: 2)

        // Assert
        XCTAssertEqual(probability, 5.0/6.0, accuracy: 0.001)
    }

    func testCalculateHitProbability_BS3Plus() {
        // Arrange & Act
        let probability = sut.calculateHitProbability(skill: 3)

        // Assert
        XCTAssertEqual(probability, 4.0/6.0, accuracy: 0.001)
    }

    func testCalculateHitProbability_BS4Plus() {
        // Arrange & Act
        let probability = sut.calculateHitProbability(skill: 4)

        // Assert
        XCTAssertEqual(probability, 3.0/6.0, accuracy: 0.001)
    }

    func testCalculateHitProbability_BS5Plus() {
        // Arrange & Act
        let probability = sut.calculateHitProbability(skill: 5)

        // Assert
        XCTAssertEqual(probability, 2.0/6.0, accuracy: 0.001)
    }

    func testCalculateHitProbability_BS6Plus() {
        // Arrange & Act
        let probability = sut.calculateHitProbability(skill: 6)

        // Assert
        XCTAssertEqual(probability, 1.0/6.0, accuracy: 0.001)
    }

    func testCalculateHitProbability_InvalidSkillTooLow() {
        // Arrange & Act
        let probability = sut.calculateHitProbability(skill: 1)

        // Assert - Skill of 1 is invalid, should return 0
        XCTAssertEqual(probability, 0.0)
    }

    func testCalculateHitProbability_InvalidSkillTooHigh() {
        // Arrange & Act
        let probability = sut.calculateHitProbability(skill: 7)

        // Assert - Skill of 7+ is invalid, should return 0
        XCTAssertEqual(probability, 0.0)
    }

    // MARK: - Wound Roll Tests (Strength vs Toughness)

    func testCalculateWoundProbability_StrengthDoubleOrMoreToughness() {
        // Arrange - S8 vs T4 (S ≥ T×2): Wound on 2+
        let strength = 8
        let toughness = 4

        // Act
        let probability = sut.calculateWoundProbability(strength: strength, toughness: toughness)

        // Assert
        XCTAssertEqual(probability, 5.0/6.0, accuracy: 0.001)
    }

    func testCalculateWoundProbability_StrengthGreaterThanToughness() {
        // Arrange - S5 vs T4 (S > T): Wound on 3+
        let strength = 5
        let toughness = 4

        // Act
        let probability = sut.calculateWoundProbability(strength: strength, toughness: toughness)

        // Assert
        XCTAssertEqual(probability, 4.0/6.0, accuracy: 0.001)
    }

    func testCalculateWoundProbability_StrengthEqualToughness() {
        // Arrange - S4 vs T4 (S = T): Wound on 4+
        let strength = 4
        let toughness = 4

        // Act
        let probability = sut.calculateWoundProbability(strength: strength, toughness: toughness)

        // Assert
        XCTAssertEqual(probability, 3.0/6.0, accuracy: 0.001)
    }

    func testCalculateWoundProbability_StrengthLessThanToughness() {
        // Arrange - S4 vs T5 (S < T but S×2 > T): Wound on 5+
        let strength = 4
        let toughness = 5

        // Act
        let probability = sut.calculateWoundProbability(strength: strength, toughness: toughness)

        // Assert
        XCTAssertEqual(probability, 2.0/6.0, accuracy: 0.001)
    }

    func testCalculateWoundProbability_StrengthHalfOrLessToughness() {
        // Arrange - S3 vs T6 (S×2 ≤ T): Wound on 6+
        let strength = 3
        let toughness = 6

        // Act
        let probability = sut.calculateWoundProbability(strength: strength, toughness: toughness)

        // Assert
        XCTAssertEqual(probability, 1.0/6.0, accuracy: 0.001)
    }

    func testCalculateWoundProbability_AllCombinations() {
        // Test all standard Strength vs Toughness combinations
        let combinations: [(s: Int, t: Int, expected: Double)] = [
            // S ≥ T×2
            (s: 6, t: 3, expected: 5.0/6.0),
            (s: 8, t: 4, expected: 5.0/6.0),
            (s: 10, t: 5, expected: 5.0/6.0),

            // S > T
            (s: 5, t: 4, expected: 4.0/6.0),
            (s: 6, t: 5, expected: 4.0/6.0),
            (s: 7, t: 6, expected: 4.0/6.0),

            // S = T
            (s: 3, t: 3, expected: 3.0/6.0),
            (s: 4, t: 4, expected: 3.0/6.0),
            (s: 5, t: 5, expected: 3.0/6.0),

            // S < T but S×2 > T
            (s: 4, t: 5, expected: 2.0/6.0),
            (s: 5, t: 6, expected: 2.0/6.0),
            (s: 6, t: 7, expected: 2.0/6.0),

            // S×2 ≤ T
            (s: 3, t: 6, expected: 1.0/6.0),
            (s: 4, t: 8, expected: 1.0/6.0),
            (s: 5, t: 10, expected: 1.0/6.0)
        ]

        for combo in combinations {
            let probability = sut.calculateWoundProbability(strength: combo.s, toughness: combo.t)
            XCTAssertEqual(
                probability,
                combo.expected,
                accuracy: 0.001,
                "S\(combo.s) vs T\(combo.t) should be \(combo.expected)"
            )
        }
    }

    // MARK: - Save Roll Tests

    func testCalculateSaveFailProbability_BasicArmorSave() {
        // Arrange - 3+ save, no AP, no invuln
        let save = 3
        let ap = 0
        let invuln: Int? = nil

        // Act
        let probability = sut.calculateSaveFailProbability(
            save: save,
            armorPenetration: ap,
            invulnerable: invuln
        )

        // Assert - 3+ save fails on 1-2 (2/6)
        XCTAssertEqual(probability, 2.0/6.0, accuracy: 0.001)
    }

    func testCalculateSaveFailProbability_ArmorSaveWithAP() {
        // Arrange - 3+ save with AP-2 becomes 5+ save
        let save = 3
        let ap = -2
        let invuln: Int? = nil

        // Act
        let probability = sut.calculateSaveFailProbability(
            save: save,
            armorPenetration: ap,
            invulnerable: invuln
        )

        // Assert - 5+ save fails on 1-4 (4/6)
        XCTAssertEqual(probability, 4.0/6.0, accuracy: 0.001)
    }

    func testCalculateSaveFailProbability_InvulnerableSaveBetter() {
        // Arrange - 3+ armor with AP-4 (would be 7+) but 4+ invuln
        let save = 3
        let ap = -4
        let invuln = 4

        // Act
        let probability = sut.calculateSaveFailProbability(
            save: save,
            armorPenetration: ap,
            invulnerable: invuln
        )

        // Assert - Uses 4+ invuln, fails on 1-3 (3/6)
        XCTAssertEqual(probability, 3.0/6.0, accuracy: 0.001)
    }

    func testCalculateSaveFailProbability_ArmorSaveBetter() {
        // Arrange - 2+ armor with AP0, 4+ invuln
        let save = 2
        let ap = 0
        let invuln = 4

        // Act
        let probability = sut.calculateSaveFailProbability(
            save: save,
            armorPenetration: ap,
            invulnerable: invuln
        )

        // Assert - Uses 2+ armor (better), fails on 1 (1/6)
        XCTAssertEqual(probability, 1.0/6.0, accuracy: 0.001)
    }

    func testCalculateSaveFailProbability_NoSavePossible() {
        // Arrange - 6+ save with AP-2 becomes 8+ (impossible)
        let save = 6
        let ap = -2
        let invuln: Int? = nil

        // Act
        let probability = sut.calculateSaveFailProbability(
            save: save,
            armorPenetration: ap,
            invulnerable: invuln
        )

        // Assert - Impossible save, always fails (1.0)
        XCTAssertEqual(probability, 1.0, accuracy: 0.001)
    }

    // MARK: - Feel No Pain Tests

    func testCalculateFeelNoPainProbability_FNP5Plus() {
        // Arrange
        let fnp = 5

        // Act
        let probability = sut.calculateFeelNoPainProbability(feelNoPain: fnp)

        // Assert - 5+ succeeds on 5-6 (2/6)
        XCTAssertEqual(probability, 2.0/6.0, accuracy: 0.001)
    }

    func testCalculateFeelNoPainProbability_FNP6Plus() {
        // Arrange
        let fnp = 6

        // Act
        let probability = sut.calculateFeelNoPainProbability(feelNoPain: fnp)

        // Assert - 6+ succeeds on 6 (1/6)
        XCTAssertEqual(probability, 1.0/6.0, accuracy: 0.001)
    }

    func testCalculateFeelNoPainProbability_NoFNP() {
        // Arrange
        let fnp: Int? = nil

        // Act
        let probability = sut.calculateFeelNoPainProbability(feelNoPain: fnp)

        // Assert - No FNP, probability is 0
        XCTAssertEqual(probability, 0.0)
    }

    // MARK: - Full Combat Result Tests

    func testCalculateCombatResult_BoltRifleVsSpaceMarine() {
        // Arrange
        let weapon = Weapon.boltRifle()  // A2 BS3+ S4 AP-1 D1
        let defender = Defender.spaceMarine()  // T4 Sv3+ W2

        // Act
        let result = sut.calculateCombatResult(weapon: weapon, defender: defender)

        // Assert
        // Expected hits: 2 attacks × 4/6 hit = 1.333
        XCTAssertEqual(result.expectedHits, 2.0 * 4.0/6.0, accuracy: 0.01)

        // Expected wounds: 1.333 hits × 3/6 wound (S4 vs T4) = 0.667
        XCTAssertEqual(result.expectedWounds, 2.0 * 4.0/6.0 * 3.0/6.0, accuracy: 0.01)

        // Save fail: 3+ with AP-1 = 4+ = fails on 1-3 (3/6)
        XCTAssertEqual(result.saveFailProbability, 3.0/6.0, accuracy: 0.01)

        // Expected unsaved wounds: 0.667 × 3/6 = 0.333
        XCTAssertEqual(result.expectedUnsavedWounds, 2.0 * 4.0/6.0 * 3.0/6.0 * 3.0/6.0, accuracy: 0.01)
    }

    func testCalculateCombatResult_PlasmaGunVsTerminator() {
        // Arrange
        let weapon = Weapon.plasmaGun()  // A1 BS3+ S7 AP-2 D1
        let defender = Defender.terminator()  // T5 Sv2+ Inv4+ W3

        // Act
        let result = sut.calculateCombatResult(weapon: weapon, defender: defender)

        // Assert
        // Expected hits: 1 × 4/6 = 0.667
        XCTAssertEqual(result.expectedHits, 4.0/6.0, accuracy: 0.01)

        // Expected wounds: 0.667 × 4/6 (S7 vs T5, S > T) = 0.444
        XCTAssertEqual(result.expectedWounds, 4.0/6.0 * 4.0/6.0, accuracy: 0.01)

        // Save: 2+ with AP-2 = 4+, but has 4+ invuln, uses invuln
        // Save fail: 4+ fails on 1-3 (3/6)
        XCTAssertEqual(result.saveFailProbability, 3.0/6.0, accuracy: 0.01)
    }

    func testCalculateCombatResult_WithFeelNoPain() {
        // Arrange
        let weapon = Weapon.bolter()  // A2 BS3+ S4 AP0 D1
        let defender = Defender.plagueMarine()  // T5 Sv3+ FNP5+ W2

        // Act
        let result = sut.calculateCombatResult(weapon: weapon, defender: defender)

        // Assert - Result should account for FNP reducing final damage
        // FNP 5+ passes 2/6 times, so 1/3 of damage is ignored
        XCTAssertGreaterThan(result.expectedDamage, 0)

        // The expectedDamage should be less than without FNP due to FNP mitigation
    }

    // MARK: - Edge Case Tests

    func testCalculateCombatResult_ZeroAttacks() {
        // Arrange
        let weapon = Weapon(name: "Test", attacks: 0, skill: 3, strength: 4, armorPenetration: 0, damage: "1")
        let defender = Defender.spaceMarine()

        // Act
        let result = sut.calculateCombatResult(weapon: weapon, defender: defender)

        // Assert
        XCTAssertEqual(result.expectedHits, 0.0)
        XCTAssertEqual(result.expectedWounds, 0.0)
        XCTAssertEqual(result.expectedDamage, 0.0)
    }

    func testCalculateCombatResult_HighStrengthLowToughness() {
        // Arrange - Lascannon vs Guardsman
        let weapon = Weapon(name: "Lascannon", attacks: 1, skill: 3, strength: 12, armorPenetration: -3, damage: "D6")
        let defender = Defender.guardsman()  // T3 Sv5+ W1

        // Act
        let result = sut.calculateCombatResult(weapon: weapon, defender: defender)

        // Assert - S12 vs T3 (S ≥ T×2) = 2+ to wound
        XCTAssertEqual(result.woundProbability, 5.0/6.0, accuracy: 0.01)
    }
}
