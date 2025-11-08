//
//  Defender.swift
//  MobileDiceRoller
//
//  Created on 2025-11-08.
//

import Foundation

/// Represents a defending unit in Warhammer 40K with its defensive characteristics
///
/// A defender defines the defensive capabilities of a unit, including toughness,
/// armor save, invulnerable save, Feel No Pain, wounds per model, and number of models.
///
/// ## Value Semantics
/// This struct uses value semantics (struct) for immutability and safety.
/// All properties are immutable to prevent accidental modification.
///
/// ## Usage
/// ```swift
/// let spaceMarine = Defender(
///     name: "Space Marine",
///     toughness: 4,
///     save: 3,
///     invulnerableSave: nil,
///     feelNoPain: nil,
///     wounds: 2,
///     modelCount: 10
/// )
/// ```
///
/// ## Factory Methods
/// Common units can be created using factory methods:
/// ```swift
/// let spaceMarine = Defender.spaceMarine()
/// ```
public struct Defender: Equatable, Codable, Hashable {
    // MARK: - Properties

    /// The name of the unit (e.g., "Space Marine", "Terminator")
    public let name: String

    /// Toughness characteristic (1-12+)
    public let toughness: Int

    /// Armor Save characteristic (2-6+)
    public let save: Int

    /// Invulnerable Save (2-6+), if any
    ///
    /// Invulnerable saves cannot be modified by AP and are used
    /// if they are better than the modified armor save.
    public let invulnerableSave: Int?

    /// Feel No Pain roll (2-6+), if any
    ///
    /// Feel No Pain allows a unit to ignore wounds on a specific roll.
    /// This roll is made after failed saves.
    public let feelNoPain: Int?

    /// Wounds per model
    public let wounds: Int

    /// Number of models in the unit
    public let modelCount: Int

    // MARK: - Computed Properties

    /// Returns true if this unit has an invulnerable save
    public var hasInvulnerableSave: Bool {
        invulnerableSave != nil
    }

    /// Returns true if this unit has Feel No Pain
    public var hasFeelNoPain: Bool {
        feelNoPain != nil
    }

    /// Returns the total wounds for the entire unit
    ///
    /// Calculated as wounds per model × number of models
    public var totalWounds: Int {
        wounds * modelCount
    }

    /// Returns true if this defender is valid for combat
    ///
    /// A defender is valid if:
    /// - It has at least 1 wound per model
    /// - It has at least 1 model
    /// - Save is between 2 and 6 (valid save range in 40K 10th edition)
    public var isValid: Bool {
        wounds > 0 &&
        modelCount > 0 &&
        save >= 2 && save <= 6
    }

    // MARK: - Initialization

    /// Creates a new defender with the specified characteristics
    ///
    /// - Parameters:
    ///   - name: The unit's name
    ///   - toughness: Toughness characteristic
    ///   - save: Armor Save characteristic (2-6)
    ///   - invulnerableSave: Optional invulnerable save (2-6)
    ///   - feelNoPain: Optional Feel No Pain roll (2-6)
    ///   - wounds: Wounds per model
    ///   - modelCount: Number of models in the unit
    public init(
        name: String,
        toughness: Int,
        save: Int,
        invulnerableSave: Int? = nil,
        feelNoPain: Int? = nil,
        wounds: Int,
        modelCount: Int
    ) {
        self.name = name
        self.toughness = toughness
        self.save = save
        self.invulnerableSave = invulnerableSave
        self.feelNoPain = feelNoPain
        self.wounds = wounds
        self.modelCount = modelCount
    }
}

// MARK: - Factory Methods

extension Defender {
    /// Creates a standard Space Marine from Warhammer 40K 10th edition
    ///
    /// - Returns: A Space Marine with standard profile
    public static func spaceMarine() -> Defender {
        Defender(
            name: "Space Marine",
            toughness: 4,
            save: 3,
            invulnerableSave: nil,
            feelNoPain: nil,
            wounds: 2,
            modelCount: 10
        )
    }

    /// Creates a standard Terminator from Warhammer 40K 10th edition
    ///
    /// - Returns: A Terminator with standard profile
    public static func terminator() -> Defender {
        Defender(
            name: "Terminator",
            toughness: 5,
            save: 2,
            invulnerableSave: 4,
            feelNoPain: nil,
            wounds: 3,
            modelCount: 5
        )
    }

    /// Creates a standard Imperial Guardsman from Warhammer 40K 10th edition
    ///
    /// - Returns: A Guardsman with standard profile
    public static func guardsman() -> Defender {
        Defender(
            name: "Imperial Guardsman",
            toughness: 3,
            save: 5,
            invulnerableSave: nil,
            feelNoPain: nil,
            wounds: 1,
            modelCount: 10
        )
    }

    /// Creates a Plague Marine with Feel No Pain from Warhammer 40K 10th edition
    ///
    /// - Returns: A Plague Marine with Disgustingly Resilient (FNP 5+)
    public static func plagueMarine() -> Defender {
        Defender(
            name: "Plague Marine",
            toughness: 5,
            save: 3,
            invulnerableSave: nil,
            feelNoPain: 5,
            wounds: 2,
            modelCount: 7
        )
    }
}

// MARK: - CustomStringConvertible

extension Defender: CustomStringConvertible {
    public var description: String {
        var desc = "\(name): T\(toughness) Sv\(save)+"

        if let invuln = invulnerableSave {
            desc += " Inv\(invuln)+"
        }

        if let fnp = feelNoPain {
            desc += " FNP\(fnp)+"
        }

        desc += " W\(wounds)"

        if modelCount > 1 {
            desc += " ×\(modelCount) models (\(totalWounds) total wounds)"
        }

        return desc
    }
}
