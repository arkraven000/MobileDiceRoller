//
//  StatisticalAnalyzing.swift
//  MobileDiceRoller
//
//  Created on 2025-11-08.
//

import Foundation

/// Protocol for statistical analysis of simulation data
///
/// This protocol defines the interface for calculating statistical measures
/// from arrays of numerical data. It provides methods for calculating
/// central tendency (mean, median, mode), spread (standard deviation),
/// and percentiles.
///
/// ## Usage
/// ```swift
/// let analyzer: StatisticalAnalyzing = StatisticalAnalyzer()
/// let data = [1.0, 2.0, 3.0, 4.0, 5.0]
/// let stats = analyzer.analyze(data)
/// print("Mean: \(stats.mean), StdDev: \(stats.standardDeviation)")
/// ```
public protocol StatisticalAnalyzing {
    /// Analyzes an array of data and returns comprehensive statistics
    ///
    /// - Parameter data: Array of numerical values to analyze
    /// - Returns: Statistical measures including mean, median, std dev, and percentiles
    ///
    /// ## Example
    /// ```swift
    /// let damageResults = [0.0, 2.0, 3.0, 1.0, 4.0, 2.0, 3.0]
    /// let stats = analyzer.analyze(damageResults)
    /// ```
    func analyze(_ data: [Double]) -> SimulationStatistics

    /// Calculates the arithmetic mean (average) of the data
    ///
    /// - Parameter data: Array of numerical values
    /// - Returns: Mean value, or 0.0 if array is empty
    func calculateMean(_ data: [Double]) -> Double

    /// Calculates the median (middle value) of the data
    ///
    /// - Parameter data: Array of numerical values
    /// - Returns: Median value, or 0.0 if array is empty
    func calculateMedian(_ data: [Double]) -> Double

    /// Calculates the mode (most frequent value) of the data
    ///
    /// For continuous data, this returns the midpoint of the most
    /// frequent histogram bin.
    ///
    /// - Parameter data: Array of numerical values
    /// - Returns: Mode value, or 0.0 if array is empty
    func calculateMode(_ data: [Double]) -> Double

    /// Calculates the standard deviation of the data
    ///
    /// Uses the sample standard deviation formula (n-1 divisor).
    ///
    /// - Parameter data: Array of numerical values
    /// - Returns: Standard deviation, or 0.0 if array has fewer than 2 elements
    func calculateStandardDeviation(_ data: [Double]) -> Double

    /// Calculates a specific percentile of the data
    ///
    /// - Parameters:
    ///   - data: Array of numerical values
    ///   - percentile: Percentile to calculate (0.0 to 1.0, e.g., 0.95 for 95th percentile)
    /// - Returns: Value at the specified percentile, or 0.0 if array is empty
    func calculatePercentile(_ data: [Double], percentile: Double) -> Double
}

// MARK: - Default Implementations

public extension StatisticalAnalyzing {
    /// Analyzes data and returns comprehensive statistics
    func analyze(_ data: [Double]) -> SimulationStatistics {
        guard !data.isEmpty else {
            return SimulationStatistics(
                mean: 0,
                median: 0,
                mode: 0,
                standardDeviation: 0,
                minimum: 0,
                maximum: 0,
                percentile25: 0,
                percentile75: 0,
                percentile90: 0,
                percentile95: 0,
                percentile99: 0
            )
        }

        return SimulationStatistics(
            mean: calculateMean(data),
            median: calculateMedian(data),
            mode: calculateMode(data),
            standardDeviation: calculateStandardDeviation(data),
            minimum: data.min() ?? 0,
            maximum: data.max() ?? 0,
            percentile25: calculatePercentile(data, percentile: 0.25),
            percentile75: calculatePercentile(data, percentile: 0.75),
            percentile90: calculatePercentile(data, percentile: 0.90),
            percentile95: calculatePercentile(data, percentile: 0.95),
            percentile99: calculatePercentile(data, percentile: 0.99)
        )
    }
}
