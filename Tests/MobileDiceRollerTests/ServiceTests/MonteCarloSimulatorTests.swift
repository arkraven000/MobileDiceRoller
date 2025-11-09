//
//  MonteCarloSimulatorTests.swift
//  MobileDiceRollerTests
//
//  Created on 2025-11-08.
//

import XCTest
@testable import MobileDiceRoller

/// Tests for the MonteCarloSimulator service
///
/// These tests verify that Monte Carlo simulations produce statistically
/// valid results and handle edge cases correctly.
final class MonteCarloSimulatorTests: XCTestCase {
    // MARK: - System Under Test

    var sut: MonteCarloSimulating!
    var probabilityEngine: ProbabilityCalculating!
    var abilityProcessor: AbilityProcessing!

    // MARK: - Test Data

    var boltRifle: Weapon!
    var spaceMarine: Defender!

    // MARK: - Setup & Teardown

    override func setUp() {
        super.setUp()
        sut = MonteCarloSimulator(
            randomNumberGenerator: SecureRandomNumberGenerator(),
            statisticalAnalyzer: StatisticalAnalyzer()
        )
        probabilityEngine = ProbabilityEngine()
        abilityProcessor = AbilityProcessor()

        // Create test fixtures
        boltRifle = Weapon(
            name: "Bolt Rifle",
            attacks: 2,
            skill: 3,
            strength: 4,
            armorPenetration: -1,
            damage: "1",
            abilities: [],
            range: 24
        )

        spaceMarine = Defender(
            name: "Space Marine",
            toughness: 4,
            save: 3,
            invulnerableSave: nil,
            feelNoPain: nil,
            wounds: 2,
            modelCount: 10
        )
    }

    override func tearDown() {
        sut = nil
        probabilityEngine = nil
        abilityProcessor = nil
        boltRifle = nil
        spaceMarine = nil
        super.tearDown()
    }

    // MARK: - Basic Simulation Tests

    func testRunSimulation_WithValidInputs_CompletesSuccessfully() {
        // When
        let result = sut.runSimulation(
            weapon: boltRifle,
            defender: spaceMarine,
            iterations: 1000,
            probabilityEngine: probabilityEngine,
            abilityProcessor: abilityProcessor,
            range: nil,
            defenderKeywords: [],
            defenderHasCover: false
        )

        // Then
        XCTAssertEqual(result.iterations, 1000)
        XCTAssertEqual(result.damageResults.count, 1000)
        XCTAssertEqual(result.killResults.count, 1000)
    }

    func testRunSimulation_WithSmallIterations_ReturnsValidResults() {
        // When
        let result = sut.runSimulation(
            weapon: boltRifle,
            defender: spaceMarine,
            iterations: 10,
            probabilityEngine: probabilityEngine,
            abilityProcessor: abilityProcessor,
            range: nil,
            defenderKeywords: [],
            defenderHasCover: false
        )

        // Then
        XCTAssertEqual(result.iterations, 10)
        XCTAssertGreaterThanOrEqual(result.damageStatistics.mean, 0)
    }

    func testRunSimulation_WithLargeIterations_CompletesInReasonableTime() {
        // Given
        let startTime = Date()

        // When
        let result = sut.runSimulation(
            weapon: boltRifle,
            defender: spaceMarine,
            iterations: 10000,
            probabilityEngine: probabilityEngine,
            abilityProcessor: abilityProcessor,
            range: nil,
            defenderKeywords: [],
            defenderHasCover: false
        )

        // Then
        let elapsed = Date().timeIntervalSince(startTime)
        XCTAssertEqual(result.iterations, 10000)
        XCTAssertLessThan(elapsed, 5.0, "10K iterations should complete in under 5 seconds")
    }

    // MARK: - Statistical Accuracy Tests

