# AI Development Guide for Warhammer 40K Dice Calculator

> **⚠️ CRITICAL: All AI assistants working on this project MUST read and follow this guide.**

This guide provides detailed instructions for AI assistants to effectively contribute to this iOS project while maintaining code quality, architectural integrity, and following industry best practices.

---

## 📖 Table of Contents

1. [Before You Start](#before-you-start)
2. [Workflow Overview](#workflow-overview)
3. [Architecture Guidelines](#architecture-guidelines)
4. [Coding Standards](#coding-standards)
5. [Testing Requirements](#testing-requirements)
6. [Git Workflow](#git-workflow)
7. [Common Patterns & Examples](#common-patterns--examples)
8. [Troubleshooting](#troubleshooting)

---

## 🚦 Before You Start

### 1. Read These Documents (In Order)
1. **PROJECT_PLAN.md** - The single source of truth for all tasks
2. **This file** (AI_DEVELOPMENT_GUIDE.md) - How to implement tasks
3. **README.md** - Project overview and setup

### 2. Understand the Context
- This is a **Warhammer 40K dice probability calculator** for iOS
- Target audience: Warhammer 40K tabletop gamers
- Implements 10th edition rules with mathematical precision
- Must be secure (encrypted database) and performant (1M simulations)

### 3. Check Project Status
```bash
# Always check current branch
git branch --show-current
# Should be: claude/warhammer-dice-calculator-ios-011CUveRegHFSfDpFKG5wErz

# Check what files exist
ls -la

# Review PROJECT_PLAN.md to see what's been completed
cat PROJECT_PLAN.md | grep "completed"
```

---

## 🔄 Workflow Overview

### Step-by-Step Process for Every Task

```
1. READ PROJECT_PLAN.md
   ↓
2. SELECT next pending task
   ↓
3. UPDATE task status to "in_progress" in PROJECT_PLAN.md
   ↓
4. WRITE TESTS FIRST (for business logic)
   ↓
5. IMPLEMENT the feature
   ↓
6. RUN TESTS (verify 80%+ coverage)
   ↓
7. RUN SWIFTLINT (zero warnings)
   ↓
8. UPDATE task status to "completed" in PROJECT_PLAN.md
   ↓
9. COMMIT with conventional commit message
   ↓
10. CONTINUE to next task
```

### How to Update PROJECT_PLAN.md

**When starting a task:**
```markdown
| 7 | Implement Weapon model with value semantics | 🔄 in_progress | 2025-11-08 | - | Starting with basic properties |
```

**When completing a task:**
```markdown
| 7 | Implement Weapon model with value semantics | ✅ completed | 2025-11-08 | 2025-11-08 | Includes all 40K weapon stats |
```

**When blocked:**
```markdown
| 50 | Set up Keychain wrapper | 🔲 pending [BLOCKED] | - | - | Waiting for security framework setup |
```

---

## 🏗️ Architecture Guidelines

### Layer Separation (Clean Architecture)

```
┌─────────────────────────────────────────┐
│         Presentation Layer              │
│  (SwiftUI Views + ViewModels)           │
│  - CalculatorView.swift                 │
│  - CalculatorViewModel.swift            │
└────────────┬────────────────────────────┘
             │ depends on
             ↓
┌─────────────────────────────────────────┐
│          Domain Layer                   │
│  (Business Logic + Models)              │
│  - ProbabilityEngine.swift              │
│  - Weapon.swift, Defender.swift         │
│  - WeaponAbility protocol               │
└────────────┬────────────────────────────┘
             │ depends on
             ↓
┌─────────────────────────────────────────┐
│           Data Layer                    │
│  (Repositories + Database)              │
│  - WeaponRepository.swift               │
│  - DatabaseService.swift                │
└─────────────────────────────────────────┘
```

**Key Rules:**
- ✅ **Presentation** can depend on **Domain**
- ✅ **Domain** can depend on **Data** (through protocols)
- ❌ **Domain** should NOT depend on **Presentation**
- ❌ **Data** should NOT depend on **Presentation**

### Dependency Injection Pattern

**Always use protocol-based dependency injection:**

```swift
// ❌ BAD: Direct dependency
class CalculatorViewModel {
    let engine = ProbabilityEngine() // Hard-coded dependency
}

// ✅ GOOD: Protocol-based DI
class CalculatorViewModel {
    private let engine: ProbabilityCalculating

    init(engine: ProbabilityCalculating) {
        self.engine = engine
    }
}
```

### Protocol Design (Interface Segregation)

**Create focused protocols, not god protocols:**

```swift
// ❌ BAD: God protocol
protocol GameEngine {
    func calculateHits()
    func calculateWounds()
    func runSimulation()
    func saveToDatabase()
    func generateChart()
}

// ✅ GOOD: Focused protocols
protocol ProbabilityCalculating {
    func calculateHitProbability(ballisticSkill: Int) -> Double
    func calculateWoundProbability(strength: Int, toughness: Int) -> Double
}

protocol MonteCarloSimulating {
    func runSimulation(iterations: Int) -> SimulationResult
}
```

---

## 💻 Coding Standards

### File Organization

```swift
// MARK: - Imports
import SwiftUI
import Combine

// MARK: - Type Definition
struct Weapon {
    // MARK: - Properties
    let name: String
    let attacks: Int

    // MARK: - Initialization
    init(name: String, attacks: Int) {
        self.name = name
        self.attacks = attacks
    }

    // MARK: - Public Methods
    func isValidForCombat() -> Bool {
        attacks > 0
    }

    // MARK: - Private Methods
    private func validateStats() -> Bool {
        // Implementation
    }
}

// MARK: - Protocol Conformance
extension Weapon: Equatable {
    static func == (lhs: Weapon, rhs: Weapon) -> Bool {
        lhs.name == rhs.name
    }
}
```

### Naming Conventions

```swift
// ✅ GOOD: Clear, descriptive names
func calculateWoundProbability(strength: Int, toughness: Int) -> Double

// ❌ BAD: Unclear abbreviations
func calcWndProb(s: Int, t: Int) -> Double

// ✅ GOOD: Bool properties
var isLethalHits: Bool
var hasDevastatingWounds: Bool

// ❌ BAD: Ambiguous bool names
var lethalHits: Bool
var devastatingWounds: Bool
```

### SwiftUI Modern Patterns (2025)

**Use @Observable (iOS 17+), not @Published:**

```swift
// ❌ OLD WAY (pre-iOS 17)
class CalculatorViewModel: ObservableObject {
    @Published var attacks: Int = 0
    @Published var hits: Double = 0
}

// ✅ NEW WAY (iOS 17+)
@Observable
class CalculatorViewModel {
    var attacks: Int = 0
    var hits: Double = 0
}
```

**Use @Bindable for two-way binding:**

```swift
// ✅ Modern form binding
struct WeaponEditorView: View {
    @Bindable var viewModel: WeaponEditorViewModel

    var body: some View {
        Form {
            TextField("Weapon Name", text: $viewModel.weaponName)
            TextField("Attacks", value: $viewModel.attacks, format: .number)
        }
    }
}
```

### Value Types vs Reference Types

```swift
// ✅ USE STRUCTS for models (value semantics)
struct Weapon {
    let name: String
    let attacks: Int
}

struct Defender {
    let toughness: Int
    let save: Int
}

// ✅ USE CLASSES for ViewModels and Services
@Observable
class CalculatorViewModel {
    var weapon: Weapon
    private let engine: ProbabilityCalculating
}

class ProbabilityEngine: ProbabilityCalculating {
    func calculateHits() -> Double { }
}
```

---

## 🧪 Testing Requirements

### Test-Driven Development (TDD)

**ALWAYS write tests BEFORE implementation for business logic:**

```swift
// Step 1: Write the test first (Red)
final class WeaponTests: XCTestCase {
    func testWeaponWithZeroAttacksIsInvalid() {
        // Arrange
        let weapon = Weapon(name: "Bolter", attacks: 0)

        // Act
        let isValid = weapon.isValidForCombat()

        // Assert
        XCTAssertFalse(isValid)
    }
}

// Step 2: Implement the feature (Green)
struct Weapon {
    func isValidForCombat() -> Bool {
        attacks > 0
    }
}

// Step 3: Refactor if needed
```

### Test Structure (AAA Pattern)

```swift
func testLethalHitsAutoWounds() {
    // Arrange - Set up test data
    let weapon = Weapon(name: "Test", attacks: 6, abilities: [.lethalHits])
    let defender = Defender(toughness: 4)
    let engine = ProbabilityEngine()

    // Act - Execute the behavior
    let result = engine.calculateDamage(weapon: weapon, defender: defender)

    // Assert - Verify the outcome
    XCTAssertGreaterThan(result.criticalHitAutoWounds, 0)
    XCTAssertEqual(result.criticalHitAutoWounds, weapon.attacks * (1.0/6.0), accuracy: 0.01)
}
```

### Code Coverage Requirements

```bash
# Check coverage after running tests
# Target: 80%+ for all modules

Domain Layer: 95%+ (business logic is critical)
Data Layer: 85%+ (repository pattern)
Presentation Layer: 70%+ (ViewModels)
```

### Mock Objects for Testing

```swift
// Create mock for testing ViewModels
class MockProbabilityEngine: ProbabilityCalculating {
    var calculateHitProbabilityCalled = false
    var stubbedHitProbability: Double = 0.5

    func calculateHitProbability(ballisticSkill: Int) -> Double {
        calculateHitProbabilityCalled = true
        return stubbedHitProbability
    }
}

// Use in tests
func testCalculatorViewModel() {
    // Arrange
    let mockEngine = MockProbabilityEngine()
    mockEngine.stubbedHitProbability = 0.75
    let viewModel = CalculatorViewModel(engine: mockEngine)

    // Act
    viewModel.calculate()

    // Assert
    XCTAssertTrue(mockEngine.calculateHitProbabilityCalled)
}
```

### Performance Testing

```swift
func testSimulationPerformance() {
    measure {
        let simulator = MonteCarloSimulator()
        _ = simulator.runSimulation(iterations: 1_000_000)
    }
    // Should complete in < 10 seconds
}
```

---

## 🔀 Git Workflow

### Branch Strategy

**Current branch:** `claude/warhammer-dice-calculator-ios-011CUveRegHFSfDpFKG5wErz`

```bash
# Always verify you're on the correct branch
git branch --show-current

# If not, switch to it
git checkout claude/warhammer-dice-calculator-ios-011CUveRegHFSfDpFKG5wErz
```

### Commit Message Format (Conventional Commits)

```bash
# Format: <type>(<scope>): <description>

# Types:
# feat: New feature
# fix: Bug fix
# refactor: Code refactoring
# test: Adding tests
# docs: Documentation
# style: Formatting
# perf: Performance improvement
# chore: Maintenance

# Examples:
git commit -m "feat(domain): add Weapon model with value semantics"
git commit -m "test(domain): add unit tests for Weapon model"
git commit -m "feat(abilities): implement LethalHits ability"
git commit -m "refactor(engine): optimize S vs T lookup table"
git commit -m "docs(plan): update PROJECT_PLAN.md with completed tasks"
```

### Commit Frequency

**Commit often, but logically:**

```bash
# ✅ GOOD: Logical commits
git commit -m "feat(domain): add Weapon model with properties"
git commit -m "test(domain): add unit tests for Weapon model (80% coverage)"
git commit -m "docs(plan): mark task 7 as completed"

# ❌ BAD: Too few commits
git commit -m "Implement entire Phase 2"

# ❌ BAD: Too many commits
git commit -m "Add Weapon.swift"
git commit -m "Add name property"
git commit -m "Add attacks property"
```

### Pushing Changes

```bash
# Push to remote with retry logic (network resilience)
git push -u origin claude/warhammer-dice-calculator-ios-011CUveRegHFSfDpFKG5wErz

# If push fails with 403, verify branch name matches session ID
# Branch MUST start with 'claude/' and end with session ID

# Retry with exponential backoff if network errors
# Wait 2s, then 4s, then 8s, then 16s between retries
```

---

## 🎯 Common Patterns & Examples

### 1. Creating a Domain Model

```swift
// File: Domain/Models/Weapon.swift

import Foundation

/// Represents a weapon in Warhammer 40K with its characteristics
///
/// A weapon defines the offensive capabilities of a unit, including
/// the number of attacks, hit chance, strength, armor penetration,
/// damage, and special abilities.
///
/// - Note: Uses value semantics (struct) for immutability and safety
struct Weapon: Equatable, Codable {
    // MARK: - Properties

    /// The name of the weapon (e.g., "Bolt Rifle", "Plasma Gun")
    let name: String

    /// Number of attacks this weapon makes
    let attacks: Int

    /// Ballistic Skill (BS) or Weapon Skill (WS) - the value needed to hit (2-6)
    let skill: Int

    /// Strength characteristic (1-14+)
    let strength: Int

    /// Armor Penetration (0 to -6)
    let armorPenetration: Int

    /// Damage per successful hit (can be "D3", "D6", etc.)
    let damage: String

    /// Special abilities (e.g., Lethal Hits, Devastating Wounds)
    let abilities: [WeaponAbility]

    /// Maximum range in inches (nil for melee weapons)
    let range: Int?

    // MARK: - Computed Properties

    /// Returns true if this is a ranged weapon
    var isRanged: Bool {
        range != nil
    }

    /// Returns true if this weapon can be used in combat
    var isValidForCombat: Bool {
        attacks > 0 && skill >= 2 && skill <= 6
    }

    // MARK: - Initialization

    /// Creates a new weapon with the specified characteristics
    init(
        name: String,
        attacks: Int,
        skill: Int,
        strength: Int,
        armorPenetration: Int,
        damage: String,
        abilities: [WeaponAbility] = [],
        range: Int? = nil
    ) {
        self.name = name
        self.attacks = attacks
        self.skill = skill
        self.strength = strength
        self.armorPenetration = armorPenetration
        self.damage = damage
        self.abilities = abilities
        self.range = range
    }
}

// MARK: - Factory Methods

extension Weapon {
    /// Creates a standard Bolt Rifle from Warhammer 40K 10th edition
    static func boltRifle() -> Weapon {
        Weapon(
            name: "Bolt Rifle",
            attacks: 2,
            skill: 3,
            strength: 4,
            armorPenetration: -1,
            damage: "1",
            range: 24
        )
    }
}
```

### 2. Creating a Protocol-Based Service

```swift
// File: Domain/Protocols/ProbabilityCalculating.swift

import Foundation

/// Protocol for calculating combat probabilities in Warhammer 40K
///
/// Implementations of this protocol handle the mathematical calculations
/// for hit rolls, wound rolls, save rolls, and damage allocation.
protocol ProbabilityCalculating {
    /// Calculates the probability of hitting with a given skill
    /// - Parameter skill: The Ballistic Skill or Weapon Skill (2-6)
    /// - Returns: Probability of success (0.0 to 1.0)
    func calculateHitProbability(skill: Int) -> Double

    /// Calculates the probability of wounding based on Strength vs Toughness
    /// - Parameters:
    ///   - strength: Attacker's Strength characteristic
    ///   - toughness: Defender's Toughness characteristic
    /// - Returns: Probability of wounding (0.0 to 1.0)
    func calculateWoundProbability(strength: Int, toughness: Int) -> Double

    /// Calculates the probability of failing a save
    /// - Parameters:
    ///   - save: Defender's Save characteristic (2-6)
    ///   - armorPenetration: Attacker's AP value (0 to -6)
    ///   - invulnerable: Optional invulnerable save (2-6)
    /// - Returns: Probability of failing save (0.0 to 1.0)
    func calculateSaveFailureProbability(
        save: Int,
        armorPenetration: Int,
        invulnerable: Int?
    ) -> Double
}

// File: Domain/Services/ProbabilityEngine.swift

import Foundation

/// Concrete implementation of probability calculations for Warhammer 40K
final class ProbabilityEngine: ProbabilityCalculating {

    // MARK: - Private Properties

    /// Lookup table for Strength vs Toughness wound rolls (optimization)
    private let strengthVsToughnessTable: [[Int]]

    // MARK: - Initialization

    init() {
        // Pre-compute S vs T table for performance
        self.strengthVsToughnessTable = Self.buildStrengthVsToughnessTable()
    }

    // MARK: - ProbabilityCalculating

    func calculateHitProbability(skill: Int) -> Double {
        guard (2...6).contains(skill) else { return 0.0 }

        // Probability = (7 - skill) / 6
        // BS 2+ = 5/6, BS 3+ = 4/6, etc.
        return Double(7 - skill) / 6.0
    }

    func calculateWoundProbability(strength: Int, toughness: Int) -> Double {
        let woundRoll = lookupWoundRoll(strength: strength, toughness: toughness)
        guard (2...6).contains(woundRoll) else { return 0.0 }

        return Double(7 - woundRoll) / 6.0
    }

    func calculateSaveFailureProbability(
        save: Int,
        armorPenetration: Int,
        invulnerable: Int?
    ) -> Double {
        // Use better of armor save or invulnerable save
        let modifiedSave = save - armorPenetration
        let bestSave = [modifiedSave, invulnerable ?? 7].min() ?? 7

        guard (2...6).contains(bestSave) else {
            return bestSave > 6 ? 1.0 : 0.0 // Auto-fail or auto-pass
        }

        // Probability of failing = (bestSave - 1) / 6
        return Double(bestSave - 1) / 6.0
    }

    // MARK: - Private Methods

    private func lookupWoundRoll(strength: Int, toughness: Int) -> Int {
        switch true {
        case strength >= toughness * 2:
            return 2 // S >= T*2: Wound on 2+
        case strength > toughness:
            return 3 // S > T: Wound on 3+
        case strength == toughness:
            return 4 // S = T: Wound on 4+
        case strength < toughness && strength * 2 > toughness:
            return 5 // S < T but S*2 > T: Wound on 5+
        default:
            return 6 // S*2 <= T: Wound on 6+
        }
    }

    private static func buildStrengthVsToughnessTable() -> [[Int]] {
        // Build lookup table for performance (optional optimization)
        return []
    }
}
```

### 3. Creating a ViewModel with @Observable

```swift
// File: Presentation/ViewModels/CalculatorViewModel.swift

import Foundation
import Observation

/// ViewModel for the probability calculator screen
///
/// Manages the state and business logic for calculating combat probabilities.
/// Uses the @Observable macro for automatic SwiftUI view updates.
@Observable
final class CalculatorViewModel {

    // MARK: - Properties

    /// Input: Weapon being used for attack
    var weapon: Weapon?

    /// Input: Defender being attacked
    var defender: Defender?

    /// Output: Calculated combat result
    var result: CombatResult?

    /// Loading state for async operations
    var isCalculating: Bool = false

    /// Error message if calculation fails
    var errorMessage: String?

    // MARK: - Dependencies

    private let probabilityEngine: ProbabilityCalculating

    // MARK: - Initialization

    init(probabilityEngine: ProbabilityCalculating) {
        self.probabilityEngine = probabilityEngine
    }

    // MARK: - Public Methods

    /// Calculates combat probabilities for current weapon and defender
    func calculate() {
        guard let weapon = weapon, let defender = defender else {
            errorMessage = "Please select a weapon and defender"
            return
        }

        isCalculating = true
        errorMessage = nil

        // Perform calculation
        let hitProb = probabilityEngine.calculateHitProbability(skill: weapon.skill)
        let woundProb = probabilityEngine.calculateWoundProbability(
            strength: weapon.strength,
            toughness: defender.toughness
        )

        // Update result
        result = CombatResult(
            expectedHits: Double(weapon.attacks) * hitProb,
            expectedWounds: Double(weapon.attacks) * hitProb * woundProb
        )

        isCalculating = false
    }

    /// Resets the calculator to initial state
    func reset() {
        weapon = nil
        defender = nil
        result = nil
        errorMessage = nil
    }
}
```

### 4. Creating a SwiftUI View

```swift
// File: Presentation/Views/Calculator/CalculatorView.swift

import SwiftUI

/// Main calculator screen for probability calculations
struct CalculatorView: View {

    // MARK: - Properties

    @State private var viewModel: CalculatorViewModel

    // MARK: - Initialization

    init(viewModel: CalculatorViewModel) {
        self._viewModel = State(initialValue: viewModel)
    }

    // MARK: - Body

    var body: some View {
        NavigationStack {
            Form {
                weaponSection
                defenderSection
                calculateButton

                if let result = viewModel.result {
                    resultsSection(result)
                }
            }
            .navigationTitle("Dice Calculator")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Reset", action: viewModel.reset)
                }
            }
        }
    }

    // MARK: - View Components

    private var weaponSection: some View {
        Section("Weapon") {
            // Weapon selection UI
            Text("Select weapon...")
        }
    }

    private var defenderSection: some View {
        Section("Defender") {
            // Defender selection UI
            Text("Select defender...")
        }
    }

    private var calculateButton: some View {
        Button(action: viewModel.calculate) {
            if viewModel.isCalculating {
                ProgressView()
            } else {
                Text("Calculate Probabilities")
            }
        }
        .disabled(viewModel.weapon == nil || viewModel.defender == nil)
    }

    private func resultsSection(_ result: CombatResult) -> some View {
        Section("Results") {
            LabeledContent("Expected Hits", value: result.expectedHits, format: .number.precision(.fractionLength(2)))
            LabeledContent("Expected Wounds", value: result.expectedWounds, format: .number.precision(.fractionLength(2)))
        }
    }
}

// MARK: - Previews

#Preview {
    CalculatorView(
        viewModel: CalculatorViewModel(
            probabilityEngine: ProbabilityEngine()
        )
    )
}
```

---

## 🐛 Troubleshooting

### Common Issues & Solutions

#### Issue: "Cannot find type 'Weapon' in scope"
**Solution:** Ensure you've imported the correct module and the file is included in the target.

```swift
// Check target membership in Xcode
// File Inspector → Target Membership → ✅ MobileDiceRoller
```

#### Issue: SwiftLint warnings
**Solution:** Run SwiftLint and fix all warnings before committing.

```bash
# Install SwiftLint
brew install swiftlint

# Run SwiftLint
swiftlint

# Auto-fix some issues
swiftlint --fix
```

#### Issue: Low test coverage
**Solution:** Add more test cases for edge cases.

```swift
// Don't just test happy path
func testHappyPath() { /* ... */ }

// Also test edge cases
func testZeroAttacks() { /* ... */ }
func testInvalidSkill() { /* ... */ }
func testNegativeDamage() { /* ... */ }
func testMaximumValues() { /* ... */ }
```

#### Issue: Performance issues with 1M simulations
**Solution:** Use concurrent dispatch.

```swift
// Use concurrent execution
DispatchQueue.concurrentPerform(iterations: iterations) { i in
    // Simulation code
}
```

#### Issue: Git push fails with 403
**Solution:** Verify branch name matches required format.

```bash
# Branch must start with 'claude/' and end with session ID
git branch --show-current
# Should output: claude/warhammer-dice-calculator-ios-011CUveRegHFSfDpFKG5wErz

# If wrong, create correct branch
git checkout -b claude/warhammer-dice-calculator-ios-011CUveRegHFSfDpFKG5wErz
```

---

## 📋 Pre-Commit Checklist

Before committing ANY code, verify:

- [ ] Task status updated in PROJECT_PLAN.md
- [ ] Code follows Swift style guide
- [ ] All tests pass (⌘U in Xcode)
- [ ] Test coverage is 80%+ for new code
- [ ] SwiftLint shows zero warnings
- [ ] Code is documented with DocC comments
- [ ] No TODOs or FIXMEs in code
- [ ] No print() statements (use proper logging)
- [ ] No force unwraps (!) unless justified
- [ ] Git commit message follows conventional commits format

---

## 🎯 Key Principles to Remember

1. **Protocol-Oriented Programming**: Always use protocols for dependencies
2. **Value Semantics**: Use structs for models, classes for services/ViewModels
3. **Test-Driven Development**: Write tests first for business logic
4. **Single Responsibility**: Each type should do ONE thing well
5. **Dependency Injection**: Never hard-code dependencies
6. **Immutability**: Prefer `let` over `var` when possible
7. **Clear Naming**: Code should be self-documenting
8. **Performance**: Profile before optimizing, optimize hot paths only
9. **Security**: Never hard-code secrets, always use Keychain
10. **Documentation**: Write DocC comments for public APIs

---

## 📚 Additional Resources

- [Swift API Design Guidelines](https://swift.org/documentation/api-design-guidelines/)
- [SwiftUI Documentation](https://developer.apple.com/documentation/swiftui/)
- [WWDC 2025 - Optimize SwiftUI Performance](https://developer.apple.com/videos/play/wwdc2025/306/)
- [iOS Security Guide](https://support.apple.com/guide/security/welcome/web)
- [XCTest Documentation](https://developer.apple.com/documentation/xctest)

---

## ✅ Final Reminder

**ALWAYS:**
1. Read PROJECT_PLAN.md before starting
2. Update PROJECT_PLAN.md when starting/completing tasks
3. Write tests first (TDD)
4. Follow SOLID principles
5. Use protocol-based DI
6. Document your code
7. Commit often with clear messages
8. Push to the correct branch

**NEVER:**
- Skip tests for business logic
- Hard-code dependencies
- Commit code with warnings
- Push directly to main/master
- Leave PROJECT_PLAN.md out of sync

---

**Questions?** Check PROJECT_PLAN.md or README.md for additional guidance.

**Good luck building an amazing Warhammer 40K dice calculator! 🎲**
