//
//  ProbabilityEngine.swift
//  MobileDiceRoller
//
//  Created on 2025-11-08.
//

import Foundation

/// Concrete implementation of probability calculations for Warhammer 40K
///
/// This service implements the `ProbabilityCalculating` protocol and handles
/// all mathematical probability calculations for combat in Warhammer 40K 10th Edition.
///
/// ## Single Responsibility Principle
/// This class has ONE responsibility: calculate combat probabilities.
/// It does not:
/// - Manage state
/// - Persist data
/// - Handle UI
/// - Process weapon abilities (that's AbilityProcessor's job)
///
/// ## Usage
/// ```swift
/// let engine = ProbabilityEngine()
/// let weapon = Weapon.boltRifle()
/// let defender = Defender.spaceMarine()
/// let result = engine.calculateCombatResult(weapon: weapon, defender: defender)
/// ```
public final class ProbabilityEngine: ProbabilityCalculating {

    // MARK: - Properties

    /// Lookup table for Strength vs Toughness wound rolls (optimization)
    ///
    /// This pre-computed table avoids repeated conditional logic for the most
    /// common S vs T combinations. Format: [strength][toughness] = wound roll needed
    private let strengthVsToughnessTable: [[Int]]

    // MARK: - Initialization

    public init() {
        self.strengthVsToughnessTable = Self.buildStrengthVsToughnessTable()
    }

    // MARK: - ProbabilityCalculating

    public func calculateHitProbability(skill: Int) -> Double {
        // Validate skill range (2-6 in 40K 10th edition)
        guard skill >= 2 && skill <= 6 else {
            return 0.0
        }

        // Probability = (7 - skill) / 6
        // BS 2+ = 5/6, BS 3+ = 4/6, BS 4+ = 3/6, BS 5+ = 2/6, BS 6+ = 1/6
        return Double(7 - skill) / 6.0
    }

    public func calculateWoundProbability(strength: Int, toughness: Int) -> Double {
        let woundRoll = woundRollNeeded(strength: strength, toughness: toughness)
        return d6Probability(target: woundRoll)
    }

    public func calculateSaveFailProbability(
        save: Int,
        armorPenetration: Int,
        invulnerable: Int?
    ) -> Double {
        // Calculate modified armor save
        let modifiedSave = save - armorPenetration

        // Use the better of modified armor save or invulnerable save
        let bestSave = min(modifiedSave, invulnerable ?? 7)

        // If save is impossible (7+), automatically fail
        guard bestSave <= 6 else {
            return 1.0  // Always fails
        }

        // If save is 1+ or better, automatically pass
        guard bestSave >= 2 else {
            return 0.0  // Never fails
        }

        // Probability of failing = (bestSave - 1) / 6
        // 2+ save fails on 1 (1/6)
        // 3+ save fails on 1-2 (2/6)
        // 4+ save fails on 1-3 (3/6)
        // etc.
        return Double(bestSave - 1) / 6.0
    }

    public func calculateFeelNoPainProbability(feelNoPain: Int?) -> Double {
        guard let fnp = feelNoPain else {
            return 0.0  // No FNP
        }

        // FNP works like a save - passing prevents the damage
        return d6Probability(target: fnp)
    }

    public func calculateCombatResult(weapon: Weapon, defender: Defender) -> CombatResult {
        // Calculate probabilities for each phase
        let hitProb = calculateHitProbability(skill: weapon.skill)
        let woundProb = calculateWoundProbability(strength: weapon.strength, toughness: defender.toughness)
        let saveFailProb = calculateSaveFailProbability(
            save: defender.save,
            armorPenetration: weapon.armorPenetration,
            invulnerable: defender.invulnerableSave
        )
        let fnpPassProb = calculateFeelNoPainProbability(feelNoPain: defender.feelNoPain)
        let fnpFailProb = 1.0 - fnpPassProb

        // Calculate expected values through the combat sequence
        let expectedHits = Double(weapon.attacks) * hitProb
        let expectedWounds = expectedHits * woundProb
        let expectedUnsavedWounds = expectedWounds * saveFailProb

        // Average damage per unsaved wound
        let avgDamage = averageDamage(from: weapon.damage)

        // Apply Feel No Pain to reduce final damage
        let expectedDamage = expectedUnsavedWounds * avgDamage * fnpFailProb

        // Calculate models killed
        let expectedModelsKilled = defender.wounds > 0
            ? expectedDamage / Double(defender.wounds)
            : 0.0

        // Calculate kill probability (at least 1 model killed)
        let killProb = calculateKillProbability(
            expectedModelsKilled: expectedModelsKilled
        )

        return CombatResult(
            expectedHits: expectedHits,
            expectedWounds: expectedWounds,
            expectedUnsavedWounds: expectedUnsavedWounds,
            expectedDamage: expectedDamage,
            expectedModelsKilled: expectedModelsKilled,
            hitProbability: hitProb,
            woundProbability: woundProb,
            saveFailProbability: saveFailProb,
            killProbability: killProb
        )
    }

