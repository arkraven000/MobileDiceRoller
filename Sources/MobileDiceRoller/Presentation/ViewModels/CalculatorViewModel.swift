//
//  CalculatorViewModel.swift
//  MobileDiceRoller
//
//  Created on 2025-11-08.
//

import Foundation
import Observation

/// ViewModel for the probability calculator screen
///
/// This ViewModel implements unidirectional data flow and uses the @Observable
/// macro (iOS 17+) for reactive state management. It coordinates between
/// the probability engine, ability processor, and the UI.
///
/// ## Architecture
/// - **Unidirectional Data Flow**: User actions → State updates → View updates
/// - **Dependency Injection**: All dependencies injected via constructor
/// - **Protocol-Based**: Testable with mock dependencies
///
/// ## Usage
/// ```swift
/// let viewModel = CalculatorViewModel(
///     probabilityEngine: engine,
///     abilityProcessor: processor
/// )
/// viewModel.updateWeapon(boltRifle)
/// viewModel.updateDefender(spaceMarine)
/// viewModel.calculate()
/// ```
@Observable
public final class CalculatorViewModel {
    // MARK: - Dependencies

    private let probabilityEngine: ProbabilityCalculating
    private let abilityProcessor: AbilityProcessing

    // MARK: - State

    /// Current weapon being evaluated
    public var weapon: Weapon?

    /// Current defender being evaluated
    public var defender: Defender?

    /// Calculation result
    public var result: CombatResult?

    /// Range for range-dependent abilities
    public var range: Int?

    /// Defender keywords for Anti-X abilities
    public var defenderKeywords: [String] = []

    /// Whether defender has cover
    public var defenderHasCover: Bool = false

    /// Error message if calculation fails
    public var errorMessage: String?

    /// Whether a calculation is in progress
    public var isCalculating: Bool = false

    // MARK: - Computed Properties

    /// Whether the calculate button should be enabled
    public var canCalculate: Bool {
        weapon != nil && defender != nil && !isCalculating
    }

    /// Whether there are results to display
    public var hasResults: Bool {
        result != nil
    }

    // MARK: - Initialization

    public init(
        probabilityEngine: ProbabilityCalculating,
        abilityProcessor: AbilityProcessing
    ) {
        self.probabilityEngine = probabilityEngine
        self.abilityProcessor = abilityProcessor
    }

    // MARK: - Actions

    /// Updates the weapon and recalculates if both inputs are available
    public func updateWeapon(_ newWeapon: Weapon) {
        weapon = newWeapon
        errorMessage = nil

        if defender != nil {
            calculate()
        }
    }

    /// Updates the defender and recalculates if both inputs are available
    public func updateDefender(_ newDefender: Defender) {
        defender = newDefender
        errorMessage = nil

        if weapon != nil {
            calculate()
        }
    }

    /// Updates the range for range-dependent abilities
    public func updateRange(_ newRange: Int?) {
        range = newRange

        if weapon != nil && defender != nil {
            calculate()
        }
    }

    /// Updates defender keywords for Anti-X abilities
    public func updateDefenderKeywords(_ keywords: [String]) {
        defenderKeywords = keywords

        if weapon != nil && defender != nil {
            calculate()
        }
    }

    /// Updates whether defender has cover
    public func updateDefenderHasCover(_ hasCover: Bool) {
        defenderHasCover = hasCover

        if weapon != nil && defender != nil {
            calculate()
        }
    }

    /// Calculates combat results
    public func calculate() {
        guard let weapon = weapon, let defender = defender else {
            errorMessage = "Please select both a weapon and a defender"
            return
        }

        guard weapon.isValidForCombat else {
            errorMessage = "Invalid weapon configuration"
            return
        }

        guard defender.isValid else {
            errorMessage = "Invalid defender configuration"
            return
        }

        isCalculating = true
        errorMessage = nil

        // Perform calculation (synchronous, but fast)
        do {
            let calculatedResult = abilityProcessor.calculateCombatResultWithAbilities(
                weapon: weapon,
                defender: defender,
                probabilityEngine: probabilityEngine,
                range: range,
                defenderKeywords: defenderKeywords,
                defenderHasCover: defenderHasCover
            )

            result = calculatedResult
        } catch {
            errorMessage = "Calculation failed: \(error.localizedDescription)"
            result = nil
        }

        isCalculating = false
    }

    /// Resets all state
    public func reset() {
        weapon = nil
        defender = nil
        result = nil
        range = nil
        defenderKeywords = []
        defenderHasCover = false
        errorMessage = nil
        isCalculating = false
    }

    /// Clears only the results
    public func clearResults() {
        result = nil
        errorMessage = nil
    }
}
