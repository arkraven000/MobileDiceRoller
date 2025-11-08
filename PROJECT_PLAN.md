# Warhammer 40K Dice Calculator - iOS Implementation Plan

> **⚠️ CRITICAL: This is the SINGLE SOURCE OF TRUTH for this project.**
> **This plan MUST be updated whenever progress is made.**
> **All AI assistants and developers MUST follow this plan and keep the task status current.**

**Last Updated**: 2025-11-08
**Project Status**: Phase 1 Complete - Foundation & Setup
**Target iOS Version**: iOS 16.0+
**Completion**: 5 of 109 tasks (4.6%)

---

## 📋 Task Tracking

### Status Legend
- 🔲 **pending** - Not yet started
- 🔄 **in_progress** - Currently being worked on
- ✅ **completed** - Finished and verified

### How to Update This Plan
1. **Before starting any task**: Mark it as `in_progress` with current date
2. **After completing a task**: Mark it as `completed` with completion date
3. **If blocked**: Add a `[BLOCKED]` tag and reason
4. **Add notes**: Use the Notes column for important decisions or issues

---

## 🎯 Core Features Overview

### 1. Dice Probability Calculator
- Calculates hit, wound, save, and damage probabilities
- Implements full Warhammer 40K 10th edition combat rules
- Handles Strength vs Toughness comparisons
- Supports armor penetration, invulnerable saves, and Feel No Pain
- Provides expected values for hits, wounds, damage, and models killed

### 2. 18 Weapon Abilities
- **Lethal Hits**: Critical hits auto-wound
- **Devastating Wounds**: Critical wounds bypass saves
- **Sustained Hits 1/2/3**: Generate additional hits on crits
- **Torrent**: Auto-hit without rolling
- **Twin-Linked**: Re-roll wounds
- **Melta 2/4**: Bonus damage at half range
- **Rapid Fire 1/2**: Extra attacks at close range
- **Blast**: Bonus attacks vs large units
- **Anti-X**: Critical wounds against specific unit types
- **Plus**: Ignores Cover, Precision, Hazardous, and more

### 3. Monte Carlo Simulation
- Runs 1 to 1,000,000 simulations
- Provides statistical analysis: mean, median, min/max, standard deviation
- Generates damage distribution histograms
- Calculates kill probabilities and unit wipe percentages
- Uses cryptographically secure random number generation

### 4. Unit & Weapon Library
- Save custom weapon profiles with all characteristics
- Save defender/unit profiles
- Search and filter saved profiles
- Clone existing profiles for variants
- Full CRUD operations
- All data encrypted in SQLCipher database

---

## 🏗️ Architecture & Technology Stack

### Architecture Pattern
- **Clean Architecture** with clear separation of concerns
- **MVVM** with modern SwiftUI (@Observable macro)
- **Protocol-Oriented Design** for testability and extensibility
- **Repository Pattern** for data access
- **Dependency Injection** for loose coupling

### SOLID Principles Implementation
- ✅ **Single Responsibility**: Each class/service has one clear purpose
- ✅ **Open-Closed**: Protocol-based weapon abilities (extensible without modification)
- ✅ **Liskov Substitution**: Protocol conformance ensures substitutability
- ✅ **Interface Segregation**: Focused protocols (ProbabilityCalculating, MonteCarloSimulating)
- ✅ **Dependency Inversion**: DI container manages all dependencies

### Technology Stack
| Component | Technology | Version |
|-----------|-----------|---------|
| Minimum iOS | iOS | 16.0+ |
| Language | Swift | 5.9+ |
| UI Framework | SwiftUI | - |
| Database | SQLCipher | Latest |
| Charts | Swift Charts | iOS 16+ |
| Testing | XCTest | - |
| Documentation | Swift DocC | - |
| Code Quality | SwiftLint | Latest |
| Dependency Mgmt | Swift Package Manager | - |
| CI/CD | GitHub Actions | - |

---

## 📁 Project Structure

