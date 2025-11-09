//
//  SimulationResultsView.swift
//  MobileDiceRoller
//
//  Created on 2025-11-08.
//

import SwiftUI
import Charts

/// Simulation results view with charts and statistics
///
/// Features:
/// - Progress indicators during simulation
/// - Histogram charts using Swift Charts
/// - Statistical summary
/// - Data sampling for large datasets (performance optimization)
struct SimulationResultsView: View {
    let result: SimulationResult
    let isRunning: Bool
    let progress: Double

    // Optimize chart rendering by sampling large datasets
    private var sampledDamageData: [(bin: HistogramBin, index: Int)] {
        let bins = Array(result.damageHistogram.bins.enumerated())
        if bins.count > 50 {
            // Sample every nth bin to keep chart performant
            let step = bins.count / 50
            return bins.enumerated().compactMap { index, element in
                index % step == 0 ? element : nil
            }
        }
        return bins
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Progress indicator
                if isRunning {
                    ProgressSection(progress: progress)
                }

                // Summary Statistics
                StatisticsSummarySection(result: result)

                // Damage Histogram
                DamageHistogramSection(bins: sampledDamageData)

                // Kill Histogram
                KillHistogramSection(histogram: result.killHistogram)

                // Probabilities
                ProbabilitiesSection(result: result)
            }
            .padding()
        }
        .navigationTitle("Simulation Results")
    }
}

// MARK: - Subviews

private struct ProgressSection: View {
    let progress: Double

    var body: some View {
        VStack(spacing: 12) {
            Text("Running simulation...")
                .font(.headline)

            ProgressView(value: progress) {
                Text("\(Int(progress * 100))%")
                    .font(.caption)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

private struct StatisticsSummarySection: View {
    let result: SimulationResult

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Statistics (\(result.iterations) iterations)")
                .font(.title2.bold())

            VStack(spacing: 8) {
                StatRow(label: "Mean Damage", value: result.damageStatistics.mean)
                StatRow(label: "Median Damage", value: result.damageStatistics.median)
                StatRow(label: "Std Dev", value: result.damageStatistics.standardDeviation)
                StatRow(label: "Min-Max", value: "\(String(format: "%.1f", result.damageStatistics.minimum)) - \(String(format: "%.1f", result.damageStatistics.maximum))")
            }
        }
    }
}

private struct DamageHistogramSection: View {
    let bins: [(bin: HistogramBin, index: Int)]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Damage Distribution")
                .font(.title3.bold())

            Chart(bins, id: \.index) { element in
                BarMark(
                    x: .value("Damage", element.bin.midpoint),
                    y: .value("Frequency", element.bin.count)
                )
                .foregroundStyle(.blue.gradient)
            }
            .frame(height: 200)
            .chartXAxis {
                AxisMarks(position: .bottom)
            }
            .chartYAxis {
                AxisMarks(position: .leading)
            }
        }
    }
}

private struct KillHistogramSection: View {
    let histogram: Histogram

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Models Killed Distribution")
                .font(.title3.bold())

            Chart(Array(histogram.bins.enumerated()), id: \.offset) { index, bin in
                BarMark(
                    x: .value("Models", bin.midpoint),
                    y: .value("Frequency", bin.count)
                )
                .foregroundStyle(.red.gradient)
            }
            .frame(height: 200)
        }
    }
}

private struct ProbabilitiesSection: View {
    let result: SimulationResult

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Probabilities")
                .font(.title3.bold())

            VStack(spacing: 8) {
                ProbabilityRow(label: "Any Damage", value: result.probabilityOfAnyDamage)
                ProbabilityRow(label: "Any Kills", value: result.probabilityOfAnyKills)
                ProbabilityRow(label: "Unit Wipe", value: result.probabilityOfWipe)
            }
        }
    }
}

// MARK: - Helper Views

private struct StatRow: View {
    let label: String
    let value: Double

    init(label: String, value: Double) {
        self.label = label
        self.value = value
    }

    init(label: String, value: String) {
        self.label = label
        self.value = 0
        self.stringValue = value
    }

    private let stringValue: String?

    var body: some View {
        HStack {
            Text(label)
                .foregroundStyle(.secondary)
            Spacer()
            Text(stringValue ?? String(format: "%.2f", value))
                .font(.system(.body, design: .monospaced))
                .fontWeight(.semibold)
        }
    }
}

private struct ProbabilityRow: View {
    let label: String
    let value: Double

    var body: some View {
        HStack {
            Text(label)
                .foregroundStyle(.secondary)
            Spacer()
            Text(String(format: "%.1f%%", value * 100))
                .font(.system(.body, design: .monospaced))
                .fontWeight(.semibold)
        }
    }
}
