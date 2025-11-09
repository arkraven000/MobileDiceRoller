//
//  SimulationViewModel.swift
//  MobileDiceRoller
//
//  Created on 2025-11-08.
//

import Foundation
import Observation

/// ViewModel for the Monte Carlo simulation screen
///
/// This ViewModel manages async task execution for long-running simulations,
/// with support for cancellation and progress tracking. Uses @Observable
/// for reactive state management.
///
/// ## Features
/// - Async/await task management
/// - Cancellation support via Task.cancel()
/// - Progress tracking
/// - Error handling
///
/// ## Usage
/// ```swift
/// let viewModel = SimulationViewModel(
///     simulator: simulator,
///     analyzer: analyzer
/// )
/// await viewModel.runSimulation(weapon: boltRifle, defender: spaceMarine, iterations: 10000)
/// ```
@Observable
public final class SimulationViewModel {
    // MARK: - Dependencies

    private let simulator: MonteCarloSimulating
    private let analyzer: StatisticalAnalyzing

    // MARK: - State

    /// Current weapon being simulated
    public var weapon: Weapon?

    /// Current defender being simulated
    public var defender: Defender?

    /// Number of iterations to run
    public var iterations: Int = 10000

    /// Simulation result
    public var result: SimulationResult?

    /// Whether a simulation is currently running
    public var isRunning: Bool = false

    /// Progress (0.0 to 1.0)
    public var progress: Double = 0.0

    /// Error message if simulation fails
    public var errorMessage: String?

    /// Range for range-dependent abilities
    public var range: Int?

    /// Defender keywords for Anti-X abilities
    public var defenderKeywords: [String] = []

    /// Whether defender has cover
    public var defenderHasCover: Bool = false

    // MARK: - Private Properties

    /// Current simulation task (for cancellation)
    private var currentTask: Task<Void, Never>?

    // MARK: - Computed Properties

    /// Whether simulation can be started
    public var canRunSimulation: Bool {
        weapon != nil && defender != nil && !isRunning && iterations > 0
    }

    /// Whether simulation can be cancelled
    public var canCancelSimulation: Bool {
        isRunning
    }

    /// Whether there are results to display
    public var hasResults: Bool {
        result != nil
    }

    // MARK: - Initialization

    public init(
        simulator: MonteCarloSimulating,
        analyzer: StatisticalAnalyzing
    ) {
        self.simulator = simulator
        self.analyzer = analyzer
    }

    // MARK: - Actions

    /// Updates the weapon
    public func updateWeapon(_ newWeapon: Weapon) {
        weapon = newWeapon
        errorMessage = nil
    }

    /// Updates the defender
    public func updateDefender(_ newDefender: Defender) {
        defender = newDefender
        errorMessage = nil
    }

    /// Updates the number of iterations
    public func updateIterations(_ newIterations: Int) {
        iterations = max(1, min(newIterations, 1_000_000))
    }

    /// Updates the range
    public func updateRange(_ newRange: Int?) {
        range = newRange
    }

    /// Updates defender keywords
    public func updateDefenderKeywords(_ keywords: [String]) {
        defenderKeywords = keywords
    }

    /// Updates whether defender has cover
    public func updateDefenderHasCover(_ hasCover: Bool) {
        defenderHasCover = hasCover
    }

    /// Runs the Monte Carlo simulation
    public func runSimulation(
        probabilityEngine: ProbabilityCalculating,
        abilityProcessor: AbilityProcessing
    ) async {
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

        // Cancel any existing simulation
        await cancelSimulation()

        isRunning = true
        progress = 0.0
        errorMessage = nil
        result = nil

        // Create a new task for the simulation
        currentTask = Task {
            do {
                // Run simulation
                let simulationResult = simulator.runSimulation(
                    weapon: weapon,
                    defender: defender,
                    iterations: iterations,
                    probabilityEngine: probabilityEngine,
                    abilityProcessor: abilityProcessor,
                    range: range,
                    defenderKeywords: defenderKeywords,
                    defenderHasCover: defenderHasCover
                )

                // Check if cancelled
                if Task.isCancelled {
                    await MainActor.run {
                        isRunning = false
                        progress = 0.0
                    }
                    return
                }

                // Update result on main actor
                await MainActor.run {
                    result = simulationResult
                    progress = 1.0
                    isRunning = false
                }
            } catch {
                await MainActor.run {
                    errorMessage = "Simulation failed: \(error.localizedDescription)"
                    isRunning = false
                    progress = 0.0
                }
            }
        }

        // Simulate progress updates (since actual simulation doesn't provide progress)
        Task {
            while isRunning && progress < 0.9 {
                try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
                await MainActor.run {
                    if isRunning {
                        progress = min(progress + 0.1, 0.9)
                    }
                }
            }
        }

        await currentTask?.value
    }

    /// Cancels the currently running simulation
    public func cancelSimulation() async {
        currentTask?.cancel()
        currentTask = nil

        await MainActor.run {
            isRunning = false
            progress = 0.0
        }
    }

    /// Resets all state
    public func reset() {
        weapon = nil
        defender = nil
        iterations = 10000
        result = nil
        isRunning = false
        progress = 0.0
        errorMessage = nil
        range = nil
        defenderKeywords = []
        defenderHasCover = false
        currentTask?.cancel()
        currentTask = nil
    }

    /// Clears only the results
    public func clearResults() {
        result = nil
        errorMessage = nil
        progress = 0.0
    }
}