```
MobileDiceRoller/
├── MobileDiceRoller/
│   ├── App/
│   │   ├── MobileDiceRollerApp.swift
│   │   └── DependencyContainer.swift          # DI Container
│   │
│   ├── Domain/                                # Business Logic Layer
│   │   ├── Models/
│   │   │   ├── Weapon.swift                   # Value type (struct)
│   │   │   ├── Defender.swift
│   │   │   ├── CombatResult.swift
│   │   │   └── WeaponAbility.swift
│   │   ├── Protocols/
│   │   │   ├── ProbabilityCalculating.swift   # ISP
│   │   │   ├── MonteCarloSimulating.swift
│   │   │   ├── WeaponAbility.swift
│   │   │   └── DatabaseRepository.swift
│   │   └── Services/
│   │       ├── ProbabilityEngine.swift        # SRP
│   │       ├── MonteCarloSimulator.swift
│   │       ├── StatisticalAnalyzer.swift
│   │       ├── AbilityProcessor.swift
│   │       └── HistogramGenerator.swift
│   │
│   ├── Data/                                  # Data Access Layer
│   │   ├── Database/
│   │   │   ├── DatabaseService.swift
│   │   │   ├── Schema/
│   │   │   │   ├── WeaponSchema.swift
│   │   │   │   └── DefenderSchema.swift
│   │   │   └── Migrations/
│   │   ├── Repositories/
│   │   │   ├── WeaponRepository.swift         # Repository Pattern
│   │   │   └── DefenderRepository.swift
│   │   └── Security/
│   │       ├── KeychainManager.swift
│   │       └── EncryptionKeyProvider.swift
│   │
│   ├── Presentation/                          # UI Layer
│   │   ├── ViewModels/
│   │   │   ├── CalculatorViewModel.swift      # @Observable
│   │   │   ├── SimulationViewModel.swift
│   │   │   └── LibraryViewModel.swift
│   │   ├── Views/
│   │   │   ├── Calculator/
│   │   │   │   ├── CalculatorView.swift
│   │   │   │   └── ResultsView.swift
│   │   │   ├── Simulation/
│   │   │   │   ├── SimulationView.swift
│   │   │   │   └── ChartView.swift
│   │   │   ├── Library/
│   │   │   │   ├── LibraryBrowserView.swift
│   │   │   │   ├── WeaponEditorView.swift
│   │   │   │   └── DefenderEditorView.swift
│   │   │   └── Components/                    # Reusable
│   │   │       ├── InputField.swift
│   │   │       ├── AbilityPicker.swift
│   │   │       └── StatCard.swift
│   │   └── Coordinators/
│   │       └── AppCoordinator.swift
│   │
│   ├── Utilities/
│   │   ├── Extensions/
│   │   │   ├── View+Accessibility.swift
│   │   │   └── Color+Semantic.swift
│   │   ├── Constants.swift
│   │   └── Helpers.swift
│   │
│   └── Resources/
│       ├── Assets.xcassets
│       ├── Colors.xcassets                    # Semantic colors
│       └── Localizable.strings
│
├── MobileDiceRollerTests/
│   ├── DomainTests/
│   │   ├── ModelTests/
│   │   ├── ServiceTests/
│   │   └── AbilityTests/                      # 18 ability tests
│   ├── DataTests/
│   │   ├── RepositoryTests/
│   │   └── EncryptionTests/
│   ├── PresentationTests/
│   │   ├── ViewModelTests/
│   │   └── SnapshotTests/
│   └── Mocks/
│       ├── MockProbabilityEngine.swift
│       └── MockRepository.swift
│
├── MobileDiceRollerUITests/
│   └── CriticalFlowTests/
│
├── Package.swift                              # SPM
├── .swiftlint.yml                            # Code quality
├── .github/workflows/ci.yml                  # CI/CD
├── README.md
├── CONTRIBUTING.md
├── LICENSE
└── docs/
    ├── ADRs/                                 # Architecture decisions
    └── API/                                  # Generated DocC
```

---

## 📝 Implementation Tasks (109 Total)

### Phase 1: Foundation & Setup (5 tasks)

