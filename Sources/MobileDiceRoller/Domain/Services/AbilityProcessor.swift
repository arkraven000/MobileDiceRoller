//
//  AbilityProcessor.swift
//  MobileDiceRoller
//
//  Created on 2025-11-08.
//

import Foundation

/// Concrete implementation of weapon ability processing for Warhammer 40K
///
/// This service applies weapon abilities to combat calculations using the Strategy pattern.
/// Each ability modifies the combat result in a specific way following 40K 10th Edition rules.
///
/// ## Single Responsibility
/// This class has ONE responsibility: apply weapon abilities to combat calculations.
/// It works in conjunction with ProbabilityEngine but doesn't duplicate its logic.
///
/// ## Strategy Pattern
/// Each ability is processed through dedicated methods, allowing easy extension
/// and modification without changing the core structure.
public final class AbilityProcessor: AbilityProcessing {

    // MARK: - Constants

    private let criticalHitRoll = 6  // Unmodified 6 is always a critical hit
    private let criticalHitProbability = 1.0 / 6.0  // 16.67%

    // MARK: - Initialization

    public init() {}

    // MARK: - AbilityProcessing

    public func applyAbilities(
        baseResult: CombatResult,
        weapon: Weapon,
        defender: Defender,
        range: Int? = nil,
        defenderKeywords: [String] = [],
        defenderHasCover: Bool = false
    ) -> CombatResult {
        // If no abilities, return base result unchanged
        guard !weapon.abilities.isEmpty else {
            return baseResult
        }

        var result = baseResult
        var modifiedAttacks = Double(weapon.attacks)

        // Apply attack-modifying abilities first
        for ability in weapon.abilities {
            switch ability {
            case .rapidFire(let bonus), .rapidFire1, .rapidFire2:
                let bonusValue = extractRapidFireBonus(ability)
                if isAtHalfRange(weaponRange: weapon.range, currentRange: range) {
                    modifiedAttacks += Double(bonusValue)
                }

            case .blast:
                modifiedAttacks += calculateBlastBonus(defenderModelCount: defender.modelCount)

            default:
                break
            }
        }

        // Recalculate if attacks were modified
        if modifiedAttacks != Double(weapon.attacks) {
            result = recalculateWithModifiedAttacks(
                attacks: modifiedAttacks,
                weapon: weapon,
                defender: defender,
                defenderHasCover: defenderHasCover
            )
        }

        // Apply hit-phase abilities
        for ability in weapon.abilities {
            switch ability {
            case .torrent:
                result = applyTorrent(result: result, attacks: modifiedAttacks)

            case .sustainedHits(let count), .sustainedHits1, .sustainedHits2, .sustainedHits3:
                let sustainedCount = extractSustainedHitsCount(ability)
                result = applySustainedHits(result: result, count: sustainedCount, attacks: modifiedAttacks)

            case .lethalHits:
                result = applyLethalHits(result: result, weapon: weapon, defender: defender, attacks: modifiedAttacks)

            default:
                break
            }
        }

        // Apply wound-phase abilities
        for ability in weapon.abilities {
            switch ability {
            case .twinLinked:
                result = applyTwinLinked(result: result)

            case .devastatingWounds:
                result = applyDevastatingWounds(result: result, weapon: weapon, defender: defender)

            case .anti(let keyword):
                if defenderKeywords.contains(keyword) {
                    result = applyAnti(result: result, weapon: weapon, defender: defender)
                }

            default:
                break
            }
        }

        // Apply damage-phase abilities
        for ability in weapon.abilities {
            switch ability {
            case .melta(let bonus), .melta2, .melta4:
                let meltaBonus = extractMeltaBonus(ability)
                if isAtHalfRange(weaponRange: weapon.range, currentRange: range) {
                    result = applyMelta(result: result, bonus: meltaBonus, weapon: weapon)
                }

            default:
                break
            }
        }

        // Apply save-phase abilities
        for ability in weapon.abilities {
            switch ability {
            case .ignoresCover:
                if defenderHasCover {
                    result = applyIgnoresCover(result: result, defender: defender, weapon: weapon)
                }

            default:
                break
            }
        }

        return result
    }