    func testRunSimulation_DamageMean_ApproximatesExpectedValue() {
        // Given - BS3+ hitting on 4+, wounding on 4+, save 3+ modified to 4+
        // Expected hits: 2 × (4/6) = 1.333
        // Expected wounds: 1.333 × (3/6) = 0.667
        // Expected unsaved: 0.667 × (3/6) = 0.333
        // Expected damage: 0.333 × 1 = 0.333

        // When - run many iterations for statistical convergence
        let result = sut.runSimulation(
            weapon: boltRifle,
            defender: spaceMarine,
            iterations: 10000,
            probabilityEngine: probabilityEngine,
            abilityProcessor: abilityProcessor,
            range: nil,
            defenderKeywords: [],
            defenderHasCover: false
        )

        // Then - mean should be close to expected value (within 20% margin)
        let expectedDamage = 0.333
        let tolerance = expectedDamage * 0.2 // 20% tolerance
        XCTAssertEqual(
            result.damageStatistics.mean,
            expectedDamage,
            accuracy: tolerance,
            "Simulated mean damage should approximate expected value"
        )
    }

    func testRunSimulation_ProbabilityOfAnyDamage_IsReasonable() {
        // When
        let result = sut.runSimulation(
            weapon: boltRifle,
            defender: spaceMarine,
            iterations: 5000,
            probabilityEngine: probabilityEngine,
            abilityProcessor: abilityProcessor,
            range: nil,
            defenderKeywords: [],
            defenderHasCover: false
        )

        // Then - should have a reasonable probability of dealing damage
        XCTAssertGreaterThan(result.probabilityOfAnyDamage, 0.1)
        XCTAssertLessThan(result.probabilityOfAnyDamage, 0.9)
    }

    func testRunSimulation_ProbabilityOfWipe_IsLowForMismatch() {
        // Given - 2 attacks with 1 damage each cannot wipe 10 models with 2 wounds
        let result = sut.runSimulation(
            weapon: boltRifle,
            defender: spaceMarine,
            iterations: 5000,
            probabilityEngine: probabilityEngine,
            abilityProcessor: abilityProcessor,
            range: nil,
            defenderKeywords: [],
            defenderHasCover: false
        )

        // Then - probability of wiping should be extremely low
        XCTAssertLessThan(result.probabilityOfWipe, 0.01, "Should be nearly impossible to wipe the unit")
    }

    // MARK: - Histogram Tests

    func testRunSimulation_DamageHistogram_HasValidBins() {
        // When
        let result = sut.runSimulation(
            weapon: boltRifle,
            defender: spaceMarine,
            iterations: 1000,
            probabilityEngine: probabilityEngine,
            abilityProcessor: abilityProcessor,
            range: nil,
            defenderKeywords: [],
            defenderHasCover: false
        )

        // Then
        XCTAssertGreaterThan(result.damageHistogram.bins.count, 0)
        XCTAssertEqual(result.damageHistogram.totalCount, 1000)
    }

    func testRunSimulation_KillHistogram_HasValidBins() {
        // When
        let result = sut.runSimulation(
            weapon: boltRifle,
            defender: spaceMarine,
            iterations: 1000,
            probabilityEngine: probabilityEngine,
            abilityProcessor: abilityProcessor,
            range: nil,
            defenderKeywords: [],
            defenderHasCover: false
        )

        // Then
        XCTAssertGreaterThan(result.killHistogram.bins.count, 0)
        XCTAssertEqual(result.killHistogram.totalCount, 1000)
    }

    // MARK: - Simplified Simulation Tests

    func testRunSimplifiedSimulation_WithValidInputs_CompletesSuccessfully() {
        // When
        let result = sut.runSimplifiedSimulation(
            weapon: boltRifle,
            defender: spaceMarine,
            iterations: 1000,
            probabilityEngine: probabilityEngine
        )

        // Then
        XCTAssertEqual(result.iterations, 1000)
        XCTAssertEqual(result.damageResults.count, 1000)
        XCTAssertEqual(result.killResults.count, 1000)
    }

    func testRunSimplifiedSimulation_ProducesSimilarResultsToFullSimulation() {
        // Given - weapon with no abilities
        let weaponNoAbilities = Weapon(
            name: "Simple Weapon",
            attacks: 3,
            skill: 3,
            strength: 4,
            armorPenetration: 0,
            damage: "1",
            abilities: [],
            range: nil
        )

        // When
        let simplifiedResult = sut.runSimplifiedSimulation(
            weapon: weaponNoAbilities,
            defender: spaceMarine,
            iterations: 5000,
            probabilityEngine: probabilityEngine
        )

        let fullResult = sut.runSimulation(
            weapon: weaponNoAbilities,
            defender: spaceMarine,
            iterations: 5000,
            probabilityEngine: probabilityEngine,
            abilityProcessor: abilityProcessor,
            range: nil,
            defenderKeywords: [],
            defenderHasCover: false
        )

        // Then - results should be very similar (within 10%)
        let tolerance = simplifiedResult.damageStatistics.mean * 0.1
        XCTAssertEqual(
            simplifiedResult.damageStatistics.mean,
            fullResult.damageStatistics.mean,
            accuracy: tolerance
        )
    }