| # | Task | Status | Started | Completed | Notes |
|---|------|--------|---------|-----------|-------|
| 1 | Set up project with modern SwiftUI architecture (iOS 16+ with @Observable macro) | ✅ completed | 2025-11-08 | 2025-11-08 | Created SPM package structure, app entry point, content view |
| 2 | Configure dependency injection container following DIP | ✅ completed | 2025-11-08 | 2025-11-08 | Protocol-based DI container with lazy singletons and factories |
| 3 | Set up Swift Package Manager dependencies (SQLCipher, Swift Testing) | ✅ completed | 2025-11-08 | 2025-11-08 | Package.swift with SQLite.swift dependency |
| 4 | Create .swiftlint.yml for code quality enforcement | ✅ completed | 2025-11-08 | 2025-11-08 | Comprehensive rules with zero warnings policy |
| 5 | Set up CI/CD pipeline for automated testing (XCTest) | ✅ completed | 2025-11-08 | 2025-11-08 | GitHub Actions with build, test, lint, security, docs |

### Phase 2: Domain Models with TDD (5 tasks)

| # | Task | Status | Started | Completed | Notes |
|---|------|--------|---------|-----------|-------|
| 6 | Create protocol-oriented domain models following SRP | 🔲 pending | - | - | Use structs with value semantics |
| 7 | Implement Weapon model with value semantics (struct) and protocols | 🔲 pending | - | - | Include all 40K stats |
| 8 | Implement Defender model with value semantics and protocols | 🔲 pending | - | - | T, Save, Invuln, FNP, Wounds |
| 9 | Create CombatResult model with immutable design | 🔲 pending | - | - | Expected values + probabilities |
| 10 | Write unit tests for domain models (TDD approach, 80%+ coverage) | 🔲 pending | - | - | Test all properties |

### Phase 3: Probability Calculator Engine (7 tasks)

| # | Task | Status | Started | Completed | Notes |
|---|------|--------|---------|-----------|-------|
| 11 | Create ProbabilityCalculating protocol (ISP) | 🔲 pending | - | - | Interface segregation |
| 12 | Implement ProbabilityEngine following SRP with injected dependencies | 🔲 pending | - | - | Hit/Wound/Save/Damage |
| 13 | Write unit tests for hit roll calculations (TDD) | 🔲 pending | - | - | Test BS 2+ through 6+ |
| 14 | Implement Strength vs Toughness matrix with lookup table optimization | 🔲 pending | - | - | All S vs T combinations |
| 15 | Write unit tests for wound roll calculations (all S vs T combinations) | 🔲 pending | - | - | 36 combinations |
| 16 | Implement armor save system with protocol-based design | 🔲 pending | - | - | AP, Invuln, FNP |
| 17 | Write unit tests for save mechanics (armor, invuln, FNP) | 🔲 pending | - | - | Edge cases |

### Phase 4: Weapon Abilities - Protocol-Based (23 tasks)

