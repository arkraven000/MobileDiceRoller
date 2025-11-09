//
//  CalculatorView.swift
//  MobileDiceRoller
//
//  Created on 2025-11-08.
//

import SwiftUI

/// Main calculator view for probability calculations
///
/// This view implements performance optimizations:
/// - Minimal view hierarchy for fast rendering
/// - Extracted subviews to minimize body re-evaluation
/// - Real-time form validation
/// - Cached computed values using @State
struct CalculatorView: View {
    // MARK: - Properties

    @Bindable var viewModel: CalculatorViewModel

    // MARK: - Body

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Weapon Section
                    WeaponInputSection(
                        weapon: viewModel.weapon,
                        onWeaponSelected: { viewModel.updateWeapon($0) }
                    )

                    // Defender Section
                    DefenderInputSection(
                        defender: viewModel.defender,
                        onDefenderSelected: { viewModel.updateDefender($0) }
                    )

                    // Options Section
                    OptionsSection(
                        range: viewModel.range,
                        defenderHasCover: viewModel.defenderHasCover,
                        onRangeChanged: { viewModel.updateRange($0) },
                        onCoverChanged: { viewModel.updateDefenderHasCover($0) }
                    )

                    // Calculate Button
                    CalculateButton(
                        isEnabled: viewModel.canCalculate,
                        isCalculating: viewModel.isCalculating,
                        action: { viewModel.calculate() }
                    )

                    // Results Section
                    if let result = viewModel.result {
                        ResultsView(result: result)
                    }

                    // Error Message
                    if let error = viewModel.errorMessage {
                        ErrorView(message: error)
                    }
                }
                .padding()
            }
            .navigationTitle("Dice Calculator")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Reset") {
                        viewModel.reset()
                    }
                }
            }
        }
    }
}

// MARK: - Subviews

/// Weapon input section (extracted to minimize re-evaluation)
private struct WeaponInputSection: View {
    let weapon: Weapon?
    let onWeaponSelected: (Weapon) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Weapon")
                .font(.headline)

            if let weapon = weapon {
                WeaponSummaryCard(weapon: weapon)
            } else {
                Button("Select Weapon") {
                    // Navigate to weapon picker
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

/// Defender input section
private struct DefenderInputSection: View {
    let defender: Defender?
    let onDefenderSelected: (Defender) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Defender")
                .font(.headline)

            if let defender = defender {
                DefenderSummaryCard(defender: defender)
            } else {
                Button("Select Defender") {
                    // Navigate to defender picker
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

/// Options section
private struct OptionsSection: View {
    let range: Int?
    let defenderHasCover: Bool
    let onRangeChanged: (Int?) -> Void
    let onCoverChanged: (Bool) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Options")
                .font(.headline)

            // Range input
            HStack {
                Text("Range:")
                Spacer()
                TextField("inches", value: Binding(
                    get: { range ?? 0 },
                    set: { onRangeChanged($0 > 0 ? $0 : nil) }
                ), format: .number)
                .textFieldStyle(.roundedBorder)
                .frame(width: 80)
                .keyboardType(.numberPad)
            }

            // Cover toggle
            Toggle("Defender has cover", isOn: Binding(
                get: { defenderHasCover },
                set: { onCoverChanged($0) }
            ))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

/// Calculate button
private struct CalculateButton: View {
    let isEnabled: Bool
    let isCalculating: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                if isCalculating {
                    ProgressView()
                        .progressViewStyle(.circular)
                        .tint(.white)
                }
                Text(isCalculating ? "Calculating..." : "Calculate")
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.borderedProminent)
        .disabled(!isEnabled)
    }
}

/// Error display view
private struct ErrorView: View {
    let message: String

    var body: some View {
        HStack {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundStyle(.red)
            Text(message)
                .foregroundStyle(.red)
        }
        .padding()
        .background(Color.red.opacity(0.1))
        .cornerRadius(8)
    }
}

// MARK: - Preview

#Preview {
    CalculatorView(
        viewModel: CalculatorViewModel(
            probabilityEngine: ProbabilityEngine(),
            abilityProcessor: AbilityProcessor()
        )
    )
}