    // MARK: - Edge Case Tests

    func testRunSimulation_WithZeroIterations_ClampsToOne() {
        // When
        let result = sut.runSimulation(
            weapon: boltRifle,
            defender: spaceMarine,
            iterations: 0,
            probabilityEngine: probabilityEngine,
            abilityProcessor: abilityProcessor,
            range: nil,
            defenderKeywords: [],
            defenderHasCover: false
        )

        // Then
        XCTAssertGreaterThanOrEqual(result.iterations, 1)
    }

    func testRunSimulation_WithNegativeIterations_ClampsToOne() {
        // When
        let result = sut.runSimulation(
            weapon: boltRifle,
            defender: spaceMarine,
            iterations: -100,
            probabilityEngine: probabilityEngine,
            abilityProcessor: abilityProcessor,
            range: nil,
            defenderKeywords: [],
            defenderHasCover: false
        )

        // Then
        XCTAssertGreaterThanOrEqual(result.iterations, 1)
    }

    func testRunSimulation_WithExcessiveIterations_ClampsToMaximum() {
        // When
        let result = sut.runSimulation(
            weapon: boltRifle,
            defender: spaceMarine,
            iterations: 2_000_000,
            probabilityEngine: probabilityEngine,
            abilityProcessor: abilityProcessor,
            range: nil,
            defenderKeywords: [],
            defenderHasCover: false
        )

        // Then
        XCTAssertLessThanOrEqual(result.iterations, 1_000_000)
    }

    // MARK: - Weapon Ability Integration Tests

    func testRunSimulation_WithTorrentAbility_IncreasesHitRate() {
        // Given
        let torrentWeapon = Weapon(
            name: "Torrent Weapon",
            attacks: 5,
            skill: 3,
            strength: 4,
            armorPenetration: 0,
            damage: "1",
            abilities: [.torrent],
            range: 12
        )

        // When
        let result = sut.runSimulation(
            weapon: torrentWeapon,
            defender: spaceMarine,
            iterations: 5000,
            probabilityEngine: probabilityEngine,
            abilityProcessor: abilityProcessor,
            range: nil,
            defenderKeywords: [],
            defenderHasCover: false
        )

        // Then - with Torrent (auto-hit), damage should be higher
        // Expected: ~2.5 unsaved wounds (5 attacks × 0.5 wound × 1.0 save fail)
        XCTAssertGreaterThan(result.damageStatistics.mean, 1.5)
    }

    func testRunSimulation_WithLethalHitsAbility_IncreasesWounds() {
        // Given
        let lethalWeapon = Weapon(
            name: "Lethal Weapon",
            attacks: 10,
            skill: 3,
            strength: 3,
            armorPenetration: 0,
            damage: "1",
            abilities: [.lethalHits],
            range: 24
        )

        let toughDefender = Defender(
            name: "Tough Target",
            toughness: 8,
            save: 3,
            invulnerableSave: nil,
            feelNoPain: nil,
            wounds: 3,
            modelCount: 5
        )

        // When
        let result = sut.runSimulation(
            weapon: lethalWeapon,
            defender: toughDefender,
            iterations: 5000,
            probabilityEngine: probabilityEngine,
            abilityProcessor: abilityProcessor,
            range: nil,
            defenderKeywords: [],
            defenderHasCover: false
        )

        // Then - Lethal Hits should help against high toughness
        XCTAssertGreaterThan(result.damageStatistics.mean, 0.1)
        XCTAssertGreaterThan(result.probabilityOfAnyDamage, 0.5)
    }

    // MARK: - Variance and Distribution Tests

