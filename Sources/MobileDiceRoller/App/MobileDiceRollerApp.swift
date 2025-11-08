import SwiftUI

/// Main entry point for the Warhammer 40K Dice Calculator iOS application
///
/// This app provides comprehensive dice probability calculations, Monte Carlo simulations,
/// and an encrypted weapon/unit library for Warhammer 40,000 10th Edition.
///
/// ## Features
/// - Probability calculator with full 40K 10th edition rules
/// - 18 weapon abilities (Lethal Hits, Devastating Wounds, etc.)
/// - Monte Carlo simulation (1 to 1,000,000 iterations)
/// - AES-256 encrypted SQLCipher database
///
/// ## Architecture
/// - Clean Architecture with MVVM pattern
/// - Protocol-oriented design for testability
/// - Dependency injection for loose coupling
/// - @Observable macro for modern SwiftUI state management
@main
struct MobileDiceRollerApp: App {
    // MARK: - Properties

    /// Dependency injection container managing all app dependencies
    private let container: DependencyContainer

    // MARK: - Initialization

    init() {
        self.container = DependencyContainer()
        configureApp()
    }

    // MARK: - Scene

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(container)
        }
    }

    // MARK: - Configuration

    /// Configures the app on launch
    private func configureApp() {
        // Configure appearance
        setupAppearance()

        // Initialize database
        Task {
            await container.initializeDatabase()
        }
    }

    /// Sets up the app's appearance and theme
    private func setupAppearance() {
        // Configure navigation bar appearance
        let appearance = UINavigationBarAppearance()
        appearance.configureWithDefaultBackground()

        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
    }
}

// MARK: - Content View

/// Temporary content view - will be replaced with proper navigation in Phase 8
struct ContentView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Image(systemName: "dice.fill")
                    .font(.system(size: 80))
                    .foregroundStyle(.blue)

                Text("Warhammer 40K")
                    .font(.title)
                    .fontWeight(.bold)

                Text("Dice Calculator")
                    .font(.title2)
                    .foregroundStyle(.secondary)

                Text("Phase 1: Foundation Setup Complete")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
                    .padding(.top, 40)
            }
            .navigationTitle("40K Calculator")
        }
    }
}

// MARK: - Previews

#Preview {
    ContentView()
}