| # | Task | Status | Started | Completed | Notes |
|---|------|--------|---------|-----------|-------|
| 18 | Create WeaponAbility protocol following OCP | 🔲 pending | - | - | Open for extension |
| 19 | Implement AbilityProcessor with Strategy pattern for extensibility | 🔲 pending | - | - | Process multiple abilities |
| 20 | Write unit tests for ability system architecture | 🔲 pending | - | - | Test processor logic |
| 21 | Implement LethalHits ability conforming to WeaponAbility protocol | 🔲 pending | - | - | Crit hits auto-wound |
| 22 | Write unit tests for LethalHits (TDD) | 🔲 pending | - | - | Test auto-wound mechanic |
| 23 | Implement SustainedHits abilities (1/2/3 variants) | 🔲 pending | - | - | Extra hits on crit |
| 24 | Write unit tests for SustainedHits variants | 🔲 pending | - | - | Test all 3 variants |
| 25 | Implement DevastatingWounds ability | 🔲 pending | - | - | Crit wounds bypass saves |
| 26 | Write unit tests for DevastatingWounds | 🔲 pending | - | - | Test save bypass |
| 27 | Implement AntiX abilities with type-safe enum | 🔲 pending | - | - | Anti-Infantry, etc. |
| 28 | Write unit tests for AntiX mechanics | 🔲 pending | - | - | Test keyword matching |
| 29 | Implement Torrent (auto-hit) ability | 🔲 pending | - | - | Skip hit rolls |
| 30 | Write unit tests for Torrent | 🔲 pending | - | - | Verify auto-hit |
| 31 | Implement TwinLinked (re-roll wounds) ability | 🔲 pending | - | - | Re-roll failed wounds |
| 32 | Write unit tests for TwinLinked | 🔲 pending | - | - | Test re-roll logic |
| 33 | Implement Melta abilities (2/4) with range-based logic | 🔲 pending | - | - | Bonus damage at half range |
| 34 | Write unit tests for Melta mechanics | 🔲 pending | - | - | Test range calculations |
| 35 | Implement RapidFire abilities (1/2) with range conditions | 🔲 pending | - | - | Extra shots at close range |
| 36 | Write unit tests for RapidFire | 🔲 pending | - | - | Test range-based attacks |
| 37 | Implement Blast ability with unit-size scaling | 🔲 pending | - | - | Bonus vs large units |
| 38 | Write unit tests for Blast | 🔲 pending | - | - | Test scaling formula |
| 39 | Implement remaining abilities (IgnoresCover, Precision, Hazardous, etc.) | 🔲 pending | - | - | 9 more abilities |
| 40 | Write comprehensive unit tests for all 18 abilities (80%+ coverage) | 🔲 pending | - | - | Full test suite |

### Phase 5: Monte Carlo Simulation (9 tasks)

| # | Task | Status | Started | Completed | Notes |
|---|------|--------|---------|-----------|-------|
| 41 | Create MonteCarloSimulating protocol for testability | 🔲 pending | - | - | Protocol-based design |
| 42 | Implement MonteCarloSimulator using SecRandomCopyBytes for secure RNG | 🔲 pending | - | - | Cryptographically secure |
| 43 | Optimize simulation with concurrent dispatch queues | 🔲 pending | - | - | DispatchQueue.concurrentPerform |
| 44 | Write unit tests for simulation statistical accuracy | 🔲 pending | - | - | Verify distributions |
| 45 | Implement StatisticalAnalyzer with mean, median, stdDev calculations | 🔲 pending | - | - | Separate analyzer |
| 46 | Write unit tests for statistical calculations | 🔲 pending | - | - | Test math accuracy |
| 47 | Create HistogramGenerator for damage distribution visualization | 🔲 pending | - | - | Bucket damage values |
| 48 | Implement kill probability calculator with binomial distribution | 🔲 pending | - | - | Probability math |
| 49 | Write unit tests for histogram and probability calculations | 🔲 pending | - | - | Test edge cases |

### Phase 6: Encrypted Database (12 tasks)

| # | Task | Status | Started | Completed | Notes |
|---|------|--------|---------|-----------|-------|
| 50 | Set up Keychain wrapper for SQLCipher encryption key storage | 🔲 pending | - | - | Hardware-backed security |
| 51 | Implement DatabaseService protocol following Repository pattern | 🔲 pending | - | - | Abstract data access |
| 52 | Configure SQLCipher with AES-256 encryption and secure key derivation | 🔲 pending | - | - | Use CryptoKit |
| 53 | Write integration tests for database encryption | 🔲 pending | - | - | Verify encryption works |
| 54 | Create normalized database schema for weapon profiles | 🔲 pending | - | - | Efficient schema design |
| 55 | Create database schema for defender profiles with foreign keys | 🔲 pending | - | - | Relational design |
| 56 | Implement WeaponRepository with async/await CRUD operations | 🔲 pending | - | - | Repository pattern |
| 57 | Write unit tests for WeaponRepository (mock database) | 🔲 pending | - | - | Test with mocks |
| 58 | Implement DefenderRepository with async/await CRUD operations | 🔲 pending | - | - | Repository pattern |
| 59 | Write unit tests for DefenderRepository | 🔲 pending | - | - | Test CRUD operations |
| 60 | Implement search with Full-Text Search (FTS5) for performance | 🔲 pending | - | - | Fast text search |
| 61 | Add filtering with predicate-based queries and indexing | 🔲 pending | - | - | Optimized queries |

