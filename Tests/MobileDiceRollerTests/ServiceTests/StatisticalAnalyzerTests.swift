//
//  StatisticalAnalyzerTests.swift
//  MobileDiceRollerTests
//
//  Created on 2025-11-08.
//

import XCTest
@testable import MobileDiceRoller

/// Tests for the StatisticalAnalyzer service
///
/// These tests verify that all statistical calculations are mathematically
/// correct and handle edge cases properly.
final class StatisticalAnalyzerTests: XCTestCase {
    // MARK: - System Under Test

    var sut: StatisticalAnalyzing!

    // MARK: - Setup & Teardown

    override func setUp() {
        super.setUp()
        sut = StatisticalAnalyzer()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    // MARK: - Mean Tests

    func testCalculateMean_WithValidData_ReturnsCorrectMean() {
        // Given
        let data = [1.0, 2.0, 3.0, 4.0, 5.0]

        // When
        let mean = sut.calculateMean(data)

        // Then
        XCTAssertEqual(mean, 3.0, accuracy: 0.001)
    }

    func testCalculateMean_WithEmptyArray_ReturnsZero() {
        // Given
        let data: [Double] = []

        // When
        let mean = sut.calculateMean(data)

        // Then
        XCTAssertEqual(mean, 0.0)
    }

    func testCalculateMean_WithSingleValue_ReturnsThatValue() {
        // Given
        let data = [42.0]

        // When
        let mean = sut.calculateMean(data)

        // Then
        XCTAssertEqual(mean, 42.0)
    }

    func testCalculateMean_WithDecimalValues_ReturnsCorrectMean() {
        // Given
        let data = [1.5, 2.5, 3.5, 4.5]

        // When
        let mean = sut.calculateMean(data)

        // Then
        XCTAssertEqual(mean, 3.0, accuracy: 0.001)
    }

    // MARK: - Median Tests

    func testCalculateMedian_WithOddNumberOfValues_ReturnsMiddleValue() {
        // Given
        let data = [1.0, 3.0, 5.0, 7.0, 9.0]

        // When
        let median = sut.calculateMedian(data)

        // Then
        XCTAssertEqual(median, 5.0)
    }

    func testCalculateMedian_WithEvenNumberOfValues_ReturnsAverageOfMiddleTwo() {
        // Given
        let data = [1.0, 2.0, 3.0, 4.0]

        // When
        let median = sut.calculateMedian(data)

        // Then
        XCTAssertEqual(median, 2.5)
    }

    func testCalculateMedian_WithUnsortedData_ReturnsCorrectMedian() {
        // Given
        let data = [5.0, 1.0, 9.0, 3.0, 7.0]

        // When
        let median = sut.calculateMedian(data)

        // Then
        XCTAssertEqual(median, 5.0)
    }

    func testCalculateMedian_WithEmptyArray_ReturnsZero() {
        // Given
        let data: [Double] = []

        // When
        let median = sut.calculateMedian(data)

        // Then
        XCTAssertEqual(median, 0.0)
    }

    func testCalculateMedian_WithSingleValue_ReturnsThatValue() {
        // Given
        let data = [42.0]

        // When
        let median = sut.calculateMedian(data)

        // Then
        XCTAssertEqual(median, 42.0)
    }

    // MARK: - Mode Tests

    func testCalculateMode_WithDiscreteData_ReturnsMostFrequentValue() {
        // Given - 3.0 appears 3 times, others appear once or twice
        let data = [1.0, 2.0, 3.0, 3.0, 3.0, 4.0, 4.0, 5.0]

        // When
        let mode = sut.calculateMode(data)

        // Then
        XCTAssertEqual(mode, 3.0)
    }

    func testCalculateMode_WithContinuousData_ReturnsHistogramPeak() {
        // Given - values clustered around 5.0
        let data = [1.5, 2.3, 4.8, 5.0, 5.1, 5.2, 5.3, 7.9]

        // When
        let mode = sut.calculateMode(data)

        // Then - should be close to 5.0 (the cluster center)
        XCTAssertGreaterThan(mode, 4.0)
        XCTAssertLessThan(mode, 6.0)
    }

    func testCalculateMode_WithEmptyArray_ReturnsZero() {
        // Given
        let data: [Double] = []

        // When
        let mode = sut.calculateMode(data)

        // Then
        XCTAssertEqual(mode, 0.0)
    }

    // MARK: - Standard Deviation Tests

    func testCalculateStandardDeviation_WithValidData_ReturnsCorrectValue() {
        // Given - simple dataset with known std dev
        let data = [2.0, 4.0, 4.0, 4.0, 5.0, 5.0, 7.0, 9.0]
        // Mean = 5.0, variance ≈ 4.0, std dev ≈ 2.0

        // When
        let stdDev = sut.calculateStandardDeviation(data)

        // Then
        XCTAssertEqual(stdDev, 2.0, accuracy: 0.1)
    }

    func testCalculateStandardDeviation_WithIdenticalValues_ReturnsZero() {
        // Given
        let data = [5.0, 5.0, 5.0, 5.0, 5.0]

        // When
        let stdDev = sut.calculateStandardDeviation(data)

        // Then
        XCTAssertEqual(stdDev, 0.0, accuracy: 0.001)
    }

    func testCalculateStandardDeviation_WithEmptyArray_ReturnsZero() {
        // Given
        let data: [Double] = []

        // When
        let stdDev = sut.calculateStandardDeviation(data)

        // Then
        XCTAssertEqual(stdDev, 0.0)
    }

    func testCalculateStandardDeviation_WithSingleValue_ReturnsZero() {
        // Given
        let data = [42.0]

        // When
        let stdDev = sut.calculateStandardDeviation(data)

        // Then
        XCTAssertEqual(stdDev, 0.0)
    }

    // MARK: - Percentile Tests

    func testCalculatePercentile_50thPercentile_EqualsMedian() {
        // Given
        let data = [1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 9.0, 10.0]

        // When
        let percentile50 = sut.calculatePercentile(data, percentile: 0.5)
        let median = sut.calculateMedian(data)

        // Then
        XCTAssertEqual(percentile50, median, accuracy: 0.001)
    }

    func testCalculatePercentile_0thPercentile_EqualsMinimum() {
        // Given
        let data = [5.0, 2.0, 9.0, 1.0, 7.0]

        // When
        let percentile0 = sut.calculatePercentile(data, percentile: 0.0)

        // Then
        XCTAssertEqual(percentile0, 1.0)
    }

    func testCalculatePercentile_100thPercentile_EqualsMaximum() {
        // Given
        let data = [5.0, 2.0, 9.0, 1.0, 7.0]

        // When
        let percentile100 = sut.calculatePercentile(data, percentile: 1.0)

        // Then
        XCTAssertEqual(percentile100, 9.0)
    }

    func testCalculatePercentile_25thPercentile_ReturnsFirstQuartile() {
        // Given
        let data = [1.0, 2.0, 3.0, 4.0, 5.0]

        // When
        let percentile25 = sut.calculatePercentile(data, percentile: 0.25)

        // Then - Q1 should be 2.0
        XCTAssertEqual(percentile25, 2.0, accuracy: 0.1)
    }

    func testCalculatePercentile_75thPercentile_ReturnsThirdQuartile() {
        // Given
        let data = [1.0, 2.0, 3.0, 4.0, 5.0]

        // When
        let percentile75 = sut.calculatePercentile(data, percentile: 0.75)

        // Then - Q3 should be 4.0
        XCTAssertEqual(percentile75, 4.0, accuracy: 0.1)
    }

    func testCalculatePercentile_WithEmptyArray_ReturnsZero() {
        // Given
        let data: [Double] = []

        // When
        let percentile = sut.calculatePercentile(data, percentile: 0.5)

        // Then
        XCTAssertEqual(percentile, 0.0)
    }

    // MARK: - Full Analysis Tests

    func testAnalyze_WithValidData_ReturnsCompleteStatistics() {
        // Given
        let data = [1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 9.0, 10.0]

        // When
        let stats = sut.analyze(data)

        // Then
        XCTAssertEqual(stats.mean, 5.5, accuracy: 0.001)
        XCTAssertEqual(stats.median, 5.5, accuracy: 0.001)
        XCTAssertEqual(stats.minimum, 1.0)
        XCTAssertEqual(stats.maximum, 10.0)
        XCTAssertGreaterThan(stats.standardDeviation, 0)
    }

    func testAnalyze_WithEmptyArray_ReturnsZeroStatistics() {
        // Given
        let data: [Double] = []

        // When
        let stats = sut.analyze(data)

        // Then
        XCTAssertEqual(stats.mean, 0.0)
        XCTAssertEqual(stats.median, 0.0)
        XCTAssertEqual(stats.mode, 0.0)
        XCTAssertEqual(stats.standardDeviation, 0.0)
        XCTAssertEqual(stats.minimum, 0.0)
        XCTAssertEqual(stats.maximum, 0.0)
    }

    func testAnalyze_WithSimulationData_ReturnsRealisticStatistics() {
        // Given - simulate 100 dice rolls (D6)
        let data = (1...100).map { _ in Double.random(in: 1...6) }

        // When
        let stats = sut.analyze(data)

        // Then - mean should be close to 3.5, stddev close to 1.7
        XCTAssertGreaterThan(stats.mean, 2.5)
        XCTAssertLessThan(stats.mean, 4.5)
        XCTAssertGreaterThan(stats.standardDeviation, 0.5)
        XCTAssertLessThan(stats.standardDeviation, 2.5)
    }

    // MARK: - Histogram Tests

    func testCreateHistogram_WithValidData_CreatesCorrectBins() {
        // Given
        let data = [1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 9.0, 10.0]

        // When
        let histogram = sut.createHistogram(from: data, binCount: 5)

        // Then
        XCTAssertEqual(histogram.bins.count, 5)
        XCTAssertEqual(histogram.totalCount, 10)
    }

    func testCreateHistogram_WithIdenticalValues_CreatesSingleBin() {
        // Given
        let data = [5.0, 5.0, 5.0, 5.0, 5.0]

        // When
        let histogram = sut.createHistogram(from: data, binCount: 10)

        // Then
        XCTAssertEqual(histogram.bins.count, 1)
        XCTAssertEqual(histogram.bins.first?.count, 5)
    }

    func testCreateHistogram_WithEmptyArray_ReturnsEmptyHistogram() {
        // Given
        let data: [Double] = []

        // When
        let histogram = sut.createHistogram(from: data, binCount: 10)

        // Then
        XCTAssertEqual(histogram.bins.count, 0)
        XCTAssertEqual(histogram.totalCount, 0)
    }

    func testCreateHistogram_PeakBin_ReturnsHighestFrequencyBin() {
        // Given - values clustered around 5
        let data = [1.0, 5.0, 5.0, 5.0, 5.0, 5.0, 9.0]

        // When
        let histogram = sut.createHistogram(from: data, binCount: 3)

        // Then
        let peakBin = histogram.peakBin
        XCTAssertNotNil(peakBin)
        XCTAssertEqual(peakBin?.count, 5)
    }

    // MARK: - SimulationStatistics Computed Properties Tests

    func testSimulationStatistics_InterquartileRange_CalculatesCorrectly() {
        // Given
        let stats = SimulationStatistics(
            mean: 5.0,
            median: 5.0,
            mode: 5.0,
            standardDeviation: 2.0,
            minimum: 1.0,
            maximum: 10.0,
            percentile25: 3.0,
            percentile75: 7.0,
            percentile90: 8.5,
            percentile95: 9.0,
            percentile99: 9.5
        )

        // When
        let iqr = stats.interquartileRange

        // Then
        XCTAssertEqual(iqr, 4.0)
    }

    func testSimulationStatistics_CoefficientOfVariation_CalculatesCorrectly() {
        // Given
        let stats = SimulationStatistics(
            mean: 10.0,
            median: 10.0,
            mode: 10.0,
            standardDeviation: 2.0,
            minimum: 5.0,
            maximum: 15.0,
            percentile25: 8.0,
            percentile75: 12.0,
            percentile90: 13.0,
            percentile95: 14.0,
            percentile99: 14.5
        )

        // When
        let cv = stats.coefficientOfVariation

        // Then
        XCTAssertEqual(cv, 0.2, accuracy: 0.001)
    }

    func testSimulationStatistics_CoefficientOfVariation_WithZeroMean_ReturnsZero() {
        // Given
        let stats = SimulationStatistics(
            mean: 0.0,
            median: 0.0,
            mode: 0.0,
            standardDeviation: 0.0,
            minimum: 0.0,
            maximum: 0.0,
            percentile25: 0.0,
            percentile75: 0.0,
            percentile90: 0.0,
            percentile95: 0.0,
            percentile99: 0.0
        )

        // When
        let cv = stats.coefficientOfVariation

        // Then
        XCTAssertEqual(cv, 0.0)
    }
}
