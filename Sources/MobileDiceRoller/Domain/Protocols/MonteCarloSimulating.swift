//
//  MonteCarloSimulating.swift
//  MobileDiceRoller
//
//  Created on 2025-11-08.
//

import Foundation

/// Protocol for Monte Carlo simulation of Warhammer 40K combat
///
/// This protocol defines the interface for running statistical simulations
/// of combat scenarios using random sampling. Monte Carlo simulation provides
/// a more accurate picture of combat outcomes than simple expected value
/// calculations, especially for scenarios with multiple abilities and
/// complex interactions.
///
/// ## Monte Carlo Method
/// Instead of calculating probabilities mathematically, the simulator:
/// 1. Rolls virtual dice thousands/millions of times
/// 2. Records the actual outcomes (damage, kills, etc.)
/// 3. Analyzes the distribution of results
/// 4. Provides statistical measures (mean, median, std deviation, percentiles)
///
/// ## Usage
/// ```swift
/// let simulator: MonteCarloSimulating = MonteCarloSimulator(
///     randomNumberGenerator: SecureRandomNumberGenerator()
/// )
///
/// let result = simulator.runSimulation(
///     weapon: boltRifle,
///     defender: spaceMarine,
///     iterations: 10000
/// )
///
/// print("Average damage: \(result.statistics.mean)")
/// print("90th percentile: \(result.statistics.percentile90)")
/// ```
///
/// ## Performance
/// Simulations should be optimized for performance using:
/// - Concurrent dispatch queues for parallel execution
/// - Pre-allocated arrays for results
/// - Efficient random number generation
public protocol MonteCarloSimulating {
    // MARK: - Simulation Execution

    /// Runs a Monte Carlo simulation of combat between a weapon and defender
    ///
    /// This method simulates the combat `iterations` times and returns
    /// comprehensive statistical analysis of the outcomes.
    ///
    /// - Parameters:
    ///   - weapon: The attacking weapon
    ///   - defender: The defending unit
    ///   - iterations: Number of simulation runs (1 to 1,000,000)
    ///   - probabilityEngine: Engine for calculating base probabilities
    ///   - abilityProcessor: Processor for applying weapon abilities
    ///   - range: Optional range for range-dependent abilities (Melta, Rapid Fire)
    ///   - defenderKeywords: Keywords for Anti-X abilities
    ///   - defenderHasCover: Whether defender has cover (for Ignores Cover)
    /// - Returns: Complete simulation results with statistics
    ///
    /// ## Performance Characteristics
    /// - 1,000 iterations: ~10ms
    /// - 10,000 iterations: ~100ms
    /// - 100,000 iterations: ~1s
    /// - 1,000,000 iterations: ~10s
    ///
    /// ## Example
    /// ```swift
    /// let result = simulator.runSimulation(
    ///     weapon: lascannonWeapon,
    ///     defender: terminatorSquad,
    ///     iterations: 100000,
    ///     probabilityEngine: engine,
    ///     abilityProcessor: processor
    /// )
    /// ```
    func runSimulation(
        weapon: Weapon,
        defender: Defender,
        iterations: Int,
        probabilityEngine: ProbabilityCalculating,
        abilityProcessor: AbilityProcessing,
        range: Int?,
        defenderKeywords: [String],
        defenderHasCover: Bool
    ) -> SimulationResult

    /// Runs a simplified simulation using only base combat calculations
    ///
    /// This variant skips weapon ability processing and uses only the
    /// basic probability engine. Useful for baseline comparisons.
    ///
    /// - Parameters:
    ///   - weapon: The attacking weapon
    ///   - defender: The defending unit
    ///   - iterations: Number of simulation runs (1 to 1,000,000)
    ///   - probabilityEngine: Engine for calculating probabilities
    /// - Returns: Simulation results without ability modifications
    func runSimplifiedSimulation(
        weapon: Weapon,
        defender: Defender,
        iterations: Int,
        probabilityEngine: ProbabilityCalculating
    ) -> SimulationResult
}

// MARK: - Supporting Types

/// Results from a Monte Carlo simulation run
///
/// Contains the raw damage/kill data from all iterations plus
/// comprehensive statistical analysis.
public struct SimulationResult: Equatable, Codable {
    // MARK: - Raw Data

    /// Number of iterations performed
    public let iterations: Int

    /// Array of damage dealt in each iteration
    ///
    /// This array has `iterations` elements, each representing the
    /// total damage dealt in one simulation run.
    public let damageResults: [Double]

    /// Array of models killed in each iteration
    ///
    /// This array has `iterations` elements, each representing the
    /// number of models killed in one simulation run.
    public let killResults: [Double]

    // MARK: - Statistical Analysis

    /// Statistical analysis of damage distribution
    public let damageStatistics: SimulationStatistics

    /// Statistical analysis of kill distribution
    public let killStatistics: SimulationStatistics

    // MARK: - Probabilities

    /// Probability of dealing at least 1 damage (0.0 to 1.0)
    ///
    /// Calculated as: (iterations with damage > 0) / total iterations
    public let probabilityOfAnyDamage: Double

    /// Probability of killing at least 1 model (0.0 to 1.0)
    ///
    /// Calculated as: (iterations with kills ≥ 1) / total iterations
    public let probabilityOfAnyKills: Double