    public func calculateCombatResultWithAbilities(
        weapon: Weapon,
        defender: Defender,
        probabilityEngine: ProbabilityCalculating,
        range: Int? = nil,
        defenderKeywords: [String] = [],
        defenderHasCover: Bool = false
    ) -> CombatResult {
        let baseResult = probabilityEngine.calculateCombatResult(weapon: weapon, defender: defender)
        return applyAbilities(
            baseResult: baseResult,
            weapon: weapon,
            defender: defender,
            range: range,
            defenderKeywords: defenderKeywords,
            defenderHasCover: defenderHasCover
        )
    }

    // MARK: - Ability Implementation Methods

    /// Applies Torrent ability (auto-hit)
    private func applyTorrent(result: CombatResult, attacks: Double) -> CombatResult {
        CombatResult(
            expectedHits: attacks,  // All attacks auto-hit
            expectedWounds: attacks * result.woundProbability,
            expectedUnsavedWounds: attacks * result.woundProbability * result.saveFailProbability,
            expectedDamage: attacks * result.woundProbability * result.saveFailProbability * (result.expectedDamage / max(result.expectedUnsavedWounds, 0.001)),
            expectedModelsKilled: result.expectedModelsKilled * (attacks / max(result.expectedHits, 0.001)),
            hitProbability: 1.0,
            woundProbability: result.woundProbability,
            saveFailProbability: result.saveFailProbability,
            killProbability: result.killProbability
        )
    }

    /// Applies Sustained Hits ability
    private func applySustainedHits(result: CombatResult, count: Int, attacks: Double) -> CombatResult {
        // Critical hits generate additional hits
        let bonusHits = attacks * criticalHitProbability * Double(count)
        let totalHits = result.expectedHits + bonusHits

        return CombatResult(
            expectedHits: totalHits,
            expectedWounds: totalHits * result.woundProbability,
            expectedUnsavedWounds: totalHits * result.woundProbability * result.saveFailProbability,
            expectedDamage: totalHits * result.woundProbability * result.saveFailProbability * (result.expectedDamage / max(result.expectedUnsavedWounds, 0.001)),
            expectedModelsKilled: result.expectedModelsKilled * (totalHits / max(result.expectedHits, 0.001)),
            hitProbability: result.hitProbability,
            woundProbability: result.woundProbability,
            saveFailProbability: result.saveFailProbability,
            killProbability: result.killProbability
        )
    }

    /// Applies Lethal Hits ability (critical hits auto-wound)
    private func applyLethalHits(result: CombatResult, weapon: Weapon, defender: Defender, attacks: Double) -> CombatResult {
        // Normal hits wound normally, critical hits auto-wound
        let normalHitProb = result.hitProbability - criticalHitProbability
        let normalWounds = attacks * normalHitProb * result.woundProbability
        let criticalWounds = attacks * criticalHitProbability * 1.0  // Auto-wound

        let totalWounds = normalWounds + criticalWounds

        return CombatResult(
            expectedHits: result.expectedHits,
            expectedWounds: totalWounds,
            expectedUnsavedWounds: totalWounds * result.saveFailProbability,
            expectedDamage: totalWounds * result.saveFailProbability * (result.expectedDamage / max(result.expectedUnsavedWounds, 0.001)),
            expectedModelsKilled: result.expectedModelsKilled * (totalWounds / max(result.expectedWounds, 0.001)),
            hitProbability: result.hitProbability,
            woundProbability: totalWounds / max(result.expectedHits, 0.001),
            saveFailProbability: result.saveFailProbability,
            killProbability: result.killProbability
        )
    }

    /// Applies Twin-Linked ability (re-roll wounds)
    private func applyTwinLinked(result: CombatResult) -> CombatResult {
        // Re-rolling wounds: prob = p + (1-p) × p = p × (2 - p)
        let enhancedWoundProb = result.woundProbability * (2.0 - result.woundProbability)

        return CombatResult(
            expectedHits: result.expectedHits,
            expectedWounds: result.expectedHits * enhancedWoundProb,
            expectedUnsavedWounds: result.expectedHits * enhancedWoundProb * result.saveFailProbability,
            expectedDamage: result.expectedHits * enhancedWoundProb * result.saveFailProbability * (result.expectedDamage / max(result.expectedUnsavedWounds, 0.001)),
            expectedModelsKilled: result.expectedModelsKilled * (enhancedWoundProb / max(result.woundProbability, 0.001)),
            hitProbability: result.hitProbability,
            woundProbability: enhancedWoundProb,
            saveFailProbability: result.saveFailProbability,
            killProbability: result.killProbability
        )
    }

