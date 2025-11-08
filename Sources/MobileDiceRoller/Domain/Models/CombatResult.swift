//
//  CombatResult.swift
//  MobileDiceRoller
//
//  Created on 2025-11-08.
//

import Foundation

/// Represents the results of a combat probability calculation
///
/// This struct contains all expected values and probabilities from a
/// Warhammer 40K combat interaction, including hits, wounds, saves, and damage.
///
/// ## Immutability
/// All properties are immutable (`let`) to ensure the result cannot be
/// modified after creation. This follows functional programming principles
/// and prevents bugs from accidental mutation.
///
/// ## Usage
/// ```swift
/// let result = CombatResult(
///     expectedHits: 3.33,
///     expectedWounds: 2.22,
///     expectedUnsavedWounds: 1.48,
///     expectedDamage: 1.48,
///     expectedModelsKilled: 0.74,
///     hitProbability: 0.667,
///     woundProbability: 0.667,
///     saveFailProbability: 0.667,
///     killProbability: 0.074
/// )
/// ```
public struct CombatResult: Equatable, Codable, Hashable {
    // MARK: - Expected Values

    /// Expected number of successful hits
    ///
    /// Calculated as: attacks × hit probability
    public let expectedHits: Double

    /// Expected number of successful wounds
    ///
    /// Calculated as: expected hits × wound probability
    public let expectedWounds: Double

    /// Expected number of unsaved wounds
    ///
    /// Calculated as: expected wounds × save fail probability
    public let expectedUnsavedWounds: Double

    /// Expected total damage dealt
    ///
    /// Calculated as: expected unsaved wounds × average damage per wound
    public let expectedDamage: Double

    /// Expected number of models removed as casualties
    ///
    /// Calculated as: expected damage / wounds per model
    public let expectedModelsKilled: Double

    // MARK: - Probabilities

    /// Probability of a single attack hitting (0.0 to 1.0)
    ///
    /// For BS/WS 3+, this would be 0.667 (4/6)
    public let hitProbability: Double

    /// Probability of a single hit wounding (0.0 to 1.0)
    ///
    /// Depends on Strength vs Toughness comparison
    public let woundProbability: Double

    /// Probability of failing a save (0.0 to 1.0)
    ///
    /// Calculated from armor save, AP, and invulnerable save
    public let saveFailProbability: Double

    /// Probability of killing at least one model (0.0 to 1.0)
    ///
    /// The chance that this attack sequence kills at least 1 model
    public let killProbability: Double

    // MARK: - Computed Properties

    /// Overall efficiency: models killed per attack
    ///
    /// Returns 0 if there are no expected hits to avoid division by zero.
    public var overallKillEfficiency: Double {
        guard expectedHits > 0 else { return 0 }
        return expectedModelsKilled / expectedHits
    }

    /// Average wounds inflicted per successful hit
    ///
    /// Returns 0 if there are no expected hits to avoid division by zero.
    public var averageWoundsPerHit: Double {
        guard expectedHits > 0 else { return 0 }
        return expectedWounds / expectedHits
    }

    /// Overall probability chain: hit → wound → fail save
    ///
    /// This is the probability that a single attack goes through all phases
    /// and deals damage to the target.
    public var overallSuccessProbability: Double {
        hitProbability * woundProbability * saveFailProbability
    }

    // MARK: - Initialization

    /// Creates a new combat result with all expected values and probabilities
    ///
    /// - Parameters:
    ///   - expectedHits: Expected number of hits
    ///   - expectedWounds: Expected number of wounds
    ///   - expectedUnsavedWounds: Expected unsaved wounds
    ///   - expectedDamage: Expected total damage
    ///   - expectedModelsKilled: Expected models removed
    ///   - hitProbability: Probability of hitting (0.0-1.0)
    ///   - woundProbability: Probability of wounding (0.0-1.0)
    ///   - saveFailProbability: Probability of failing save (0.0-1.0)
    ///   - killProbability: Probability of killing at least one model (0.0-1.0)
    public init(
        expectedHits: Double,
        expectedWounds: Double,
        expectedUnsavedWounds: Double,
        expectedDamage: Double,
        expectedModelsKilled: Double,
        hitProbability: Double,
        woundProbability: Double,
        saveFailProbability: Double,
        killProbability: Double
    ) {
        self.expectedHits = expectedHits
        self.expectedWounds = expectedWounds
        self.expectedUnsavedWounds = expectedUnsavedWounds
        self.expectedDamage = expectedDamage
        self.expectedModelsKilled = expectedModelsKilled
        self.hitProbability = hitProbability
        self.woundProbability = woundProbability
        self.saveFailProbability = saveFailProbability
        self.killProbability = killProbability
    }
}

// MARK: - Factory Methods

extension CombatResult {
    /// Creates a combat result representing no damage
    ///
    /// Useful for scenarios where attacks automatically fail or
    /// when initializing before calculations.
    ///
    /// - Returns: A combat result with all zeros
    public static func noDamage() -> CombatResult {
        CombatResult(
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
    }

    /// Creates a combat result for auto-hit weapons with perfect accuracy
    ///
    /// - Parameters:
    ///   - attacks: Number of attacks
    ///   - woundProb: Probability of wounding
    ///   - saveFailProb: Probability of failing save
    ///   - damage: Average damage per unsaved wound
    ///   - woundsPerModel: Wounds per model for kill calculation
    /// - Returns: Combat result with 100% hit probability
    public static func autoHit(
        attacks: Int,
        woundProb: Double,
        saveFailProb: Double,
        damage: Double,
        woundsPerModel: Int
    ) -> CombatResult {
        let hits = Double(attacks)
        let wounds = hits * woundProb
        let unsaved = wounds * saveFailProb
        let totalDamage = unsaved * damage
        let modelsKilled = totalDamage / Double(woundsPerModel)

        return CombatResult(
            expectedHits: hits,
            expectedWounds: wounds,
            expectedUnsavedWounds: unsaved,
            expectedDamage: totalDamage,
            expectedModelsKilled: modelsKilled,
            hitProbability: 1.0,
            woundProbability: woundProb,
            saveFailProbability: saveFailProb,
            killProbability: modelsKilled >= 1.0 ? 1.0 : modelsKilled
        )
    }
}

// MARK: - CustomStringConvertible

extension CombatResult: CustomStringConvertible {
    public var description: String {
        """
        Combat Result:
          Expected Hits: \(String(format: "%.2f", expectedHits))
          Expected Wounds: \(String(format: "%.2f", expectedWounds))
          Expected Unsaved Wounds: \(String(format: "%.2f", expectedUnsavedWounds))
          Expected Damage: \(String(format: "%.2f", expectedDamage))
          Expected Models Killed: \(String(format: "%.2f", expectedModelsKilled))

          Hit Probability: \(String(format: "%.1f%%", hitProbability * 100))
          Wound Probability: \(String(format: "%.1f%%", woundProbability * 100))
          Save Fail Probability: \(String(format: "%.1f%%", saveFailProbability * 100))
          Kill Probability: \(String(format: "%.1f%%", killProbability * 100))

          Overall Success Rate: \(String(format: "%.1f%%", overallSuccessProbability * 100))
          Kill Efficiency: \(String(format: "%.3f", overallKillEfficiency)) models/attack
        """
    }
}
