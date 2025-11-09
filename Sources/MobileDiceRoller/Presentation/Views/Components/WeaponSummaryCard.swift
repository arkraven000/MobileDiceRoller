//
//  WeaponSummaryCard.swift
//  MobileDiceRoller
//
//  Created on 2025-11-08.
//

import SwiftUI

/// Reusable card component for displaying weapon summary
///
/// This component follows component-driven design principles:
/// - Self-contained and reusable
/// - Minimal dependencies
/// - Clear interface
struct WeaponSummaryCard: View {
    let weapon: Weapon

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Name
            Text(weapon.name)
                .font(.title3.bold())

            // Stats
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 8) {
                StatItem(label: "Attacks", value: "\(weapon.attacks)")
                StatItem(label: "Skill", value: "\(weapon.skill)+")
                StatItem(label: "Strength", value: "\(weapon.strength)")
                StatItem(label: "AP", value: "\(weapon.armorPenetration)")
                StatItem(label: "Damage", value: weapon.damage)
                if let range = weapon.range {
                    StatItem(label: "Range", value: "\(range)\"")
                }
            }

            // Abilities
            if !weapon.abilities.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Abilities:")
                        .font(.caption.bold())
                    ForEach(weapon.abilities, id: \.self) { ability in
                        Text("• \(ability.displayName)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

/// Single stat item
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

// MARK: - WeaponAbility Extension

extension WeaponAbility {
    var displayName: String {
        switch self {
        case .lethalHits:
            return "Lethal Hits"
        case .sustainedHits(let value):
            return "Sustained Hits \(value)"
        case .devastatingWounds:
            return "Devastating Wounds"
        case .anti(let keyword):
            return "Anti-\(keyword)"
        case .torrent:
            return "Torrent"
        case .twinLinked:
            return "Twin-Linked"
        case .melta(let value):
            return "Melta \(value)"
        case .rapidFire(let value):
            return "Rapid Fire \(value)"
        case .blast:
            return "Blast"
        case .ignoresCover:
            return "Ignores Cover"
        case .precision:
            return "Precision"
        case .hazardous:
            return "Hazardous"
        }
    }
}

// MARK: - Preview

#Preview {
    WeaponSummaryCard(weapon: Weapon.boltRifle())
        .padding()
}