### Phase 7: ViewModels with Modern Swift (9 tasks)

| # | Task | Status | Started | Completed | Notes |
|---|------|--------|---------|-----------|-------|
| 62 | Create CalculatorViewModel with @Observable macro (not @Published) | 🔲 pending | - | - | Modern SwiftUI |
| 63 | Implement unidirectional data flow in CalculatorViewModel | 🔲 pending | - | - | Clean architecture |
| 64 | Write unit tests for CalculatorViewModel (mock dependencies) | 🔲 pending | - | - | Test state changes |
| 65 | Create SimulationViewModel with async task management | 🔲 pending | - | - | Background processing |
| 66 | Implement cancellation support for long-running simulations | 🔲 pending | - | - | Task.cancel() |
| 67 | Write unit tests for SimulationViewModel | 🔲 pending | - | - | Test async operations |
| 68 | Create LibraryViewModel with @Observable and pagination | 🔲 pending | - | - | Lazy loading |
| 69 | Implement clone functionality with transaction safety | 🔲 pending | - | - | Database transactions |
| 70 | Write unit tests for LibraryViewModel | 🔲 pending | - | - | Test pagination |

### Phase 8: SwiftUI Views - Performance Optimized (14 tasks)

| # | Task | Status | Started | Completed | Notes |
|---|------|--------|---------|-----------|-------|
| 71 | Design CalculatorView with minimal view hierarchy for performance | 🔲 pending | - | - | Reduce nesting |
| 72 | Extract reusable subviews to minimize body re-evaluation | 🔲 pending | - | - | Performance optimization |
| 73 | Implement form validation with real-time feedback | 🔲 pending | - | - | Input validation |
| 74 | Create WeaponEditorView with @Bindable for two-way binding | 🔲 pending | - | - | Form binding |
| 75 | Avoid expensive computations in view bodies (use @State caching) | 🔲 pending | - | - | Cache computed values |
| 76 | Create DefenderEditorView with accessibility labels | 🔲 pending | - | - | Accessibility first |
| 77 | Implement ResultsView with lazy loading for large datasets | 🔲 pending | - | - | LazyVStack |
| 78 | Create custom Chart view for histogram using Swift Charts framework | 🔲 pending | - | - | iOS 16+ Charts |
| 79 | Optimize chart rendering with data sampling for large datasets | 🔲 pending | - | - | Sample for performance |
| 80 | Create SimulationResultsView with progress indicators | 🔲 pending | - | - | Loading states |
| 81 | Implement LibraryBrowserView with LazyVStack for performance | 🔲 pending | - | - | Virtual scrolling |
| 82 | Add pull-to-refresh and pagination for library view | 🔲 pending | - | - | Infinite scroll |
| 83 | Create reusable components following component-driven design | 🔲 pending | - | - | DRY principle |
| 84 | Profile UI with Instruments 26 SwiftUI tool to identify bottlenecks | 🔲 pending | - | - | Performance profiling |

### Phase 9: Accessibility & UX (9 tasks)

| # | Task | Status | Started | Completed | Notes |
|---|------|--------|---------|-----------|-------|
| 85 | Write snapshot tests for all views using Swift Snapshot Testing | 🔲 pending | - | - | Visual regression |
| 86 | Implement VoiceOver support with accessibility identifiers | 🔲 pending | - | - | Screen reader support |
| 87 | Add Dynamic Type support with scaledFont modifier | 🔲 pending | - | - | Text scaling |
| 88 | Test accessibility with Accessibility Inspector | 🔲 pending | - | - | Verify a11y |
| 89 | Implement dark mode with adaptive colors (@Environment colorScheme) | 🔲 pending | - | - | Semantic colors |
| 90 | Create custom color palette with semantic naming | 🔲 pending | - | - | Colors.xcassets |
| 91 | Design app icon following iOS Human Interface Guidelines | 🔲 pending | - | - | HIG compliance |
| 92 | Create launch screen with minimal design for fast load | 🔲 pending | - | - | Quick launch |
| 93 | Add haptic feedback for user interactions using UIFeedbackGenerator | 🔲 pending | - | - | Tactile feedback |

