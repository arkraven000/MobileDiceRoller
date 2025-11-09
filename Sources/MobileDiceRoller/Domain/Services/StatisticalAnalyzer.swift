//
//  StatisticalAnalyzer.swift
//  MobileDiceRoller
//
//  Created on 2025-11-08.
//

import Foundation

/// Service for calculating statistical measures from numerical data
///
/// This implementation provides efficient algorithms for calculating
/// mean, median, mode, standard deviation, and percentiles from
/// simulation data.
///
/// ## Performance Considerations
/// - Mean calculation: O(n)
/// - Median/Percentile calculation: O(n log n) due to sorting
/// - Standard deviation: O(n)
/// - Mode calculation: O(n) for discrete data, O(n log n) for continuous
///
/// ## Usage
/// ```swift
/// let analyzer = StatisticalAnalyzer()
/// let data = [1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 9.0, 10.0]
/// let stats = analyzer.analyze(data)
/// print("Mean: \(stats.mean)")
/// print("Median: \(stats.median)")
/// print("Std Dev: \(stats.standardDeviation)")
/// ```
public final class StatisticalAnalyzer: StatisticalAnalyzing {
    // MARK: - Initialization

    public init() {}

    // MARK: - Mean Calculation

    /// Calculates the arithmetic mean of the data
    ///
    /// Formula: sum(values) / count
    ///
    /// - Parameter data: Array of numerical values
    /// - Returns: Mean value, or 0.0 if array is empty
    public func calculateMean(_ data: [Double]) -> Double {
        guard !data.isEmpty else { return 0.0 }

        let sum = data.reduce(0.0, +)
        return sum / Double(data.count)
    }

    // MARK: - Median Calculation

    /// Calculates the median (50th percentile) of the data
    ///
    /// The median is the middle value when data is sorted.
    /// For even-length arrays, returns the average of the two middle values.
    ///
    /// - Parameter data: Array of numerical values
    /// - Returns: Median value, or 0.0 if array is empty
    public func calculateMedian(_ data: [Double]) -> Double {
        guard !data.isEmpty else { return 0.0 }

        let sorted = data.sorted()
        let count = sorted.count

        if count % 2 == 0 {
            // Even number of elements: average the two middle values
            let mid1 = sorted[count / 2 - 1]
            let mid2 = sorted[count / 2]
            return (mid1 + mid2) / 2.0
        } else {
            // Odd number of elements: return the middle value
            return sorted[count / 2]
        }
    }

    // MARK: - Mode Calculation

    /// Calculates the mode (most frequent value) of the data
    ///
    /// For discrete data (integers), finds the most frequently occurring value.
    /// For continuous data (floating point), groups values into bins and
    /// finds the midpoint of the most frequent bin.
    ///
    /// - Parameter data: Array of numerical values
    /// - Returns: Mode value, or 0.0 if array is empty
    public func calculateMode(_ data: [Double]) -> Double {
        guard !data.isEmpty else { return 0.0 }

        // Check if data appears to be discrete (all integers)
        let isDiscrete = data.allSatisfy { $0 == $0.rounded() }

        if isDiscrete {
            // For discrete data, find the most frequent value
            var frequencies: [Double: Int] = [:]
            for value in data {
                frequencies[value, default: 0] += 1
            }

            let mostFrequent = frequencies.max { $0.value < $1.value }
            return mostFrequent?.key ?? 0.0
        } else {
            // For continuous data, use histogram bins
            let histogram = createHistogram(from: data, binCount: 20)
            return histogram.peakBin?.midpoint ?? 0.0
        }
    }

    // MARK: - Standard Deviation Calculation

    /// Calculates the sample standard deviation of the data
    ///
    /// Formula: sqrt(sum((x - mean)^2) / (n - 1))
    ///
    /// Uses the sample standard deviation (n-1 divisor) rather than
    /// population standard deviation (n divisor) as this is more
    /// appropriate for simulation data.
    ///
    /// - Parameter data: Array of numerical values
    /// - Returns: Standard deviation, or 0.0 if array has fewer than 2 elements
    public func calculateStandardDeviation(_ data: [Double]) -> Double {
        guard data.count >= 2 else { return 0.0 }

        let mean = calculateMean(data)
        let squaredDeviations = data.map { pow($0 - mean, 2) }
        let variance = squaredDeviations.reduce(0.0, +) / Double(data.count - 1)
        return sqrt(variance)
    }

    // MARK: - Percentile Calculation

    /// Calculates a specific percentile of the data
    ///
    /// Uses linear interpolation between values when the percentile
    /// falls between two data points.
    ///
    /// - Parameters:
    ///   - data: Array of numerical values
    ///   - percentile: Percentile to calculate (0.0 to 1.0)
    /// - Returns: Value at the specified percentile, or 0.0 if array is empty
    ///
    /// ## Examples
    /// ```swift
    /// let data = [1.0, 2.0, 3.0, 4.0, 5.0]
    /// analyzer.calculatePercentile(data, percentile: 0.5)  // Returns 3.0 (median)
    /// analyzer.calculatePercentile(data, percentile: 0.25) // Returns 2.0 (Q1)
    /// analyzer.calculatePercentile(data, percentile: 0.75) // Returns 4.0 (Q3)
    /// ```
    public func calculatePercentile(_ data: [Double], percentile: Double) -> Double {
        guard !data.isEmpty else { return 0.0 }
        guard percentile >= 0.0 && percentile <= 1.0 else { return 0.0 }

        let sorted = data.sorted()
        let count = sorted.count

        // Handle edge cases
        if percentile == 0.0 { return sorted.first ?? 0.0 }
        if percentile == 1.0 { return sorted.last ?? 0.0 }

        // Calculate the index (0-based)
        let index = percentile * Double(count - 1)
        let lowerIndex = Int(index)
        let upperIndex = min(lowerIndex + 1, count - 1)

        // Linear interpolation between the two surrounding values
        let lowerValue = sorted[lowerIndex]
        let upperValue = sorted[upperIndex]
        let fraction = index - Double(lowerIndex)

        return lowerValue + fraction * (upperValue - lowerValue)
    }

    // MARK: - Histogram Generation

    /// Creates a histogram from the data
    ///
    /// - Parameters:
    ///   - data: Array of numerical values
    ///   - binCount: Number of bins to create (default: 20)
    /// - Returns: Histogram with the specified number of bins
    func createHistogram(from data: [Double], binCount: Int = 20) -> Histogram {
        guard !data.isEmpty else {
            return Histogram(bins: [])
        }

        let min = data.min() ?? 0.0
        let max = data.max() ?? 0.0

        // Handle case where all values are the same
        guard min < max else {
            let bin = HistogramBin(lowerBound: min, upperBound: min + 1, count: data.count)
            return Histogram(bins: [bin])
        }

        // Calculate bin width
        let binWidth = (max - min) / Double(binCount)

        // Create bins
        var bins: [HistogramBin] = []
        for i in 0..<binCount {
            let lowerBound = min + Double(i) * binWidth
            let upperBound = min + Double(i + 1) * binWidth

            // Count values in this bin
            let count = data.filter { value in
                if i == binCount - 1 {
                    // Last bin includes upper bound
                    return value >= lowerBound && value <= upperBound
                } else {
                    return value >= lowerBound && value < upperBound
                }
            }.count

            bins.append(HistogramBin(
                lowerBound: lowerBound,
                upperBound: upperBound,
                count: count
            ))
        }

        return Histogram(bins: bins)
    }
}
