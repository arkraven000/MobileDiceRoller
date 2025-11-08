//
//  Weapon.swift
//  MobileDiceRoller
//
//  Created on 2025-11-08.
//

import Foundation

/// Represents a weapon in Warhammer 40K with its characteristics
///
/// A weapon defines the offensive capabilities of a unit, including
/// the number of attacks, hit chance, strength, armor penetration,
/// damage, and special abilities from Warhammer 40K 10th Edition.
///
/// ## Value Semantics
/// This struct uses value semantics (struct) for immutability and safety.
/// All properties are immutable to prevent accidental modification.
///
/// ## Usage
/// ```swift
/// let boltRifle = Weapon(
///     name: "Bolt Rifle",
///     attacks: 2,
///     skill: 3,
///     strength: 4,
///     armorPenetration: -1,
///     damage: "1",
///     range: 24
/// )
/// ```
///
/// ## Factory Methods
/// Common weapons can be created using factory methods:
/// ```swift
/// let boltRifle = Weapon.boltRifle()
/// ```
public struct Weapon: Equatable, Codable, Hashable {
    // MARK: - Properties

    /// The name of the weapon (e.g., "Bolt Rifle", "Plasma Gun")
    public let name: String

    /// Number of attacks this weapon makes
    public let attacks: Int

    /// Ballistic Skill (BS) or Weapon Skill (WS) - the value needed to hit (2-6+)
    public let skill: Int

    /// Strength characteristic (1-20+)
    public let strength: Int

    /// Armor Penetration (0 to -6)
    public let armorPenetration: Int

    /// Damage per successful hit (can be "1", "D3", "D6", "D6+2", etc.)
    public let damage: String

    /// Special abilities (e.g., Lethal Hits, Devastating Wounds)
    public let abilities: [WeaponAbility]

    /// Maximum range in inches (nil for melee weapons)
    public let range: Int?

    // MARK: - Computed Properties

    /// Returns true if this is a ranged weapon
    public var isRanged: Bool {
        range != nil
    }

    /// Returns true if this weapon can be used in combat
    ///
    /// A weapon is valid if:
    /// - It has at least 1 attack
    /// - Skill is between 2 and 6 (valid BS/WS range in 40K 10th edition)
    public var isValidForCombat: Bool {
        attacks > 0 && skill >= 2 && skill <= 6
    }

    // MARK: - Initialization

    /// Creates a new weapon with the specified characteristics
    ///
    /// - Parameters:
    ///   - name: The weapon's name
    ///   - attacks: Number of attacks
    ///   - skill: Ballistic Skill or Weapon Skill (2-6)
    ///   - strength: Strength characteristic
    ///   - armorPenetration: AP value (0 to -6)
    ///   - damage: Damage characteristic (e.g., "1", "D6")
    ///   - abilities: Special weapon abilities
    ///   - range: Maximum range in inches (nil for melee)
    public init(
        name: String,
        attacks: Int,
        skill: Int,
        strength: Int,
        armorPenetration: Int,
        damage: String,
        abilities: [WeaponAbility] = [],
        range: Int? = nil
    ) {
        self.name = name
        self.attacks = attacks
        self.skill = skill
        self.strength = strength
        self.armorPenetration = armorPenetration
        self.damage = damage
        self.abilities = abilities
        self.range = range
    }
}

// MARK: - Factory Methods

extension Weapon {
    /// Creates a standard Bolt Rifle from Warhammer 40K 10th edition
    ///
    /// Bolt Rifles are the signature weapon of Primaris Space Marines.
    ///
    /// - Returns: A Bolt Rifle with standard profile
    public static func boltRifle() -> Weapon {
        Weapon(
            name: "Bolt Rifle",
            attacks: 2,
            skill: 3,
            strength: 4,
            armorPenetration: -1,
            damage: "1",
            abilities: [],
            range: 24
        )
    }

    /// Creates a standard Bolter from Warhammer 40K 10th edition
    ///
    /// - Returns: A Bolter with standard profile
    public static func bolter() -> Weapon {
        Weapon(
            name: "Bolter",
            attacks: 2,
            skill: 3,
            strength: 4,
            armorPenetration: 0,
            damage: "1",
            abilities: [.rapidFire1],
            range: 24
        )
    }

    /// Creates a standard Plasma Gun from Warhammer 40K 10th edition
    ///
    /// - Returns: A Plasma Gun with standard profile (standard mode)
    public static func plasmaGun() -> Weapon {
        Weapon(
            name: "Plasma Gun",
            attacks: 1,
            skill: 3,
            strength: 7,
            armorPenetration: -2,
            damage: "1",
            abilities: [.rapidFire1],
            range: 24
        )
    }

    /// Creates a standard Plasma Gun (supercharge mode)
    ///
    /// - Returns: A Plasma Gun with supercharge profile
    public static func plasmaGunSupercharge() -> Weapon {
        Weapon(
            name: "Plasma Gun (Supercharge)",
            attacks: 1,
            skill: 3,
            strength: 8,
            armorPenetration: -3,
            damage: "2",
            abilities: [.rapidFire1, .hazardous],
            range: 24
        )
    }

    /// Creates a standard Chainsword from Warhammer 40K 10th edition
    ///
    /// - Returns: A Chainsword with standard profile
    public static func chainsword() -> Weapon {
        Weapon(
            name: "Chainsword",
            attacks: 3,
            skill: 3,
            strength: 4,
            armorPenetration: -1,
            damage: "1",
            abilities: [],
            range: nil
        )
    }
}

// MARK: - CustomStringConvertible

extension Weapon: CustomStringConvertible {
    public var description: String {
        var desc = "\(name): A\(attacks) BS/WS\(skill)+ S\(strength) AP\(armorPenetration) D\(damage)"

        if let range = range {
            desc += " Range: \(range)\""
        } else {
            desc += " (Melee)"
        }

        if !abilities.isEmpty {
            let abilityNames = abilities.map { $0.displayName }.joined(separator: ", ")
            desc += " [\(abilityNames)]"
        }

        return desc
    }
}