    /// Applies Devastating Wounds ability (critical wounds bypass saves)
    private func applyDevastatingWounds(result: CombatResult, weapon: Weapon, defender: Defender) -> CombatResult {
        // Critical wounds (6s to wound) bypass saves
        let normalWoundProb = result.woundProbability - criticalHitProbability
        let normalUnsavedWounds = result.expectedHits * normalWoundProb * result.saveFailProbability
        let criticalUnsavedWounds = result.expectedHits * criticalHitProbability * 1.0  // Bypass save

        let totalUnsavedWounds = normalUnsavedWounds + criticalUnsavedWounds

        return CombatResult(
            expectedHits: result.expectedHits,
            expectedWounds: result.expectedWounds,
            expectedUnsavedWounds: totalUnsavedWounds,
            expectedDamage: totalUnsavedWounds * (result.expectedDamage / max(result.expectedUnsavedWounds, 0.001)),
            expectedModelsKilled: result.expectedModelsKilled * (totalUnsavedWounds / max(result.expectedUnsavedWounds, 0.001)),
            hitProbability: result.hitProbability,
            woundProbability: result.woundProbability,
            saveFailProbability: totalUnsavedWounds / max(result.expectedWounds, 0.001),
            killProbability: result.killProbability
        )
    }

    /// Applies Anti-X ability (critical wounds on 6+ vs specific keywords)
    private func applyAnti(result: CombatResult, weapon: Weapon, defender: Defender) -> CombatResult {
        // Similar to Devastating Wounds when keywords match
        return applyDevastatingWounds(result: result, weapon: weapon, defender: defender)
    }

    /// Applies Melta ability (bonus damage at half range)
    private func applyMelta(result: CombatResult, bonus: Int, weapon: Weapon) -> CombatResult {
        // Adds bonus to average damage
        let baseDamage = result.expectedDamage / max(result.expectedUnsavedWounds, 0.001)
        let enhancedDamage = baseDamage + Double(bonus)

        return CombatResult(
            expectedHits: result.expectedHits,
            expectedWounds: result.expectedWounds,
            expectedUnsavedWounds: result.expectedUnsavedWounds,
            expectedDamage: result.expectedUnsavedWounds * enhancedDamage,
            expectedModelsKilled: result.expectedModelsKilled * (enhancedDamage / max(baseDamage, 0.001)),
            hitProbability: result.hitProbability,
            woundProbability: result.woundProbability,
            saveFailProbability: result.saveFailProbability,
            killProbability: result.killProbability
        )
    }

    /// Applies Ignores Cover ability
    private func applyIgnoresCover(result: CombatResult, defender: Defender, weapon: Weapon) -> CombatResult {
        // Recalculate save without cover bonus (+1 to save)
        let coverBonus = 1
        let actualSave = defender.save + coverBonus
        let saveWithoutCover = defender.save

        // Recalculate save fail probability without cover
        let engine = ProbabilityEngine()
        let newSaveFailProb = engine.calculateSaveFailProbability(
            save: saveWithoutCover,
            armorPenetration: weapon.armorPenetration,
            invulnerable: defender.invulnerableSave
        )

        return CombatResult(
            expectedHits: result.expectedHits,
            expectedWounds: result.expectedWounds,
            expectedUnsavedWounds: result.expectedWounds * newSaveFailProb,
            expectedDamage: result.expectedWounds * newSaveFailProb * (result.expectedDamage / max(result.expectedUnsavedWounds, 0.001)),
            expectedModelsKilled: result.expectedModelsKilled * (newSaveFailProb / max(result.saveFailProbability, 0.001)),
            hitProbability: result.hitProbability,
            woundProbability: result.woundProbability,
            saveFailProbability: newSaveFailProb,
            killProbability: result.killProbability
        )
    }

    // MARK: - Helper Methods

