//
//  AbilityProcessing.swift
//  MobileDiceRoller
//
//  Created on 2025-11-08.
//

import Foundation

/// Protocol for processing weapon abilities in Warhammer 40K combat
///
/// This protocol defines the interface for applying weapon abilities to combat
/// calculations. Implementations use the Strategy pattern to modify combat results
/// based on active weapon abilities.
///
/// ## Weapon Abilities Supported
/// - **Critical Hit Modifiers**: Lethal Hits, Sustained Hits
/// - **Critical Wound Modifiers**: Devastating Wounds, Anti-X
/// - **Auto-Hit**: Torrent
/// - **Re-rolls**: Twin-Linked
/// - **Range-Based**: Melta, Rapid Fire
/// - **Unit-Size Based**: Blast
/// - **Defensive**: Ignores Cover, Precision
/// - **Risk**: Hazardous
///
/// ## Usage
/// ```swift
/// let processor: AbilityProcessing = AbilityProcessor()
/// let enhanced = processor.applyAbilities(
///     baseResult: baseResult,
///     weapon: weapon,
///     defender: defender
/// )
/// ```
public protocol AbilityProcessing {
    // MARK: - Core Methods

    /// Applies all weapon abilities to a base combat result
    ///
    /// Takes a baseline combat result (calculated without abilities) and modifies it
    /// based on all active weapon abilities. Abilities are applied in a specific order
    /// to ensure correct interaction.
    ///
    /// - Parameters:
    ///   - baseResult: The baseline combat result without abilities
    ///   - weapon: The attacking weapon with its abilities
    ///   - defender: The defending unit
    ///   - range: Optional combat range (for Melta, Rapid Fire)
    ///   - defenderKeywords: Optional defender keywords (for Anti-X)
    ///   - defenderHasCover: Whether defender has cover (for Ignores Cover)
    /// - Returns: Enhanced combat result with all abilities applied
    func applyAbilities(
        baseResult: CombatResult,
        weapon: Weapon,
        defender: Defender,
        range: Int?,
        defenderKeywords: [String],
        defenderHasCover: Bool
    ) -> CombatResult

    /// Calculates complete combat result including all weapon abilities
    ///
    /// This is a convenience method that combines probability calculation
    /// and ability processing in one call.
    ///
    /// - Parameters:
    ///   - weapon: The attacking weapon
    ///   - defender: The defending unit
    ///   - probabilityEngine: Engine for base probability calculations
    ///   - range: Optional combat range
    ///   - defenderKeywords: Optional defender keywords
    ///   - defenderHasCover: Whether defender has cover
    /// - Returns: Complete combat result with abilities applied
    func calculateCombatResultWithAbilities(
        weapon: Weapon,
        defender: Defender,
        probabilityEngine: ProbabilityCalculating,
        range: Int?,
        defenderKeywords: [String],
        defenderHasCover: Bool
    ) -> CombatResult
}

// MARK: - Default Implementations

public extension AbilityProcessing {
    /// Applies abilities with default optional parameters
    func applyAbilities(
        baseResult: CombatResult,
        weapon: Weapon,
        defender: Defender
    ) -> CombatResult {
        applyAbilities(
            baseResult: baseResult,
            weapon: weapon,
            defender: defender,
            range: nil,
            defenderKeywords: [],
            defenderHasCover: false
        )
    }

    /// Calculates combat result with abilities using default optional parameters
    func calculateCombatResultWithAbilities(
        weapon: Weapon,
        defender: Defender,
        probabilityEngine: ProbabilityCalculating
    ) -> CombatResult {
        calculateCombatResultWithAbilities(
            weapon: weapon,
            defender: defender,
            probabilityEngine: probabilityEngine,
            range: nil,
            defenderKeywords: [],
            defenderHasCover: false
        )
    }

    /// Calculates combat result with specific range
    func calculateCombatResultWithAbilities(
        weapon: Weapon,
        defender: Defender,
        probabilityEngine: ProbabilityCalculating,
        range: Int?
    ) -> CombatResult {
        calculateCombatResultWithAbilities(
            weapon: weapon,
            defender: defender,
            probabilityEngine: probabilityEngine,
            range: range,
            defenderKeywords: [],
            defenderHasCover: false
        )
    }

    /// Calculates combat result with defender keywords
    func calculateCombatResultWithAbilities(
        weapon: Weapon,
        defender: Defender,
        probabilityEngine: ProbabilityCalculating,
        defenderKeywords: [String]
    ) -> CombatResult {
        calculateCombatResultWithAbilities(
            weapon: weapon,
            defender: defender,
            probabilityEngine: probabilityEngine,
            range: nil,
            defenderKeywords: defenderKeywords,
            defenderHasCover: false
        )
    }

    /// Calculates combat result with cover status
    func calculateCombatResultWithAbilities(
        weapon: Weapon,
        defender: Defender,
        probabilityEngine: ProbabilityCalculating,
        defenderHasCover: Bool
    ) -> CombatResult {
        calculateCombatResultWithAbilities(
            weapon: weapon,
            defender: defender,
            probabilityEngine: probabilityEngine,
            range: nil,
            defenderKeywords: [],
            defenderHasCover: defenderHasCover
        )
    }
}