### Phase 10: Documentation & Quality (12 tasks)

| # | Task | Status | Started | Completed | Notes |
|---|------|--------|---------|-----------|-------|
| 94 | Implement onboarding flow with privacy-focused messaging | 🔲 pending | - | - | First-run experience |
| 95 | Add inline documentation with Swift DocC format | 🔲 pending | - | - | Doc comments |
| 96 | Create architecture decision records (ADRs) for key decisions | 🔲 pending | - | - | Document rationale |
| 97 | Generate API documentation using Swift DocC | 🔲 pending | - | - | Build docs |
| 98 | Verify 80%+ code coverage with XCTest coverage reports | 🔲 pending | - | - | Coverage target |
| 99 | Perform static analysis with SwiftLint (zero warnings) | 🔲 pending | - | - | Code quality |
| 100 | Run security audit for sensitive data handling | 🔲 pending | - | - | Security review |
| 101 | Test performance with 1M simulation runs using XCTest performance tests | 🔲 pending | - | - | Performance benchmarks |
| 102 | Conduct UI testing for critical user flows with XCUITest | 🔲 pending | - | - | End-to-end tests |
| 103 | Profile memory usage with Instruments (Allocations & Leaks) | 🔲 pending | - | - | Memory profiling |
| 104 | Test on multiple iOS versions (iOS 16, 17, 18) | 🔲 pending | - | - | Compatibility testing |
| 105 | Verify database migration strategy works correctly | 🔲 pending | - | - | Migration tests |

### Phase 11: Final Delivery (4 tasks)

| # | Task | Status | Started | Completed | Notes |
|---|------|--------|---------|-----------|-------|
| 106 | Create comprehensive README with architecture diagrams | 🔲 pending | - | - | Project overview |
| 107 | Add CONTRIBUTING.md with coding standards | 🔲 pending | - | - | Contribution guidelines |
| 108 | Create LICENSE file (choose appropriate license) | 🔲 pending | - | - | Open source license |
| 109 | Commit and push final implementation | 🔲 pending | - | - | Release ready |

---

## 🧪 Testing Strategy (TDD Approach)

### Target: 80%+ Code Coverage

#### Unit Tests
- ✅ Domain Models (100% coverage target)
- ✅ Probability Engine (all hit/wound/save calculations)
- ✅ 18 Weapon Abilities (one test suite per ability)
- ✅ Monte Carlo Simulator (statistical accuracy)
- ✅ ViewModels (with mocked dependencies)

#### Integration Tests
- ✅ Database encryption/decryption
- ✅ Repository CRUD operations
- ✅ Search and filter with FTS5

#### Snapshot Tests
- ✅ All views in light/dark mode
- ✅ Different device sizes (iPhone SE, Pro, Pro Max)

#### Performance Tests
- ✅ 1M simulation runs < 10 seconds
- ✅ Database queries < 100ms
- ✅ UI rendering < 16ms per frame (60 FPS)

#### UI Tests (XCUITest)
- ✅ Critical flow: Calculate probabilities → View results
- ✅ Critical flow: Create weapon profile → Save → Load
- ✅ Critical flow: Run simulation → View histogram

---

## 🔒 Security Checklist

- [ ] Encryption keys stored in Keychain (hardware-backed)
- [ ] SQLCipher AES-256 encryption for database
- [ ] SecRandomCopyBytes for RNG (not arc4random)
- [ ] No hardcoded secrets or API keys
- [ ] iOS Data Protection API enabled (NSFileProtectionComplete)
- [ ] Secure key derivation with CryptoKit
- [ ] Security audit completed before release
- [ ] Privacy manifest file included (iOS 17+)

---

## ⚡ Performance Targets

| Metric | Target | Measurement Method |
|--------|--------|-------------------|
| App launch time | < 2 seconds | Instruments Time Profiler |
| 1M simulation runs | < 10 seconds | XCTest measure block |
| Database query | < 100ms | Instruments Core Data |
| UI frame rate | 60 FPS (16ms/frame) | Instruments SwiftUI |
| Memory usage | < 100MB typical | Instruments Allocations |
| Code coverage | > 80% | Xcode coverage report |
| Binary size | < 50MB | Xcode organizer |