    // MARK: - Private Helper Methods

    /// Parses damage characteristic and returns average damage
    ///
    /// Supports formats like: "1", "2", "D3", "D6", "D6+2", "2D6", etc.
    ///
    /// - Parameter damageString: The damage characteristic from the weapon profile
    /// - Returns: Average damage value
    private func averageDamage(from damageString: String) -> Double {
        let damage = damageString.trimmingCharacters(in: .whitespaces).uppercased()

        // Fixed damage (e.g., "1", "2", "3")
        if let fixedDamage = Int(damage) {
            return Double(fixedDamage)
        }

        // D3 damage (average 2)
        if damage == "D3" {
            return 2.0
        }

        // D6 damage (average 3.5)
        if damage == "D6" {
            return 3.5
        }

        // D6+X format (e.g., "D6+1", "D6+2")
        if damage.hasPrefix("D6+") {
            let bonusString = damage.dropFirst(3)
            if let bonus = Int(bonusString) {
                return 3.5 + Double(bonus)
            }
        }

        // D3+X format
        if damage.hasPrefix("D3+") {
            let bonusString = damage.dropFirst(3)
            if let bonus = Int(bonusString) {
                return 2.0 + Double(bonus)
            }
        }

        // 2D6 format (average 7)
        if damage == "2D6" {
            return 7.0
        }

        // 3D6 format (average 10.5)
        if damage == "3D6" {
            return 10.5
        }

        // Default to 1 if unparseable
        return 1.0
    }

    /// Calculates the probability of killing at least one model
    ///
    /// This is a simplified calculation. For more accuracy, use Monte Carlo simulation.
    ///
    /// - Parameter expectedModelsKilled: Expected number of models killed
    /// - Returns: Probability of killing at least one model (0.0 to 1.0)
    private func calculateKillProbability(expectedModelsKilled: Double) -> Double {
        // Simplified: if expected kills >= 1, probability is high
        // For exact probability, would need binomial distribution or simulation
        if expectedModelsKilled >= 1.0 {
            return 1.0
        } else if expectedModelsKilled <= 0.0 {
            return 0.0
        } else {
            // Linear approximation for 0 < expected < 1
            return expectedModelsKilled
        }
    }

    /// Builds a lookup table for Strength vs Toughness wound rolls
    ///
    /// This optimization pre-computes the wound roll needed for common
    /// S vs T combinations to avoid repeated conditional logic.
    ///
    /// - Returns: 2D array where [strength][toughness] = wound roll needed
    private static func buildStrengthVsToughnessTable() -> [[Int]] {
        let maxStat = 20  // Support S/T up to 20
        var table = Array(repeating: Array(repeating: 0, count: maxStat + 1), count: maxStat + 1)

        for s in 1...maxStat {
            for t in 1...maxStat {
                let woundRoll: Int
                if s >= t * 2 {
                    woundRoll = 2  // S ≥ T×2
                } else if s > t {
                    woundRoll = 3  // S > T
                } else if s == t {
                    woundRoll = 4  // S = T
                } else if s * 2 > t {
                    woundRoll = 5  // S < T but S×2 > T
                } else {
                    woundRoll = 6  // S×2 ≤ T
                }
                table[s][t] = woundRoll
            }
        }

        return table
    }
}

// MARK: - Private Extensions

private extension ProbabilityEngine {
    /// Optimized wound roll lookup using pre-computed table
    ///
    /// Falls back to calculated method if outside table bounds.
    func woundRollNeededOptimized(strength: Int, toughness: Int) -> Int {
        // Use lookup table if within bounds
        if strength > 0 && strength < strengthVsToughnessTable.count &&
           toughness > 0 && toughness < strengthVsToughnessTable[0].count {
            return strengthVsToughnessTable[strength][toughness]
        }

        // Fall back to calculated method
        return woundRollNeeded(strength: strength, toughness: toughness)
    }
}
