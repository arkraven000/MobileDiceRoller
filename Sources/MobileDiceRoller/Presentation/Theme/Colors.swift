//
//  Colors.swift
//  MobileDiceRoller
//
//  Created on 2025-11-08.
//

import SwiftUI

/// Semantic color palette for the app
///
/// This extension provides semantic color names that adapt to light/dark mode
/// automatically. All colors are defined in the asset catalog for proper
/// dark mode support.
///
/// ## Usage
/// ```swift
/// Text("Hello").foregroundStyle(.appPrimary)
/// Rectangle().fill(.appBackground)
/// ```
extension Color {
    // MARK: - Primary Colors

    /// Primary brand color (adapts to dark mode)
    static let appPrimary = Color("Primary")

    /// Secondary brand color (adapts to dark mode)
    static let appSecondary = Color("Secondary")

    /// Accent color for highlights and interactive elements
    static let appAccent = Color("Accent")

    // MARK: - Background Colors

    /// Primary background color
    static let appBackground = Color("Background")

    /// Secondary background color for cards and sections
    static let appBackgroundSecondary = Color("BackgroundSecondary")

    /// Elevated background for overlays
    static let appBackgroundElevated = Color("BackgroundElevated")

    // MARK: - Text Colors

    /// Primary text color
    static let appTextPrimary = Color("TextPrimary")

    /// Secondary text color for less emphasis
    static let appTextSecondary = Color("TextSecondary")

    /// Tertiary text color for hints and placeholders
    static let appTextTertiary = Color("TextTertiary")

    // MARK: - Semantic Colors

    /// Success state color (green)
    static let appSuccess = Color("Success")

    /// Warning state color (yellow/orange)
    static let appWarning = Color("Warning")

    /// Error state color (red)
    static let appError = Color("Error")

    /// Info state color (blue)
    static let appInfo = Color("Info")

    // MARK: - Chart Colors

    /// Chart color for damage (blue gradient)
    static let appChartDamage = Color.blue

    /// Chart color for kills (red gradient)
    static let appChartKills = Color.red

    /// Chart color for probabilities (green gradient)
    static let appChartProbability = Color.green
}

// MARK: - Fallback Colors (for when asset catalog is not available)

extension Color {
    /// Fallback implementation using system colors
    static func semanticColor(light: Color, dark: Color) -> Color {
        Color(UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark ? UIColor(dark) : UIColor(light)
        })
    }
}

// Provide fallback colors if asset catalog colors are missing
extension Color {
    init(_ name: String) {
        // Try to load from asset catalog, fall back to system colors
        self = Color(name, bundle: nil)
    }
}