---

## 📊 Best Practices Being Followed

### Modern SwiftUI (2025)
- ✅ @Observable macro instead of @Published
- ✅ @Bindable for two-way binding
- ✅ Unidirectional data flow
- ✅ Minimal view hierarchy
- ✅ Lazy loading (LazyVStack)
- ✅ Avoid expensive computations in view bodies

### SOLID Principles
- ✅ Single Responsibility Principle
- ✅ Open-Closed Principle (protocol-based abilities)
- ✅ Liskov Substitution Principle
- ✅ Interface Segregation Principle
- ✅ Dependency Inversion Principle

### Clean Architecture
- ✅ Repository pattern for data access
- ✅ Protocol-oriented design
- ✅ Dependency injection
- ✅ Service layer separation

### Security Best Practices
- ✅ Keychain for sensitive data
- ✅ SQLCipher database encryption
- ✅ Secure random number generation
- ✅ iOS Data Protection API

### Testing Best Practices
- ✅ Test-Driven Development (TDD)
- ✅ 80%+ code coverage target
- ✅ Test isolation and independence
- ✅ Mock dependencies for unit tests
- ✅ Performance testing with XCTest

---

## 🚨 AI Development Instructions

**READ THIS CAREFULLY BEFORE STARTING ANY TASK:**

1. **ALWAYS check this file first** before starting work
2. **Update task status** when you start and complete tasks
3. **Follow the architecture** outlined in this document
4. **Write tests first** (TDD approach) for business logic
5. **Target 80%+ code coverage** for all code
6. **Use protocols** for all dependencies to enable testing
7. **Follow SOLID principles** in all implementations
8. **Document your code** with Swift DocC comments
9. **Run SwiftLint** before committing (zero warnings)
10. **Update this plan** with any architecture decisions

### When Starting a New Task:
```markdown
1. Mark the task as "in_progress" in the table above
2. Add today's date in the "Started" column
3. Read the task description and notes carefully
4. Check dependencies (previous tasks that must be complete)
5. Write tests first (if applicable)
6. Implement the feature
7. Run tests and verify 80%+ coverage
8. Run SwiftLint and fix any warnings
9. Update task status to "completed"
10. Add completion date and any relevant notes
```

### When Blocked:
```markdown
1. Add "[BLOCKED]" tag to task status
2. Add detailed reason in Notes column
3. Document what needs to be resolved
4. Move to next available task if possible
```

---

## 📅 Project Milestones

| Milestone | Target Date | Tasks | Status |
|-----------|-------------|-------|--------|
| Project Setup Complete | 2025-11-08 | 1-5 | ✅ Complete |
| Domain Models Complete | TBD | 6-10 | Not Started |
| Probability Engine Complete | TBD | 11-17 | Not Started |
| All Weapon Abilities Complete | TBD | 18-40 | Not Started |
| Monte Carlo Simulation Complete | TBD | 41-49 | Not Started |
| Database & Repositories Complete | TBD | 50-61 | Not Started |
| ViewModels Complete | TBD | 62-70 | Not Started |
| UI Implementation Complete | TBD | 71-84 | Not Started |
| Accessibility & UX Complete | TBD | 85-93 | Not Started |
| Testing & Documentation Complete | TBD | 94-105 | Not Started |
| Final Release Ready | TBD | 106-109 | Not Started |

---

## 📖 Additional Documentation

- See `AI_DEVELOPMENT_GUIDE.md` for detailed AI development instructions
- See `README.md` for project overview
- See `CONTRIBUTING.md` for contribution guidelines
- See `docs/ADRs/` for architecture decision records

---

## 🔄 Change Log

| Date | Change | Author |
|------|--------|--------|
| 2025-11-08 | Initial plan created with 109 tasks | Claude |
| 2025-11-08 | Phase 1 complete: Foundation & Setup (5/109 tasks - 4.6%) | Claude |

---

**Remember**: This plan is a living document. Keep it updated as the project progresses!
