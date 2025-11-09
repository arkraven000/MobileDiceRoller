//
//  ResultsView.swift
//  MobileDiceRoller
//
//  Created on 2025-11-08.
//

import SwiftUI

/// Results display view for combat calculations
///
/// Implements lazy loading for performance with large result sets
struct ResultsView: View {
    let result: CombatResult

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Results")
                .font(.title2.bold())

            // Expected Values
            LazyVStack(spacing: 12) {
                ResultRow(label: "Expected Hits", value: result.expectedHits, format: ".2f")
                ResultRow(label: "Expected Wounds", value: result.expectedWounds, format: ".2f")
                ResultRow(label: "Expected Unsaved Wounds", value: result.expectedUnsavedWounds, format: ".2f")
                ResultRow(label: "Expected Damage", value: result.expectedDamage, format: ".2f")
                ResultRow(label: "Expected Models Killed", value: result.expectedModelsKilled, format: ".2f")
            }

            Divider()

            // Probabilities
            LazyVStack(spacing: 12) {
                ProbabilityRow(label: "Hit Probability", value: result.hitProbability)
                ProbabilityRow(label: "Wound Probability", value: result.woundProbability)
                ProbabilityRow(label: "Save Fail Probability", value: result.saveFailProbability)
                ProbabilityRow(label: "Kill Probability", value: result.killProbability)
            }

            Divider()

            // Efficiency Metrics
            LazyVStack(spacing: 12) {
                ResultRow(label: "Kill Efficiency", value: result.overallKillEfficiency * 100, format: ".1f", suffix: "%")
                ResultRow(label: "Avg Wounds/Hit", value: result.averageWoundsPerHit, format: ".2f")
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}

// MARK: - Subcomponents

private struct ResultRow: View {
    let label: String
    let value: Double
    let format: String
    var suffix: String = ""

    var body: some View {
        HStack {
            Text(label)
                .foregroundStyle(.secondary)
            Spacer()
            Text(String(format: "%\(format)\(suffix)", value))
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
            HStack(spacing: 8) {
                Text(String(format: "%.1f%%", value * 100))
                    .font(.system(.body, design: .monospaced))
                    .fontWeight(.semibold)

                // Visual bar
                GeometryReader { geometry in
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.blue.opacity(0.3))
                        .frame(width: geometry.size.width * value)
                }
                .frame(width: 60, height: 8)
            }
        }
    }
}

#Preview {
    ResultsView(result: CombatResult(
        expectedHits: 1.33,
        expectedWounds: 0.67,
        expectedUnsavedWounds: 0.33,
        expectedDamage: 0.33,
        expectedModelsKilled: 0.17,
        hitProbability: 0.67,
        woundProbability: 0.5,
        saveFailProbability: 0.5,
        killProbability: 0.17
    ))
    .padding()
}
