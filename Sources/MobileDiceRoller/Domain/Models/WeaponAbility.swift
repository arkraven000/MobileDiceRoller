//
//  WeaponAbility.swift
//  MobileDiceRoller
//
//  Created on 2025-11-08.
//

import Foundation

/// Weapon abilities from Warhammer 40K 10th Edition
///
/// This enum represents all 18 weapon abilities that can be applied to weapons.
/// Each ability modifies combat behavior in specific ways.
///
/// ## Abilities
/// - **Lethal Hits**: Critical hits automatically wound
/// - **Devastating Wounds**: Critical wounds bypass saves
/// - **Sustained Hits**: Generate additional hits on critical rolls
/// - **Torrent**: Automatically hit without rolling
/// - **Twin-Linked**: Re-roll wound rolls
/// - **Melta**: Bonus damage at half range
/// - **Rapid Fire**: Extra attacks at close range
/// - **Blast**: Bonus attacks vs large units
/// - **Anti-X**: Critical wounds against specific unit types
/// - **Ignores Cover**: Target cannot claim cover saves
/// - **Precision**: Can allocate attacks to specific models
/// - **Hazardous**: May cause mortal wounds on attack rolls of 1
///
/// ## Usage
/// ```swift
/// let weapon = Weapon(
///     name: "Plasma Gun",
///     abilities: [.lethalHits, .hazardous]
/// )
/// ```
public enum WeaponAbility: Equatable, Codable, Hashable {
    // MARK: - Critical Hit Modifiers

    /// Critical hits automatically wound (no wound roll needed)
    case lethalHits

    /// Generate 1 additional hit on critical hit rolls
    case sustainedHits1

    /// Generate 2 additional hits on critical hit rolls
    case sustainedHits2

    /// Generate 3 additional hits on critical hit rolls
    case sustainedHits3

    /// Convenience case for sustained hits with parameter
    case sustainedHits(Int)

    // MARK: - Critical Wound Modifiers

    /// Critical wounds bypass armor and invulnerable saves
    case devastatingWounds

    /// Critical wounds on 6+ against specific unit type
    /// - Parameter unitType: The keyword the target must have (e.g., "Infantry", "Monster")
    case anti(String)

    // MARK: - Hit Roll Modifiers

    /// Automatically hit without rolling (typically for flame weapons)
    case torrent

    // MARK: - Wound Roll Modifiers

    /// Re-roll wound rolls
    case twinLinked

    // MARK: - Range-Based Modifiers

    /// Add 2 to damage rolls at half range or closer
    case melta2

    /// Add 4 to damage rolls at half range or closer
    case melta4

    /// Convenience case for melta with parameter
    case melta(Int)

    // MARK: - Attack Count Modifiers

    /// Add 1 attack at half range or closer
    case rapidFire1

    /// Add 2 attacks at half range or closer
    case rapidFire2

    /// Convenience case for rapid fire with parameter
    case rapidFire(Int)

    /// Add attacks equal to models in target unit (minimum 3 attacks)
    case blast

    // MARK: - Defensive Modifiers

    /// Target cannot benefit from cover
    case ignoresCover

    /// Can allocate attacks to specific models
    case precision

    // MARK: - Risk Modifiers

    /// Attack rolls of 1 cause mortal wounds to bearer
    case hazardous

    // MARK: - Additional Abilities

    /// Re-roll hit rolls of 1
    case reRollOnes

    /// Re-roll all failed hit rolls
    case reRollHits

    /// Re-roll all failed wound rolls
    case reRollWounds

    // MARK: - Computed Properties

    /// Returns true if this ability affects hit rolls
    public var affectsHitRolls: Bool {
        switch self {
        case .lethalHits, .sustainedHits1, .sustainedHits2, .sustainedHits3, .sustainedHits(_),
             .torrent, .reRollOnes, .reRollHits, .hazardous:
            return true
        default:
            return false
        }
    }

    /// Returns true if this ability affects wound rolls
    public var affectsWoundRolls: Bool {
        switch self {
        case .devastatingWounds, .anti(_), .twinLinked, .reRollWounds:
            return true
        default:
            return false
        }
    }

    /// Returns true if this ability is range-dependent
    public var isRangeDependent: Bool {
        switch self {
        case .melta2, .melta4, .melta(_), .rapidFire1, .rapidFire2, .rapidFire(_):
            return true
        default:
            return false
        }
    }