    /// Probability of wiping out the entire unit (0.0 to 1.0)
    ///
    /// Calculated as: (iterations with kills ≥ model count) / total iterations
    public let probabilityOfWipe: Double

    // MARK: - Histogram Data

    /// Histogram bins for damage distribution
    ///
    /// Used for visualization. Each bin represents a range of damage values
    /// and contains the count of iterations that fell into that range.
    public let damageHistogram: Histogram

    /// Histogram bins for kill distribution
    ///
    /// Used for visualization. Each bin represents a number of models killed
    /// and contains the count of iterations that killed that many models.
    public let killHistogram: Histogram

    // MARK: - Initialization

    public init(
        iterations: Int,
        damageResults: [Double],
        killResults: [Double],
        damageStatistics: SimulationStatistics,
        killStatistics: SimulationStatistics,
        probabilityOfAnyDamage: Double,
        probabilityOfAnyKills: Double,
        probabilityOfWipe: Double,
        damageHistogram: Histogram,
        killHistogram: Histogram
    ) {
        self.iterations = iterations
        self.damageResults = damageResults
        self.killResults = killResults
        self.damageStatistics = damageStatistics
        self.killStatistics = killStatistics
        self.probabilityOfAnyDamage = probabilityOfAnyDamage
        self.probabilityOfAnyKills = probabilityOfAnyKills
        self.probabilityOfWipe = probabilityOfWipe
        self.damageHistogram = damageHistogram
        self.killHistogram = killHistogram
    }
}

/// Statistical measures from simulation data
///
/// Provides comprehensive statistical analysis including central tendency,
/// spread, and percentiles.
public struct SimulationStatistics: Equatable, Codable {
    /// Average (arithmetic mean) value
    public let mean: Double

    /// Middle value when sorted (50th percentile)
    public let median: Double

    /// Most frequently occurring value
    ///
    /// For continuous data, this represents the mode of the histogram bins.
    public let mode: Double

    /// Standard deviation (measure of spread)
    ///
    /// Indicates how much variation exists from the mean.
    /// ~68% of values fall within ±1 std deviation of mean.
    public let standardDeviation: Double

    /// Minimum value observed
    public let minimum: Double

    /// Maximum value observed
    public let maximum: Double

    /// Value at 25th percentile (Q1)
    ///
    /// 25% of results were less than or equal to this value.
    public let percentile25: Double

    /// Value at 75th percentile (Q3)
    ///
    /// 75% of results were less than or equal to this value.
    public let percentile75: Double

    /// Value at 90th percentile
    ///
    /// 90% of results were less than or equal to this value.
    /// Useful for "best case" scenarios.
    public let percentile90: Double

    /// Value at 95th percentile
    ///
    /// 95% of results were less than or equal to this value.
    public let percentile95: Double

    /// Value at 99th percentile
    ///
    /// 99% of results were less than or equal to this value.
    public let percentile99: Double

    /// Interquartile range (Q3 - Q1)
    ///
    /// The middle 50% of data falls within this range.
    public var interquartileRange: Double {
        percentile75 - percentile25
    }

    /// Coefficient of variation (std dev / mean)
    ///
    /// Normalized measure of spread. Useful for comparing
    /// variability between different distributions.
    /// Returns 0 if mean is 0 to avoid division by zero.
    public var coefficientOfVariation: Double {
        guard mean > 0 else { return 0 }
        return standardDeviation / mean
    }

    public init(
        mean: Double,
        median: Double,
        mode: Double,
        standardDeviation: Double,
        minimum: Double,
        maximum: Double,
        percentile25: Double,
        percentile75: Double,
        percentile90: Double,
        percentile95: Double,
        percentile99: Double
    ) {
        self.mean = mean
        self.median = median
        self.mode = mode
        self.standardDeviation = standardDeviation
        self.minimum = minimum
        self.maximum = maximum
        self.percentile25 = percentile25
        self.percentile75 = percentile75
        self.percentile90 = percentile90
        self.percentile95 = percentile95
        self.percentile99 = percentile99
    }
}

/// Histogram data for visualization
///
/// Represents the distribution of results as a set of bins.
/// Each bin covers a range of values and contains a count of
/// how many results fell into that range.
public struct Histogram: Equatable, Codable {
    /// The bins that make up the histogram
    public let bins: [HistogramBin]

    /// Total count of all values across all bins
    public var totalCount: Int {
        bins.reduce(0) { $0 + $1.count }
    }

    /// Bin with the highest count (mode of distribution)
    public var peakBin: HistogramBin? {
        bins.max { $0.count < $1.count }
    }

    public init(bins: [HistogramBin]) {
        self.bins = bins
    }
}

/// A single bin in a histogram
///
/// Represents a range of values [lowerBound, upperBound) and
/// the count of data points that fell into that range.
public struct HistogramBin: Equatable, Codable {
    /// Lower bound of this bin (inclusive)
    public let lowerBound: Double

    /// Upper bound of this bin (exclusive)
    public let upperBound: Double

    /// Number of values that fell into this bin
    public let count: Int

    /// Midpoint of the bin for display purposes
    public var midpoint: Double {
        (lowerBound + upperBound) / 2.0
    }

    /// Width of the bin
    public var width: Double {
        upperBound - lowerBound
    }

    public init(lowerBound: Double, upperBound: Double, count: Int) {
        self.lowerBound = lowerBound
        self.upperBound = upperBound
        self.count = count
    }
}
