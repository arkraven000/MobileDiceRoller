# Contributing to Warhammer 40K Dice Calculator

Thank you for your interest in contributing! This document provides guidelines for contributing to this project.

---

## 📋 Table of Contents

1. [Code of Conduct](#code-of-conduct)
2. [Getting Started](#getting-started)
3. [Development Workflow](#development-workflow)
4. [Coding Standards](#coding-standards)
5. [Testing Requirements](#testing-requirements)
6. [Commit Messages](#commit-messages)
7. [Pull Request Process](#pull-request-process)
8. [Architecture Guidelines](#architecture-guidelines)

---

## 🤝 Code of Conduct

This project follows standard open-source community guidelines:

- **Be respectful** - Treat all contributors with respect
- **Be collaborative** - Work together constructively
- **Be patient** - Remember that everyone was a beginner once
- **Be helpful** - Share knowledge and assist others
- **Focus on merit** - Technical quality matters most

---

## 🚀 Getting Started

### Prerequisites

Before contributing, ensure you have:

- macOS 13.0+ (Ventura or later)
- Xcode 15.0+
- Swift 5.9+
- iOS 17.0+ simulator or device
- Git installed and configured

### Setting Up Development Environment

```bash
# 1. Fork the repository on GitHub
# 2. Clone your fork
git clone https://github.com/YOUR_USERNAME/MobileDiceRoller.git
cd MobileDiceRoller

# 3. Add upstream remote
git remote add upstream https://github.com/ORIGINAL_OWNER/MobileDiceRoller.git

# 4. Create a feature branch
git checkout -b feature/your-feature-name

# 5. Open in Xcode
open MobileDiceRoller.xcodeproj
```

---

## 🔄 Development Workflow

### Required Reading

Before writing any code, read these documents in order:

1. **[PROJECT_PLAN.md](PROJECT_PLAN.md)** - Complete task breakdown (109 tasks)
2. **[AI_DEVELOPMENT_GUIDE.md](AI_DEVELOPMENT_GUIDE.md)** - Detailed development guidelines
3. **[README.md](README.md)** - Project overview and architecture
4. **[docs/ADRs/](docs/ADRs/)** - Architecture Decision Records

### Task Selection

1. Check [PROJECT_PLAN.md](PROJECT_PLAN.md) for available tasks (status: 🔲 pending)
2. Comment on the task or issue indicating you're working on it
3. Update task status to 🔄 in_progress in PROJECT_PLAN.md
4. Create a feature branch: `git checkout -b feature/task-name`

### Test-Driven Development

This project follows **Test-Driven Development (TDD)**:

1. **Write tests first** for all business logic
2. **Run tests** - they should fail (Red)
3. **Implement** the minimum code to pass tests (Green)
4. **Refactor** while keeping tests green (Refactor)
5. **Verify coverage** - aim for 80%+

```bash
# Run tests in Xcode (⌘U)
# Or from command line:
xcodebuild test -scheme MobileDiceRoller \
  -destination 'platform=iOS Simulator,name=iPhone 15 Pro' \
  -enableCodeCoverage YES
```

---

## 📐 Coding Standards

### Swift Style Guide

This project follows the [Swift API Design Guidelines](https://swift.org/documentation/api-design-guidelines/) with these additions:

#### Naming Conventions

```swift
// Classes/Structs: UpperCamelCase
class ProbabilityEngine { }
struct Weapon { }

// Functions/Variables: lowerCamelCase
func calculateProbability() { }
var expectedDamage: Double

// Protocols: Descriptive with -ing/-able suffix
protocol ProbabilityCalculating { }
protocol Encodable { }

// Constants: lowerCamelCase
let maximumAttacks = 100

// Enums: UpperCamelCase, cases lowerCamelCase
enum WeaponAbilityType {
    case lethalHits
    case devastatingWounds
}
```

#### Code Organization

```swift
// MARK: - Type Definition
struct Weapon {
    // MARK: - Properties
    let id: String
    let name: String

    // MARK: - Initialization
    init(id: String, name: String) {
        self.id = id
        self.name = name
    }

    // MARK: - Public Methods
    func validate() -> Bool {
        // Implementation
    }

    // MARK: - Private Methods
    private func helper() {
        // Implementation
    }
}

// MARK: - Protocol Conformance
extension Weapon: Equatable {
    static func == (lhs: Weapon, rhs: Weapon) -> Bool {
        lhs.id == rhs.id
    }
}
```

#### Documentation

Use Swift DocC format for all public APIs:

```swift
/// Calculates combat probability for a weapon against a defender
///
/// This function implements the full Warhammer 40K 10th Edition combat rules,
/// including hit rolls, wound rolls, save rolls, and damage allocation.
///
/// - Parameters:
///   - weapon: The attacking weapon with all characteristics
///   - defender: The defending unit with toughness, saves, and wounds
/// - Returns: A `CombatResult` containing all probability calculations
/// - Throws: `CalculationError` if inputs are invalid
///
/// ## Example
/// ```swift
/// let result = try calculateCombat(weapon: boltgun, defender: spaceMarine)
/// print("Expected damage: \(result.expectedDamage)")
/// ```
func calculateCombat(weapon: Weapon, defender: Defender) throws -> CombatResult {
    // Implementation
}
```

### SwiftLint

This project uses SwiftLint for code quality enforcement:

```bash
# SwiftLint must pass with zero warnings before PR approval
swiftlint lint --strict

# Auto-fix what's possible
swiftlint --fix
```

**SwiftLint Rules:**
- Line length: 120 characters max
- Function body length: 40 lines max
- File length: 400 lines max
- Cyclomatic complexity: 10 max
- Force unwrapping: Disallowed (use guard/if let)
- Force cast: Disallowed (use as? or guard)

---

## 🧪 Testing Requirements

### Coverage Targets

| Layer | Coverage Target | Rationale |
|-------|----------------|-----------|
| **Domain** | 95%+ | Business logic is critical |
| **Data** | 85%+ | Repository pattern testing |
| **Presentation** | 70%+ | ViewModel testing |
| **Overall** | **80%+** | Project-wide requirement |

### Testing Approach

#### Unit Tests

Test individual components in isolation:

```swift
final class WeaponTests: XCTestCase {
    func testWeaponInitialization() {
        // Given
        let weapon = Weapon(
            id: "test-id",
            name: "Boltgun",
            attacks: 2,
            skill: 3,
            strength: 4,
            armorPenetration: 0,
            damage: 1
        )

        // When/Then
        XCTAssertEqual(weapon.name, "Boltgun")
        XCTAssertEqual(weapon.attacks, 2)
    }
}
```

#### Integration Tests

Test component interactions:

```swift
final class RepositoryIntegrationTests: XCTestCase {
    var repository: WeaponRepository!

    override func setUp() async throws {
        repository = try await SQLiteWeaponRepository(databaseURL: testDatabaseURL)
    }

    func testSaveAndRetrieveWeapon() async throws {
        // Given
        let weapon = Weapon.boltgun()

        // When
        try await repository.save(weapon)
        let retrieved = try await repository.findById(weapon.id)

        // Then
        XCTAssertEqual(retrieved, weapon)
    }
}
```

#### Performance Tests

Verify performance targets:

```swift
final class SimulationPerformanceTests: XCTestCase {
    func testOneMillionSimulationsUnder10Seconds() {
        measure {
            let result = engine.runSimulation(iterations: 1_000_000)
            XCTAssertNotNil(result)
        }
        // XCTest will fail if average exceeds 10 seconds
    }
}
```

---

## 📝 Commit Messages

Use [Conventional Commits](https://www.conventionalcommits.org/) format:

```
<type>(<scope>): <description>

[optional body]

[optional footer]
```

### Types

- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation only
- `style`: Code style changes (formatting, no logic change)
- `refactor`: Code refactoring (no feature or bug fix)
- `perf`: Performance improvement
- `test`: Adding or updating tests
- `chore`: Maintenance tasks (dependencies, build config)

### Examples

```bash
# Feature addition
git commit -m "feat(domain): add Sustained Hits ability implementation"

# Bug fix
git commit -m "fix(engine): correct Strength vs Toughness calculation for S10+ weapons"

# Documentation
git commit -m "docs(adr): add decision record for @Observable macro usage"

# Refactoring
git commit -m "refactor(viewmodel): extract calculator validation logic to separate method"

# Multiple paragraphs
git commit -m "feat(database): implement SQLCipher encryption

- Add AES-256 encryption for weapon database
- Store encryption keys in iOS Keychain
- Implement secure key generation and rotation
- Add migration from unencrypted database

Closes #42"
```

---

## 🔀 Pull Request Process

### Before Submitting

Ensure your PR meets these requirements:

- [ ] All tests pass (`⌘U` in Xcode)
- [ ] Code coverage ≥ 80%
- [ ] SwiftLint passes with zero warnings
- [ ] Documentation updated (if needed)
- [ ] PROJECT_PLAN.md updated with task status
- [ ] Conventional commit messages used
- [ ] No merge conflicts with main branch

### PR Template

```markdown
## Description
Brief description of what this PR does

## Related Issue
Closes #123

## Type of Change
- [ ] Bug fix (non-breaking change which fixes an issue)
- [ ] New feature (non-breaking change which adds functionality)
- [ ] Breaking change (fix or feature that would cause existing functionality to not work as expected)
- [ ] Documentation update

## Testing
Describe the tests you added/modified

## Screenshots (if applicable)
Add screenshots for UI changes

## Checklist
- [ ] Tests pass
- [ ] Code coverage ≥ 80%
- [ ] SwiftLint clean
- [ ] Documentation updated
- [ ] PROJECT_PLAN.md updated
```

### Review Process

1. **Submit PR** to the `develop` branch (not `main`)
2. **CI checks** must pass (tests, coverage, SwiftLint)
3. **Code review** by maintainer (1 approval required)
4. **Address feedback** - make requested changes
5. **Merge** - Squash and merge into develop

---

## 🏗️ Architecture Guidelines

### Clean Architecture Layers

This project uses **Clean Architecture** with **MVVM**:

```
┌─────────────────────────────────────┐
│     Presentation Layer              │  ← ViewModels, SwiftUI Views
│     (@Observable, SwiftUI)          │
├─────────────────────────────────────┤
│     Domain Layer                    │  ← Business Logic, Models, Protocols
│     (Pure Swift, Protocol-Oriented) │
├─────────────────────────────────────┤
│     Data Layer                      │  ← Repositories, Database
│     (SQLCipher, Persistence)        │
└─────────────────────────────────────┘
```

### Dependency Rules

- **Presentation** depends on **Domain** (not Data)
- **Data** depends on **Domain** (implements protocols)
- **Domain** depends on nothing (pure Swift)

### Protocol-Oriented Design

All major components use protocols:

```swift
// Domain layer defines protocol
protocol ProbabilityCalculating {
    func calculate(weapon: Weapon, defender: Defender) -> CombatResult
}

// Domain layer implements
final class ProbabilityEngine: ProbabilityCalculating {
    func calculate(weapon: Weapon, defender: Defender) -> CombatResult {
        // Implementation
    }
}

// Presentation layer uses protocol (via DI)
@Observable
final class CalculatorViewModel {
    private let probabilityEngine: ProbabilityCalculating

    init(probabilityEngine: ProbabilityCalculating) {
        self.probabilityEngine = probabilityEngine
    }
}
```

### Dependency Injection

Use constructor injection via `DependencyContainer`:

```swift
// Register dependencies
let container = DependencyContainer()

// Create ViewModel with injected dependencies
let viewModel = container.makeCalculatorViewModel()
```

### Modern SwiftUI Patterns

- Use `@Observable` macro (iOS 17+), not `@Published`
- Use `@Bindable` for two-way binding in views
- Prefer `async/await` over Combine for async operations
- Extract subviews for performance
- Use `LazyVStack` for large lists

---

## 🔒 Security Guidelines

### Sensitive Data

- **NEVER** commit secrets, API keys, or passwords
- Use iOS Keychain for encryption keys
- Use `.gitignore` for sensitive files

### Database Security

- All weapon/unit data encrypted with SQLCipher (AES-256)
- Encryption keys stored in iOS Keychain (hardware-backed)
- No plaintext storage of user data

### Code Review Checklist

- [ ] No hardcoded secrets
- [ ] Keychain used for sensitive data
- [ ] Input validation for user data
- [ ] No SQL injection vulnerabilities (use parameterized queries)
- [ ] Secure random number generation (SecRandomCopyBytes)

---

## ❓ Questions?

- **General Questions**: Open a [Discussion](https://github.com/YOUR_REPO/discussions)
- **Bug Reports**: Open an [Issue](https://github.com/YOUR_REPO/issues)
- **Development Questions**: Check [AI_DEVELOPMENT_GUIDE.md](AI_DEVELOPMENT_GUIDE.md)
- **Architecture Questions**: Read [docs/ADRs/](docs/ADRs/)

---

## 📜 License

By contributing, you agree that your contributions will be licensed under the MIT License.

---

## 🙏 Recognition

Contributors will be recognized in:
- GitHub Contributors page
- Release notes
- Project README (for significant contributions)

Thank you for contributing to the Warhammer 40K community! ⚔️

*For the Emperor!*
