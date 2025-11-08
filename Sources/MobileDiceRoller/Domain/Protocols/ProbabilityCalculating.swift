//
//  ProbabilityCalculating.swift
//  MobileDiceRoller
//
//  Created on 2025-11-08.
//

import Foundation

/// Protocol for calculating combat probabilities in Warhammer 40K
///
/// This protocol defines the interface for probability calculations following
/// the Interface Segregation Principle (ISP). Implementations handle the
/// mathematical calculations for hit rolls, wound rolls, save rolls, and
/// damage allocation based on Warhammer 40K 10th Edition rules.
///
/// ## Warhammer 40K Combat Sequence
/// 1. **Hit Roll**: Ballistic Skill or Weapon Skill determines hit probability
/// 2. **Wound Roll**: Strength vs Toughness comparison determines wound probability
/// 3. **Save Roll**: Armor save (modified by AP) or invulnerable save
/// 4. **Feel No Pain**: Optional damage mitigation roll
/// 5. **Damage Allocation**: Calculate damage and models removed
///
/// ## Usage
/// ```swift
/// let engine: ProbabilityCalculating = ProbabilityEngine()
/// let hitProb = engine.calculateHitProbability(skill: 3) // BS/WS 3+ = 66.7%
/// let woundProb = engine.calculateWoundProbability(strength: 4, toughness: 4) // 50%
/// ```
public protocol ProbabilityCalculating {
    // MARK: - Hit Roll Calculations

    /// Calculates the probability of hitting with a given skill value
    ///
    /// In Warhammer 40K, hits are successful on rolls of the skill value or higher
    /// on a D6. For example, BS 3+ means rolls of 3, 4, 5, or 6 succeed (4/6 = 66.7%).
    ///
    /// - Parameter skill: The Ballistic Skill or Weapon Skill (2-6)
    /// - Returns: Probability of success (0.0 to 1.0), or 0.0 if skill is invalid
    ///
    /// ## Examples
    /// ```swift
    /// calculateHitProbability(skill: 2) // Returns 0.833 (5/6)
    /// calculateHitProbability(skill: 3) // Returns 0.667 (4/6)
    /// calculateHitProbability(skill: 4) // Returns 0.5 (3/6)
    /// calculateHitProbability(skill: 6) // Returns 0.167 (1/6)
    /// ```
    func calculateHitProbability(skill: Int) -> Double

    // MARK: - Wound Roll Calculations

    /// Calculates the probability of wounding based on Strength vs Toughness
    ///
    /// The wound roll needed is determined by comparing the attacker's Strength
    /// to the defender's Toughness:
    /// - S ≥ T×2: Wound on 2+
    /// - S > T: Wound on 3+
    /// - S = T: Wound on 4+
    /// - S < T (but S×2 > T): Wound on 5+
    /// - S×2 ≤ T: Wound on 6+
    ///
    /// - Parameters:
    ///   - strength: Attacker's Strength characteristic
    ///   - toughness: Defender's Toughness characteristic
    /// - Returns: Probability of wounding (0.0 to 1.0)
    ///
    /// ## Examples
    /// ```swift
    /// // Space Marine (S4) vs Space Marine (T4)
    /// calculateWoundProbability(strength: 4, toughness: 4) // 0.5 (4+ to wound)
    ///
    /// // Lascannon (S12) vs Space Marine (T4)
    /// calculateWoundProbability(strength: 12, toughness: 4) // 0.833 (2+ to wound)
    /// ```
    func calculateWoundProbability(strength: Int, toughness: Int) -> Double

    // MARK: - Save Roll Calculations

