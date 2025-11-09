# ADR 003: Protocol-Oriented Architecture with Dependency Injection

**Date**: 2025-11-08
**Status**: Accepted
**Deciders**: Development Team

## Context

Need to choose an architecture pattern that provides:
- Testability
- Loose coupling
- Clear separation of concerns
- Type safety

## Decision

We will use **Protocol-Oriented Architecture** with **Dependency Injection** via constructor injection.

## Rationale

### Core Principles:
1. **Protocols Define Contracts**: All major components defined by protocols
2. **Dependency Inversion**: High-level modules depend on abstractions, not concretions
3. **Constructor Injection**: Dependencies injected via initializers
4. **Single Responsibility**: Each protocol has one clear purpose

### Example Pattern:

```swift
// Protocol defines the contract
protocol ProbabilityCalculating {
    func calculateHitProbability(skill: Int) -> Double
}

// Concrete implementation
final class ProbabilityEngine: ProbabilityCalculating {
    func calculateHitProbability(skill: Int) -> Double {
        // Implementation
    }
}

// ViewModel depends on protocol, not concrete class
@Observable
final class CalculatorViewModel {
    private let probabilityEngine: ProbabilityCalculating

    init(probabilityEngine: ProbabilityCalculating) {
        self.probabilityEngine = probabilityEngine
    }
}
```

## Benefits

### Testability:
```swift
// Easy to create mocks for testing
struct MockProbabilityEngine: ProbabilityCalculating {
    func calculateHitProbability(skill: Int) -> Double {
        return 0.5 // Controlled test value
    }
}

// Test with mock
let viewModel = CalculatorViewModel(
    probabilityEngine: MockProbabilityEngine()
)
```

### Flexibility:
- Can swap implementations without changing client code
- Easy to add new implementations (e.g., caching decorator)

### SOLID Compliance:
- ✅ Single Responsibility Principle
- ✅ Open-Closed Principle
- ✅ Liskov Substitution Principle
- ✅ Interface Segregation Principle
- ✅ Dependency Inversion Principle

## Protocol Hierarchy

```
Domain Layer:
- ProbabilityCalculating
- MonteCarloSimulating
- StatisticalAnalyzing
- AbilityProcessing

Data Layer:
- DatabaseServiceProtocol
- WeaponRepositoryProtocol
- DefenderRepositoryProtocol
- KeychainManaging

Presentation Layer:
- ViewModels use domain protocols
- Views depend on ViewModels (via @Bindable)
```

## Dependency Container

Centralized DI container manages all dependencies:
- Lazy singletons for services
- Factory methods for ViewModels
- Protocol-based registration

## Consequences

### Positive:
- Highly testable (100% mockable)
- Loose coupling between layers
- Easy to refactor implementations
- Clear architectural boundaries
- Type-safe dependency resolution

### Negative:
- More upfront design (define protocols)
- Slight increase in code volume
- Need to maintain protocol contracts

## Testing Impact

Test coverage with protocols vs. concrete classes:
- **With Protocols**: 90%+ achievable (mocks, no DB needed)
- **Without Protocols**: 50-60% (requires real DB, hard to isolate)

## References

- [Protocol-Oriented Programming - WWDC 2015](https://developer.apple.com/videos/play/wwdc2015/408/)
- [Dependency Injection in Swift](https://www.swiftbysundell.com/articles/dependency-injection-using-factories-in-swift/)
- [SOLID Principles](https://en.wikipedia.org/wiki/SOLID)