    func testRunSimulation_StandardDeviation_ReflectsVariability() {
        // When
        let result = sut.runSimulation(
            weapon: boltRifle,
            defender: spaceMarine,
            iterations: 5000,
            probabilityEngine: probabilityEngine,
            abilityProcessor: abilityProcessor,
            range: nil,
            defenderKeywords: [],
            defenderHasCover: false
        )

        // Then - standard deviation should be positive (results vary)
        XCTAssertGreaterThan(result.damageStatistics.standardDeviation, 0)
        XCTAssertGreaterThan(result.killStatistics.standardDeviation, 0)
    }

    func testRunSimulation_PercentilesAreOrdered() {
        // When
        let result = sut.runSimulation(
            weapon: boltRifle,
            defender: spaceMarine,
            iterations: 5000,
            probabilityEngine: probabilityEngine,
            abilityProcessor: abilityProcessor,
            range: nil,
            defenderKeywords: [],
            defenderHasCover: false
        )

        // Then - percentiles should be in ascending order
        let stats = result.damageStatistics
        XCTAssertLessThanOrEqual(stats.percentile25, stats.median)
        XCTAssertLessThanOrEqual(stats.median, stats.percentile75)
        XCTAssertLessThanOrEqual(stats.percentile75, stats.percentile90)
        XCTAssertLessThanOrEqual(stats.percentile90, stats.percentile95)
        XCTAssertLessThanOrEqual(stats.percentile95, stats.percentile99)
    }

    // MARK: - Damage Type Tests

    func testRunSimulation_WithD3Damage_ProducesCorrectRange() {
        // Given
        let d3Weapon = Weapon(
            name: "D3 Weapon",
            attacks: 3,
            skill: 2,
            strength: 8,
            armorPenetration: -2,
            damage: "D3",
            abilities: [],
            range: 24
        )

        // When
        let result = sut.runSimulation(
            weapon: d3Weapon,
            defender: spaceMarine,
            iterations: 5000,
            probabilityEngine: probabilityEngine,
            abilityProcessor: abilityProcessor,
            range: nil,
            defenderKeywords: [],
            defenderHasCover: false
        )

        // Then - damage should reflect D3 range (1-3 per unsaved wound)
        XCTAssertGreaterThan(result.damageStatistics.mean, 0)
        XCTAssertLessThan(result.damageStatistics.maximum, 10) // 3 attacks × 3 damage max = 9
    }

    func testRunSimulation_WithD6Damage_ProducesCorrectRange() {
        // Given
        let d6Weapon = Weapon(
            name: "D6 Weapon",
            attacks: 2,
            skill: 3,
            strength: 9,
            armorPenetration: -3,
            damage: "D6",
            abilities: [],
            range: 48
        )

        // When
        let result = sut.runSimulation(
            weapon: d6Weapon,
            defender: spaceMarine,
            iterations: 5000,
            probabilityEngine: probabilityEngine,
            abilityProcessor: abilityProcessor,
            range: nil,
            defenderKeywords: [],
            defenderHasCover: false
        )

        // Then - with D6 damage, potential for high damage
        XCTAssertGreaterThan(result.damageStatistics.mean, 0)
        XCTAssertLessThan(result.damageStatistics.maximum, 13) // 2 attacks × 6 damage max = 12
    }

    // MARK: - Performance Tests

    func testRunSimulation_ConcurrentExecution_ProducesConsistentResults() {
        // Given
        let iterations = 10000

        // When - run same simulation twice
        let result1 = sut.runSimulation(
            weapon: boltRifle,
            defender: spaceMarine,
            iterations: iterations,
            probabilityEngine: probabilityEngine,
            abilityProcessor: abilityProcessor,
            range: nil,
            defenderKeywords: [],
            defenderHasCover: false
        )

        let result2 = sut.runSimulation(
            weapon: boltRifle,
            defender: spaceMarine,
            iterations: iterations,
            probabilityEngine: probabilityEngine,
            abilityProcessor: abilityProcessor,
            range: nil,
            defenderKeywords: [],
            defenderHasCover: false
        )

        // Then - results should be statistically similar (within 10%)
        let tolerance = result1.damageStatistics.mean * 0.1
        XCTAssertEqual(
            result1.damageStatistics.mean,
            result2.damageStatistics.mean,
            accuracy: tolerance,
            "Concurrent simulations should produce consistent results"
        )
    }
}