    /// Calculates the probability of failing a save roll
    ///
    /// The defender uses the better of their armor save (modified by AP) or
    /// their invulnerable save (unaffected by AP). A roll equal to or higher
    /// than the save value succeeds.
    ///
    /// - Parameters:
    ///   - save: Defender's armor Save characteristic (2-6)
    ///   - armorPenetration: Attacker's AP value (0 to -6, where negative worsens the save)
    ///   - invulnerableSave: Optional invulnerable save (2-6), unaffected by AP
    /// - Returns: Probability of failing the save (0.0 to 1.0)
    ///
    /// ## Examples
    /// ```swift
    /// // 3+ armor save vs AP-1 weapon
    /// calculateSaveFailProbability(save: 3, armorPenetration: -1, invulnerable: nil)
    /// // Returns 0.5 (modified to 4+, fails on 1-3)
    ///
    /// // 3+ armor save with 4+ invuln vs AP-3 weapon
    /// calculateSaveFailProbability(save: 3, armorPenetration: -3, invulnerable: 4)
    /// // Returns 0.5 (uses 4+ invuln, fails on 1-3)
    /// ```
    func calculateSaveFailProbability(
        save: Int,
        armorPenetration: Int,
        invulnerable: Int?
    ) -> Double

    /// Calculates the probability of passing a Feel No Pain roll
    ///
    /// Feel No Pain allows ignoring damage on a specific roll. This is rolled
    /// after failed saves. The probability returned is for PASSING the roll
    /// (i.e., ignoring the damage).
    ///
    /// - Parameter feelNoPain: The FNP value (2-6), or nil if no FNP
    /// - Returns: Probability of passing FNP (0.0 to 1.0), or 0.0 if no FNP
    ///
    /// ## Examples
    /// ```swift
    /// calculateFeelNoPainProbability(feelNoPain: 5) // Returns 0.333 (2/6)
    /// calculateFeelNoPainProbability(feelNoPain: 6) // Returns 0.167 (1/6)
    /// calculateFeelNoPainProbability(feelNoPain: nil) // Returns 0.0
    /// ```
    func calculateFeelNoPainProbability(feelNoPain: Int?) -> Double

    // MARK: - Full Combat Calculation

    /// Calculates the complete combat result for a weapon attacking a defender
    ///
    /// This method chains all probability calculations together to produce
    /// a comprehensive result including expected hits, wounds, damage, and
    /// models killed.
    ///
    /// - Parameters:
    ///   - weapon: The attacking weapon
    ///   - defender: The defending unit
    /// - Returns: Complete combat result with all probabilities and expected values
    ///
    /// ## Example
    /// ```swift
    /// let weapon = Weapon.boltRifle()
    /// let defender = Defender.spaceMarine()
    /// let result = engine.calculateCombatResult(weapon: weapon, defender: defender)
    /// print("Expected damage: \(result.expectedDamage)")
    /// ```
    func calculateCombatResult(weapon: Weapon, defender: Defender) -> CombatResult
}

// MARK: - Default Implementations

public extension ProbabilityCalculating {
    /// Calculates the probability of a D6 roll meeting or exceeding a target
    ///
    /// This is a helper method for the standard D6 probability calculation
    /// used throughout Warhammer 40K.
    ///
    /// - Parameter target: The target value (2-6)
    /// - Returns: Probability of success (0.0 to 1.0)
    func d6Probability(target: Int) -> Double {
        guard target >= 2 && target <= 6 else {
            if target < 2 {
                return 1.0 // Always succeeds
            } else {
                return 0.0 // Impossible
            }
        }

        return Double(7 - target) / 6.0
    }

    /// Determines the wound roll needed for a given Strength vs Toughness matchup
    ///
    /// - Parameters:
    ///   - strength: Attacker's Strength
    ///   - toughness: Defender's Toughness
    /// - Returns: The D6 value needed to wound (2-6)
    func woundRollNeeded(strength: Int, toughness: Int) -> Int {
        switch true {
        case strength >= toughness * 2:
            return 2 // S ≥ T×2: Wound on 2+
        case strength > toughness:
            return 3 // S > T: Wound on 3+
        case strength == toughness:
            return 4 // S = T: Wound on 4+
        case strength * 2 > toughness:
            return 5 // S < T but S×2 > T: Wound on 5+
        default:
            return 6 // S×2 ≤ T: Wound on 6+
        }
    }
}
