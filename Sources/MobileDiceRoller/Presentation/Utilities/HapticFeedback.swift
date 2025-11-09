//
//  HapticFeedback.swift
//  MobileDiceRoller
//
//  Created on 2025-11-08.
//

import UIKit

/// Haptic feedback manager for tactile user interactions
///
/// Provides standardized haptic feedback throughout the app using
/// UIFeedbackGenerator. Respects user's reduced motion preferences.
///
/// ## Usage
/// ```swift
/// HapticFeedback.success() // When calculation succeeds
/// HapticFeedback.error() // When validation fails
/// HapticFeedback.selection() // When user taps a selectable item
/// ```
enum HapticFeedback {
    // MARK: - Feedback Generators

    private static let impactLight = UIImpactFeedbackGenerator(style: .light)
    private static let impactMedium = UIImpactFeedbackGenerator(style: .medium)
    private static let impactHeavy = UIImpactFeedbackGenerator(style: .heavy)
    private static let notification = UINotificationFeedbackGenerator()
    private static let selection = UISelectionFeedbackGenerator()

    // MARK: - Public Methods

    /// Triggers success haptic feedback
    /// Use when: Calculation completes, save succeeds, simulation finishes
    static func success() {
        guard !prefersReducedMotion else { return }
        notification.notificationOccurred(.success)
    }

    /// Triggers warning haptic feedback
    /// Use when: User action needs attention but isn't an error
    static func warning() {
        guard !prefersReducedMotion else { return }
        notification.notificationOccurred(.warning)
    }

    /// Triggers error haptic feedback
    /// Use when: Validation fails, operation errors, invalid input
    static func error() {
        guard !prefersReducedMotion else { return }
        notification.notificationOccurred(.error)
    }

    /// Triggers light impact feedback
    /// Use when: Toggle switches, minor interactions
    static func light() {
        guard !prefersReducedMotion else { return }
        impactLight.impactOccurred()
    }

    /// Triggers medium impact feedback
    /// Use when: Button taps, deleting items
    static func medium() {
        guard !prefersReducedMotion else { return }
        impactMedium.impactOccurred()
    }

    /// Triggers heavy impact feedback
    /// Use when: Critical actions, reset operations
    static func heavy() {
        guard !prefersReducedMotion else { return }
        impactHeavy.impactOccurred()
    }

    /// Triggers selection feedback
    /// Use when: Scrolling through pickers, selecting items in a list
    static func selection() {
        guard !prefersReducedMotion else { return }
        selection.selectionChanged()
    }

    // MARK: - Preparation (Optional Optimization)

    /// Prepares feedback generators for reduced latency
    /// Call this before showing a screen with haptic feedback
    static func prepare() {
        guard !prefersReducedMotion else { return }
        impactLight.prepare()
        impactMedium.prepare()
        impactHeavy.prepare()
        notification.prepare()
        selection.prepare()
    }

    // MARK: - Helper

    private static var prefersReducedMotion: Bool {
        UIAccessibility.isReduceMotionEnabled
    }
}

// MARK: - SwiftUI View Extension

extension View {
    /// Adds haptic feedback to a button or interactive view
    func hapticFeedback(_ feedbackType: HapticFeedbackType = .selection, onTap: Bool = true) -> some View {
        self.onTapGesture {
            if onTap {
                switch feedbackType {
                case .light:
                    HapticFeedback.light()
                case .medium:
                    HapticFeedback.medium()
                case .heavy:
                    HapticFeedback.heavy()
                case .selection:
                    HapticFeedback.selection()
                case .success:
                    HapticFeedback.success()
                case .warning:
                    HapticFeedback.warning()
                case .error:
                    HapticFeedback.error()
                }
            }
        }
    }
}

/// Haptic feedback types
enum HapticFeedbackType {
    case light
    case medium
    case heavy
    case selection
    case success
    case warning
    case error
}
