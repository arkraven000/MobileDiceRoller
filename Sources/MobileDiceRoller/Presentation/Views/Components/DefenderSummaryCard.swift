//
//  DefenderSummaryCard.swift
//  MobileDiceRoller
//
//  Created on 2025-11-08.
//

import SwiftUI

/// Reusable card component for displaying defender summary
struct DefenderSummaryCard: View {
    let defender: Defender

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Name
            Text(defender.name)
                .font(.title3.bold())

            // Stats
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 8) {
                StatItem(label: "Toughness", value: "\(defender.toughness)")
                StatItem(label: "Save", value: "\(defender.save)+")
                StatItem(label: "Wounds", value: "\(defender.wounds)")
                if let invuln = defender.invulnerableSave {
                    StatItem(label: "Invuln", value: "\(invuln)++")
                }
                if let fnp = defender.feelNoPain {
                    StatItem(label: "FNP", value: "\(fnp)+++")
                }
                StatItem(label: "Models", value: "\(defender.modelCount)")
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

private struct StatItem: View {
    let label: String
    let value: String

    var body: some View {
        VStack(spacing: 2) {
            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.caption.bold())
        }
    }
}

#Preview {
    DefenderSummaryCard(defender: Defender.spaceMarine())
        .padding()
}
