import Foundation
import Observation

/// Dependency Injection Container managing all app dependencies
///
/// This container follows the Dependency Inversion Principle (DIP) by:
/// - Registering protocol-based dependencies
/// - Providing factory methods for ViewModels
/// - Managing singleton instances for services
/// - Centralizing dependency configuration
///
/// ## Usage
/// ```swift
/// let container = DependencyContainer()
/// let viewModel = container.makeCalculatorViewModel()
/// ```
///
/// ## Architecture
/// The container uses constructor injection to provide dependencies,
/// ensuring loose coupling and high testability.
@Observable
final class DependencyContainer {
    // MARK: - Services (Lazy Singletons)

    /// Probability calculation engine (lazy singleton)
    private(set) lazy var probabilityEngine: ProbabilityCalculating = {
        ProbabilityEngine()
    }()

    /// Monte Carlo simulation engine (lazy singleton)
    private(set) lazy var monteCarloSimulator: MonteCarloSimulating = {
        MonteCarloSimulator(randomNumberGenerator: SecureRandomNumberGenerator())
    }()

    /// Statistical analyzer (lazy singleton)
    private(set) lazy var statisticalAnalyzer: StatisticalAnalyzing = {
        StatisticalAnalyzer()
    }()

    /// Ability processor for weapon abilities (lazy singleton)
    private(set) lazy var abilityProcessor: AbilityProcessing = {
        AbilityProcessor()
    }()

    // MARK: - Security

    /// Keychain manager for secure storage (lazy singleton)
    private(set) lazy var keychainManager: KeychainManaging = {
        KeychainManager(service: "com.mobilediceroller.app")
    }()

    // MARK: - Database & Repositories

    /// Database service (lazy singleton)
    private(set) lazy var databaseService: DatabaseService = {
        DatabaseService(
            keychainManager: keychainManager,
            configuration: DatabaseConfiguration()
        )
    }()

    /// Weapon repository (lazy singleton)
    private(set) lazy var weaponRepository: WeaponRepositoryProtocol = {
        WeaponRepository(database: databaseService)
    }()

    /// Defender repository (lazy singleton)
    private(set) lazy var defenderRepository: DefenderRepositoryProtocol = {
        DefenderRepository(database: databaseService)
    }()

    // MARK: - Initialization

    init() {
        // Container is ready to provide dependencies
    }

    // MARK: - Database Initialization

    /// Initializes the database and performs migrations
    ///
    /// This should be called during app launch to ensure the database
    /// is ready before any UI is displayed.
    func initializeDatabase() async throws {
        try await databaseService.initialize()
    }

    // MARK: - ViewModel Factories

    /// Creates a new CalculatorViewModel with injected dependencies
    ///
    /// - Returns: Configured CalculatorViewModel instance
    func makeCalculatorViewModel() -> CalculatorViewModel {
        CalculatorViewModel(
            probabilityEngine: probabilityEngine,
            abilityProcessor: abilityProcessor
        )
    }

    /// Creates a new SimulationViewModel with injected dependencies
    ///
    /// - Returns: Configured SimulationViewModel instance
    func makeSimulationViewModel() -> SimulationViewModel {
        SimulationViewModel(
            simulator: monteCarloSimulator,
            analyzer: statisticalAnalyzer
        )
    }

    /// Creates a new LibraryViewModel with injected dependencies
    ///
    /// - Returns: Configured LibraryViewModel instance
    func makeLibraryViewModel() -> LibraryViewModel {
        LibraryViewModel(
            weaponRepository: weaponRepository,
            defenderRepository: defenderRepository
        )
    }

    // MARK: - Testing Support

    /// Creates a container with mock dependencies for testing
    ///
    /// - Parameters:
    ///   - probabilityEngine: Mock probability engine (optional)
    ///   - simulator: Mock Monte Carlo simulator (optional)
    ///   - weaponRepository: Mock weapon repository (optional)
    /// - Returns: Container configured with mocks
    static func makeMockContainer(
        probabilityEngine: ProbabilityCalculating? = nil,
        simulator: MonteCarloSimulating? = nil,
        weaponRepository: WeaponRepositoryProtocol? = nil
    ) -> DependencyContainer {
        let container = DependencyContainer()

        // Inject mocks if provided
        // This pattern will be expanded in testing phases
        return container
    }
}

// MARK: - Temporary ViewModel Stubs (Phase 7)

// Temporary ViewModel stubs
struct CalculatorViewModel {
    init(probabilityEngine: ProbabilityCalculating, abilityProcessor: AbilityProcessing) {}
}
struct SimulationViewModel {
    init(simulator: MonteCarloSimulating, analyzer: StatisticalAnalyzing) {}
}
struct LibraryViewModel {
    init(weaponRepository: WeaponRepositoryProtocol, defenderRepository: DefenderRepositoryProtocol) {}
}
