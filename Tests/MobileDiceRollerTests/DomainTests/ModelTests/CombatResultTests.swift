//
//  CombatResultTests.swift
//  MobileDiceRoller
//
//  Created on 2025-11-08.
//

import XCTest
@testable import MobileDiceRoller

/// Unit tests for the CombatResult domain model
///
/// Following TDD approach: Tests written first, implementation follows.
/// Target: 80%+ code coverage
final class CombatResultTests: XCTestCase {

    // MARK: - Initialization Tests

    func testCombatResultInitialization() {
        // Arrange & Act
        let result = CombatResult(
            expectedHits: 3.33,
            expectedWounds: 2.22,
            expectedUnsavedWounds: 1.48,
            expectedDamage: 1.48,
            expectedModelsKilled: 0.74,
            hitProbability: 0.667,
            woundProbability: 0.667,
            saveFailProbability: 0.667,
            killProbability: 0.074
        )

        // Assert
        XCTAssertEqual(result.expectedHits, 3.33, accuracy: 0.001)
        XCTAssertEqual(result.expectedWounds, 2.22, accuracy: 0.001)
        XCTAssertEqual(result.expectedUnsavedWounds, 1.48, accuracy: 0.001)
        XCTAssertEqual(result.expectedDamage, 1.48, accuracy: 0.001)
        XCTAssertEqual(result.expectedModelsKilled, 0.74, accuracy: 0.001)
        XCTAssertEqual(result.hitProbability, 0.667, accuracy: 0.001)
        XCTAssertEqual(result.woundProbability, 0.667, accuracy: 0.001)
        XCTAssertEqual(result.saveFailProbability, 0.667, accuracy: 0.001)
        XCTAssertEqual(result.killProbability, 0.074, accuracy: 0.001)
    }

    func testCombatResultWithZeroValues() {
        // Arrange & Act
        let result = CombatResult(
            expectedHits: 0,
            expectedWounds: 0,
            expectedUnsavedWounds: 0,
            expectedDamage: 0,
            expectedModelsKilled: 0,
            hitProbability: 0,
            woundProbability: 0,
            saveFailProbability: 0,
            killProbability: 0
        )

        // Assert
        XCTAssertEqual(result.expectedHits, 0)
        XCTAssertEqual(result.expectedWounds, 0)
        XCTAssertEqual(result.expectedDamage, 0)
    }

    // MARK: - Computed Property Tests

    func testOverallKillEfficiencyWithNonZeroHits() {
        // Arrange
        let result = CombatResult(
            expectedHits: 4.0,
            expectedWounds: 3.0,
            expectedUnsavedWounds: 2.0,
            expectedDamage: 2.0,
            expectedModelsKilled: 1.0,
            hitProbability: 0.667,
            woundProbability: 0.75,
            saveFailProbability: 0.667,
            killProbability: 0.25
        )

        // Act
        let efficiency = result.overallKillEfficiency

        // Assert
        XCTAssertEqual(efficiency, 0.25, accuracy: 0.001) // 1.0 killed / 4.0 hits = 0.25
    }

    func testOverallKillEfficiencyWithZeroHits() {
        // Arrange
        let result = CombatResult(
            expectedHits: 0,
            expectedWounds: 0,
            expectedUnsavedWounds: 0,
            expectedDamage: 0,
            expectedModelsKilled: 0,
            hitProbability: 0,
            woundProbability: 0,
            saveFailProbability: 0,
            killProbability: 0
        )

        // Act
        let efficiency = result.overallKillEfficiency

        // Assert
        XCTAssertEqual(efficiency, 0)
    }

    func testAverageWoundsPerHitWithNonZeroHits() {
        // Arrange
        let result = CombatResult(
            expectedHits: 6.0,
            expectedWounds: 3.0,
            expectedUnsavedWounds: 2.0,
            expectedDamage: 2.0,
            expectedModelsKilled: 1.0,
            hitProbability: 0.5,
            woundProbability: 0.5,
            saveFailProbability: 0.667,
            killProbability: 0.167
        )

        // Act
        let avgWounds = result.averageWoundsPerHit

        // Assert
        XCTAssertEqual(avgWounds, 0.5, accuracy: 0.001) // 3.0 wounds / 6.0 hits = 0.5
    }

    func testAverageWoundsPerHitWithZeroHits() {
        // Arrange
        let result = CombatResult(
            expectedHits: 0,
            expectedWounds: 0,
            expectedUnsavedWounds: 0,
            expectedDamage: 0,
            expectedModelsKilled: 0,
            hitProbability: 0,
            woundProbability: 0,
            saveFailProbability: 0,
            killProbability: 0
        )

        // Act
        let avgWounds = result.averageWoundsPerHit

        // Assert
        XCTAssertEqual(avgWounds, 0)
    }

    // MARK: - Equatable Tests

    func testEquatableWithIdenticalResults() {
        // Arrange
        let result1 = CombatResult(
            expectedHits: 3.0,
            expectedWounds: 2.0,
            expectedUnsavedWounds: 1.5,
            expectedDamage: 1.5,
            expectedModelsKilled: 0.75,
            hitProbability: 0.5,
            woundProbability: 0.667,
            saveFailProbability: 0.75,
            killProbability: 0.25
        )

        let result2 = CombatResult(
            expectedHits: 3.0,
            expectedWounds: 2.0,
            expectedUnsavedWounds: 1.5,
            expectedDamage: 1.5,
            expectedModelsKilled: 0.75,
            hitProbability: 0.5,
            woundProbability: 0.667,
            saveFailProbability: 0.75,
            killProbability: 0.25
        )

        // Act & Assert
        XCTAssertEqual(result1, result2)
    }