    /// Returns the display name for this ability
    public var displayName: String {
        switch self {
        case .lethalHits:
            return "Lethal Hits"
        case .sustainedHits1, .sustainedHits(1):
            return "Sustained Hits 1"
        case .sustainedHits2, .sustainedHits(2):
            return "Sustained Hits 2"
        case .sustainedHits3, .sustainedHits(3):
            return "Sustained Hits 3"
        case .sustainedHits(let count):
            return "Sustained Hits \(count)"
        case .devastatingWounds:
            return "Devastating Wounds"
        case .anti(let unitType):
            return "Anti-\(unitType)"
        case .torrent:
            return "Torrent"
        case .twinLinked:
            return "Twin-Linked"
        case .melta2, .melta(2):
            return "Melta 2"
        case .melta4, .melta(4):
            return "Melta 4"
        case .melta(let bonus):
            return "Melta \(bonus)"
        case .rapidFire1, .rapidFire(1):
            return "Rapid Fire 1"
        case .rapidFire2, .rapidFire(2):
            return "Rapid Fire 2"
        case .rapidFire(let bonus):
            return "Rapid Fire \(bonus)"
        case .blast:
            return "Blast"
        case .ignoresCover:
            return "Ignores Cover"
        case .precision:
            return "Precision"
        case .hazardous:
            return "Hazardous"
        case .reRollOnes:
            return "Re-roll 1s to Hit"
        case .reRollHits:
            return "Re-roll Failed Hits"
        case .reRollWounds:
            return "Re-roll Failed Wounds"
        }
    }
}

// MARK: - Codable Conformance

extension WeaponAbility {
    private enum CodingKeys: String, CodingKey {
        case type
        case value
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        switch self {
        case .lethalHits:
            try container.encode("lethalHits", forKey: .type)
        case .sustainedHits1, .sustainedHits(1):
            try container.encode("sustainedHits", forKey: .type)
            try container.encode(1, forKey: .value)
        case .sustainedHits2, .sustainedHits(2):
            try container.encode("sustainedHits", forKey: .type)
            try container.encode(2, forKey: .value)
        case .sustainedHits3, .sustainedHits(3):
            try container.encode("sustainedHits", forKey: .type)
            try container.encode(3, forKey: .value)
        case .sustainedHits(let count):
            try container.encode("sustainedHits", forKey: .type)
            try container.encode(count, forKey: .value)
        case .devastatingWounds:
            try container.encode("devastatingWounds", forKey: .type)
        case .anti(let unitType):
            try container.encode("anti", forKey: .type)
            try container.encode(unitType, forKey: .value)
        case .torrent:
            try container.encode("torrent", forKey: .type)
        case .twinLinked:
            try container.encode("twinLinked", forKey: .type)
        case .melta2, .melta(2):
            try container.encode("melta", forKey: .type)
            try container.encode(2, forKey: .value)
        case .melta4, .melta(4):
            try container.encode("melta", forKey: .type)
            try container.encode(4, forKey: .value)
        case .melta(let bonus):
            try container.encode("melta", forKey: .type)
            try container.encode(bonus, forKey: .value)
        case .rapidFire1, .rapidFire(1):
            try container.encode("rapidFire", forKey: .type)
            try container.encode(1, forKey: .value)
        case .rapidFire2, .rapidFire(2):
            try container.encode("rapidFire", forKey: .type)
            try container.encode(2, forKey: .value)
        case .rapidFire(let bonus):
            try container.encode("rapidFire", forKey: .type)
            try container.encode(bonus, forKey: .value)
        case .blast:
            try container.encode("blast", forKey: .type)
        case .ignoresCover:
            try container.encode("ignoresCover", forKey: .type)
        case .precision:
            try container.encode("precision", forKey: .type)
        case .hazardous:
            try container.encode("hazardous", forKey: .type)
        case .reRollOnes:
            try container.encode("reRollOnes", forKey: .type)
        case .reRollHits:
            try container.encode("reRollHits", forKey: .type)
        case .reRollWounds:
            try container.encode("reRollWounds", forKey: .type)
        }
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(String.self, forKey: .type)

        switch type {
        case "lethalHits":
            self = .lethalHits
        case "sustainedHits":
            let count = try container.decode(Int.self, forKey: .value)
            self = .sustainedHits(count)
        case "devastatingWounds":
            self = .devastatingWounds
        case "anti":
            let unitType = try container.decode(String.self, forKey: .value)
            self = .anti(unitType)
        case "torrent":
            self = .torrent
        case "twinLinked":
            self = .twinLinked
        case "melta":
            let bonus = try container.decode(Int.self, forKey: .value)
            self = .melta(bonus)
        case "rapidFire":
            let bonus = try container.decode(Int.self, forKey: .value)
            self = .rapidFire(bonus)
        case "blast":
            self = .blast
        case "ignoresCover":
            self = .ignoresCover
        case "precision":
            self = .precision
        case "hazardous":
            self = .hazardous
        case "reRollOnes":
            self = .reRollOnes
        case "reRollHits":
            self = .reRollHits
        case "reRollWounds":
            self = .reRollWounds
        default:
            throw DecodingError.dataCorruptedError(
                forKey: .type,
                in: container,
                debugDescription: "Unknown weapon ability type: \(type)"
            )
        }
    }
}