    /// Recalculates combat result with modified attack count
    private func recalculateWithModifiedAttacks(
        attacks: Double,
        weapon: Weapon,
        defender: Defender,
        defenderHasCover: Bool
    ) -> CombatResult {
        let engine = ProbabilityEngine()
        let hitProb = engine.calculateHitProbability(skill: weapon.skill)
        let woundProb = engine.calculateWoundProbability(strength: weapon.strength, toughness: defender.toughness)

        var saveFailProb = engine.calculateSaveFailProbability(
            save: defender.save,
            armorPenetration: weapon.armorPenetration,
            invulnerable: defender.invulnerableSave
        )

        // Apply cover if applicable
        if defenderHasCover {
            let coverSave = defender.save + 1
            saveFailProb = engine.calculateSaveFailProbability(
                save: coverSave,
                armorPenetration: weapon.armorPenetration,
                invulnerable: defender.invulnerableSave
            )
        }

        let expectedHits = attacks * hitProb
        let expectedWounds = expectedHits * woundProb
        let expectedUnsavedWounds = expectedWounds * saveFailProb

        // Simplified damage calculation
        let avgDamage = averageDamageValue(weapon.damage)
        let expectedDamage = expectedUnsavedWounds * avgDamage
        let expectedKills = defender.wounds > 0 ? expectedDamage / Double(defender.wounds) : 0.0

        return CombatResult(
            expectedHits: expectedHits,
            expectedWounds: expectedWounds,
            expectedUnsavedWounds: expectedUnsavedWounds,
            expectedDamage: expectedDamage,
            expectedModelsKilled: expectedKills,
            hitProbability: hitProb,
            woundProbability: woundProb,
            saveFailProbability: saveFailProb,
            killProbability: expectedKills >= 1.0 ? 1.0 : expectedKills
        )
    }

    /// Checks if current range is at half weapon range or less
    private func isAtHalfRange(weaponRange: Int?, currentRange: Int?) -> Bool {
        guard let weaponRange = weaponRange,
              let currentRange = currentRange else {
            return false
        }

        return currentRange <= weaponRange / 2
    }

    /// Calculates bonus attacks from Blast vs large units
    private func calculateBlastBonus(defenderModelCount: Int) -> Double {
        // Blast: Minimum 3 attacks, or attacks equal to model count for 6-10 models, or +3 for 11+ models
        if defenderModelCount <= 5 {
            return 0.0
        } else if defenderModelCount <= 10 {
            return Double(defenderModelCount) - 6.0  // Use model count as attacks
        } else {
            return 3.0  // +3 attacks for 11+ models
        }
    }

    /// Extracts Sustained Hits count from ability
    private func extractSustainedHitsCount(_ ability: WeaponAbility) -> Int {
        switch ability {
        case .sustainedHits1, .sustainedHits(1):
            return 1
        case .sustainedHits2, .sustainedHits(2):
            return 2
        case .sustainedHits3, .sustainedHits(3):
            return 3
        case .sustainedHits(let count):
            return count
        default:
            return 0
        }
    }

    /// Extracts Rapid Fire bonus from ability
    private func extractRapidFireBonus(_ ability: WeaponAbility) -> Int {
        switch ability {
        case .rapidFire1, .rapidFire(1):
            return 1
        case .rapidFire2, .rapidFire(2):
            return 2
        case .rapidFire(let bonus):
            return bonus
        default:
            return 0
        }
    }

    /// Extracts Melta bonus from ability
    private func extractMeltaBonus(_ ability: WeaponAbility) -> Int {
        switch ability {
        case .melta2, .melta(2):
            return 2
        case .melta4, .melta(4):
            return 4
        case .melta(let bonus):
            return bonus
        default:
            return 0
        }
    }

    /// Gets average damage value from damage string
    private func averageDamageValue(_ damage: String) -> Double {
        let trimmed = damage.trimmingCharacters(in: .whitespaces).uppercased()

        if let fixed = Int(trimmed) {
            return Double(fixed)
        }

        switch trimmed {
        case "D3": return 2.0
        case "D6": return 3.5
        case "2D6": return 7.0
        case "3D6": return 10.5
        default:
            if trimmed.hasPrefix("D6+") {
                let bonusStr = trimmed.dropFirst(3)
                if let bonus = Int(bonusStr) {
                    return 3.5 + Double(bonus)
                }
            }
            if trimmed.hasPrefix("D3+") {
                let bonusStr = trimmed.dropFirst(3)
                if let bonus = Int(bonusStr) {
                    return 2.0 + Double(bonus)
                }
            }
            return 1.0
        }
    }
}
