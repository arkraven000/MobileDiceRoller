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

    // MARK: - Database & Repositories

    /// Database service (lazy singleton)
    private(set) lazy var databaseService: DatabaseServiceProtocol = {
        // Will be implemented in Phase 6
        // For now, return a stub
        DatabaseServiceStub()
    }()

    /// Weapon repository (lazy singleton)
    private(set) lazy var weaponRepository: WeaponRepositoryProtocol = {
        // Will be implemented in Phase 6
        WeaponRepositoryStub()
    }()

    /// Defender repository (lazy singleton)
    private(set) lazy var defenderRepository: DefenderRepositoryProtocol = {
        // Will be implemented in Phase 6
        DefenderRepositoryStub()
    }()

    // MARK: - Security

    /// Keychain manager for secure storage (lazy singleton)
    private(set) lazy var keychainManager: KeychainManaging = {
        // Will be implemented in Phase 6
        KeychainManagerStub()
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
    func initializeDatabase() async {
        // Will be implemented in Phase 6
        // For now, this is a no-op
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

// MARK: - Temporary Stub Implementations

// These stubs will be replaced with real implementations in later phases

/// Temporary stub for database service
private struct DatabaseServiceStub: DatabaseServiceProtocol {
    func initialize() async throws {}
}

/// Temporary stub for weapon repository
private struct WeaponRepositoryStub: WeaponRepositoryProtocol {
    func fetchAll() async throws -> [Weapon] { [] }
    func save(_ weapon: Weapon) async throws {}
    func delete(_ weapon: Weapon) async throws {}
}

/// Temporary stub for defender repository
private struct DefenderRepositoryStub: DefenderRepositoryProtocol {
    func fetchAll() async throws -> [Defender] { [] }
    func save(_ defender: Defender) async throws {}
    func delete(_ defender: Defender) async throws {}
}

/// Temporary stub for keychain manager
private struct KeychainManagerStub: KeychainManaging {
    func save(key: String, data: Data) throws {}
    func retrieve(key: String) throws -> Data? { nil }
    func delete(key: String) throws {}
}

// MARK: - Protocol Definitions (Temporary Forward Declarations)

// These protocols will be properly defined in their respective phases
// For now, we provide minimal definitions to avoid compilation errors

protocol ProbabilityCalculating {}
protocol MonteCarloSimulating {}
protocol StatisticalAnalyzing {}
protocol AbilityProcessing {}
protocol DatabaseServiceProtocol {
    func initialize() async throws
}
protocol WeaponRepositoryProtocol {
    func fetchAll() async throws -> [Weapon]
    func save(_ weapon: Weapon) async throws
    func delete(_ weapon: Weapon) async throws
}
protocol DefenderRepositoryProtocol {
    func fetchAll() async throws -> [Defender]
    func save(_ defender: Defender) async throws
    func delete(_ defender: Defender) async throws
}
protocol KeychainManaging {
    func save(key: String, data: Data) throws
    func retrieve(key: String) throws -> Data?
    func delete(key: String) throws
}

// Temporary stub implementations
struct ProbabilityEngine: ProbabilityCalculating {}
struct MonteCarloSimulator: MonteCarloSimulating {
    init(randomNumberGenerator: RandomNumberGenerator) {}
}
struct SecureRandomNumberGenerator: RandomNumberGenerator {
    func next() -> UInt64 { 0 }
}
struct StatisticalAnalyzer: StatisticalAnalyzing {}
struct AbilityProcessor: AbilityProcessing {}

// Temporary model stubs
struct Weapon {}
struct Defender {}

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