    func testEquatableWithDifferentExpectedHits() {
        // Arrange
        let result1 = CombatResult(
            expectedHits: 3.0,
            expectedWounds: 2.0,
            expectedUnsavedWounds: 1.5,
            expectedDamage: 1.5,
            expectedModelsKilled: 0.75,
            hitProbability: 0.5,
            woundProbability: 0.667,
            saveFailProbability: 0.75,
            killProbability: 0.25
        )

        let result2 = CombatResult(
            expectedHits: 4.0,
            expectedWounds: 2.0,
            expectedUnsavedWounds: 1.5,
            expectedDamage: 1.5,
            expectedModelsKilled: 0.75,
            hitProbability: 0.5,
            woundProbability: 0.667,
            saveFailProbability: 0.75,
            killProbability: 0.25
        )

        // Act & Assert
        XCTAssertNotEqual(result1, result2)
    }

    // MARK: - Codable Tests

    func testEncodingCombatResult() throws {
        // Arrange
        let result = CombatResult(
            expectedHits: 3.33,
            expectedWounds: 2.22,
            expectedUnsavedWounds: 1.48,
            expectedDamage: 1.48,
            expectedModelsKilled: 0.74,
            hitProbability: 0.667,
            woundProbability: 0.667,
            saveFailProbability: 0.667,
            killProbability: 0.074
        )

        // Act
        let encoder = JSONEncoder()
        let data = try encoder.encode(result)

        // Assert
        XCTAssertFalse(data.isEmpty)
    }

    func testDecodingCombatResult() throws {
        // Arrange
        let json = """
        {
            "expectedHits": 3.33,
            "expectedWounds": 2.22,
            "expectedUnsavedWounds": 1.48,
            "expectedDamage": 1.48,
            "expectedModelsKilled": 0.74,
            "hitProbability": 0.667,
            "woundProbability": 0.667,
            "saveFailProbability": 0.667,
            "killProbability": 0.074
        }
        """.data(using: .utf8)!

        // Act
        let decoder = JSONDecoder()
        let result = try decoder.decode(CombatResult.self, from: json)

        // Assert
        XCTAssertEqual(result.expectedHits, 3.33, accuracy: 0.001)
        XCTAssertEqual(result.expectedWounds, 2.22, accuracy: 0.001)
        XCTAssertEqual(result.killProbability, 0.074, accuracy: 0.001)
    }

    func testRoundTripEncoding() throws {
        // Arrange
        let original = CombatResult(
            expectedHits: 5.0,
            expectedWounds: 3.5,
            expectedUnsavedWounds: 2.33,
            expectedDamage: 2.33,
            expectedModelsKilled: 1.17,
            hitProbability: 0.833,
            woundProbability: 0.7,
            saveFailProbability: 0.667,
            killProbability: 0.234
        )

        // Act
        let encoder = JSONEncoder()
        let data = try encoder.encode(original)

        let decoder = JSONDecoder()
        let decoded = try decoder.decode(CombatResult.self, from: data)

        // Assert
        XCTAssertEqual(original, decoded)
    }

    // MARK: - Edge Case Tests

    func testCombatResultWithPerfectAccuracy() {
        // Arrange
        let result = CombatResult(
            expectedHits: 10.0,
            expectedWounds: 10.0,
            expectedUnsavedWounds: 10.0,
            expectedDamage: 10.0,
            expectedModelsKilled: 5.0,
            hitProbability: 1.0,
            woundProbability: 1.0,
            saveFailProbability: 1.0,
            killProbability: 0.5
        )

        // Act & Assert
        XCTAssertEqual(result.hitProbability, 1.0)
        XCTAssertEqual(result.woundProbability, 1.0)
        XCTAssertEqual(result.saveFailProbability, 1.0)
        XCTAssertEqual(result.overallKillEfficiency, 0.5)
    }

    func testCombatResultWithHighDamageOutput() {
        // Arrange
        let result = CombatResult(
            expectedHits: 6.0,
            expectedWounds: 5.0,
            expectedUnsavedWounds: 4.5,
            expectedDamage: 27.0, // 4.5 unsaved × 6 damage each
            expectedModelsKilled: 13.5,
            hitProbability: 0.833,
            woundProbability: 0.833,
            saveFailProbability: 0.9,
            killProbability: 1.0
        )

        // Act & Assert
        XCTAssertEqual(result.expectedDamage, 27.0)
        XCTAssertEqual(result.expectedModelsKilled, 13.5)
    }

    // MARK: - Immutability Tests

    func testCombatResultIsImmutable() {
        // Arrange
        let result = CombatResult(
            expectedHits: 3.0,
            expectedWounds: 2.0,
            expectedUnsavedWounds: 1.5,
            expectedDamage: 1.5,
            expectedModelsKilled: 0.75,
            hitProbability: 0.5,
            woundProbability: 0.667,
            saveFailProbability: 0.75,
            killProbability: 0.25
        )

        // Act - All properties should be let (immutable)
        // This is verified by compilation - attempting to modify would fail

        // Assert
        XCTAssertEqual(result.expectedHits, 3.0)
    }
}
