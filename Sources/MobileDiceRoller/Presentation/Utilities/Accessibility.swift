//
//  Accessibility.swift
//  MobileDiceRoller
//
//  Created on 2025-11-08.
//

import SwiftUI

// MARK: - Accessibility Identifiers

/// Standard accessibility identifiers for UI testing and VoiceOver
enum AccessibilityID {
    // MARK: - Calculator Screen
    static let calculatorView = "calculator_view"
    static let weaponSelectionButton = "weapon_selection_button"
    static let defenderSelectionButton = "defender_selection_button"
    static let calculateButton = "calculate_button"
    static let resetButton = "reset_button"
    static let resultsSection = "results_section"

    // MARK: - Simulation Screen
    static let simulationView = "simulation_view"
    static let iterationsField = "iterations_field"
    static let runSimulationButton = "run_simulation_button"
    static let cancelSimulationButton = "cancel_simulation_button"
    static let progressBar = "progress_bar"
    static let simulationResults = "simulation_results"

    // MARK: - Library Screen
    static let libraryView = "library_view"
    static let weaponsTab = "weapons_tab"
    static let defendersTab = "defenders_tab"
    static let searchField = "search_field"
    static let addButton = "add_button"
    static let refreshButton = "refresh_button"

    // MARK: - Components
    static let weaponCard = "weapon_card"
    static let defenderCard = "defender_card"
    static let deleteButton = "delete_button"
    static let cloneButton = "clone_button"
}

// MARK: - Accessibility Labels

/// Provides descriptive labels for VoiceOver
extension View {
    /// Adds a descriptive accessibility label
    func accessibilityLabel(_ label: String) -> some View {
        self.accessibilityLabel(Text(label))
    }

    /// Adds accessibility hint with additional context
    func accessibilityHint(_ hint: String) -> some View {
        self.accessibilityHint(Text(hint))
    }

    /// Marks view as a button for VoiceOver
    func accessibilityButton() -> some View {
        self.accessibilityAddTraits(.isButton)
    }

    /// Marks view as a header for VoiceOver navigation
    func accessibilityHeader() -> some View {
        self.accessibilityAddTraits(.isHeader)
    }
}

// MARK: - Dynamic Type Support

extension View {
    /// Scales font size based on Dynamic Type settings
    func scaledFont(_ style: Font.TextStyle, weight: Font.Weight = .regular) -> some View {
        self.font(.system(style, design: .default, weight: weight))
    }

    /// Limits the maximum Dynamic Type scale
    @available(iOS 15.0, *)
    func limitedDynamicType(min: DynamicTypeSize = .xSmall, max: DynamicTypeSize = .xxxLarge) -> some View {
        self.dynamicTypeSize(min...max)
    }
}

// MARK: - VoiceOver Helpers

/// Checks if VoiceOver is currently running
var isVoiceOverRunning: Bool {
    UIAccessibility.isVoiceOverRunning
}

/// Checks if user prefers reduced motion
var prefersReducedMotion: Bool {
    UIAccessibility.isReduceMotionEnabled
}

/// Checks if user prefers reduced transparency
var prefersReducedTransparency: Bool {
    UIAccessibility.isReduceTransparencyEnabled
}

// MARK: - Accessibility Announcement

/// Posts an accessibility announcement for VoiceOver users
func announceForAccessibility(_ message: String) {
    UIAccessibility.post(notification: .announcement, argument: message)
}

/// Posts a screen change announcement
func announceScreenChange(_ message: String) {
    UIAccessibility.post(notification: .screenChanged, argument: message)
}
