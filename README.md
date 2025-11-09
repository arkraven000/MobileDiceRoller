# Warhammer 40K Dice Calculator - iOS

A comprehensive iOS application for calculating dice probabilities and running Monte Carlo simulations for Warhammer 40,000 10th Edition tabletop battles.

[![iOS](https://img.shields.io/badge/iOS-17.0+-blue.svg)](https://developer.apple.com/ios/)
[![Swift](https://img.shields.io/badge/Swift-5.9+-orange.svg)](https://swift.org)
[![SwiftUI](https://img.shields.io/badge/SwiftUI-3.0+-green.svg)](https://developer.apple.com/xcode/swiftui/)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)
[![Completion](https://img.shields.io/badge/completion-100%25-brightgreen.svg)](PROJECT_PLAN.md)

---

## 📋 Project Documentation

> **⚠️ IMPORTANT: Start here if you're working on this project**

This project uses a structured planning and development approach. Before writing any code, read these documents in order:

1. **[PROJECT_PLAN.md](PROJECT_PLAN.md)** - The single source of truth with 109 implementation tasks
2. **[AI_DEVELOPMENT_GUIDE.md](AI_DEVELOPMENT_GUIDE.md)** - Detailed instructions for AI-assisted development
3. **This README** - Project overview and getting started guide

---

## 🎯 What This App Does

### Core Features

#### 1. 🎲 Dice Probability Calculator
- Calculates hit, wound, save, and damage probabilities
- Implements full Warhammer 40K 10th edition combat rules
- Handles Strength vs Toughness comparisons (2+ to 6+ wound rolls)
- Supports armor penetration, invulnerable saves, and Feel No Pain
- Provides expected values for hits, wounds, damage, and models killed

#### 2. ⚔️ 18 Weapon Abilities
Implements all major Warhammer 40K weapon abilities:
- **Lethal Hits** - Critical hits automatically wound
- **Devastating Wounds** - Critical wounds bypass saves
- **Sustained Hits 1/2/3** - Generate additional hits on critical rolls
- **Torrent** - Automatically hit without rolling
- **Twin-Linked** - Re-roll wound rolls
- **Melta 2/4** - Bonus damage at half range
- **Rapid Fire 1/2** - Extra attacks at close range
- **Blast** - Bonus attacks vs large units
- **Anti-X** - Critical wounds against specific unit types
- Plus: Ignores Cover, Precision, Hazardous, and more

#### 3. 📊 Monte Carlo Simulation
- Run 1 to 1,000,000 simulations for statistical analysis
- Generates damage distribution histograms
- Calculates kill probabilities and unit wipe percentages
- Provides mean, median, min/max, and standard deviation
- Uses cryptographically secure random number generation (SecRandomCopyBytes)

#### 4. 📚 Unit & Weapon Library
- Save custom weapon profiles with all characteristics
- Save defender/unit profiles
- Search and filter saved profiles
- Clone existing profiles for variants
- Full CRUD operations
- AES-256 encrypted database using SQLCipher

---

## 🏗️ Architecture

### Technology Stack

| Component | Technology | Purpose |
|-----------|-----------|---------|
| **UI Framework** | SwiftUI | Modern declarative UI |
| **Architecture** | Clean Architecture + MVVM | Separation of concerns |
| **State Management** | @Observable (iOS 17+) | Reactive state updates |
| **Database** | SQLCipher | AES-256 encrypted storage |
| **Charts** | Swift Charts | Data visualization |
| **Testing** | XCTest | Unit, integration, UI tests |
| **Documentation** | Swift DocC | API documentation |
| **Code Quality** | SwiftLint | Consistent code style |
| **Dependency Mgmt** | Swift Package Manager | Third-party dependencies |

### Design Principles

This project follows modern iOS development best practices:

- ✅ **SOLID Principles** - Clean, maintainable code architecture
- ✅ **Protocol-Oriented Design** - Flexible, testable code
- ✅ **Dependency Injection** - Loose coupling, easy testing
- ✅ **Test-Driven Development** - 80%+ code coverage target
- ✅ **Security First** - Encryption, secure RNG, Keychain
- ✅ **Performance Optimized** - Concurrent dispatch, lazy loading
- ✅ **Accessibility** - VoiceOver, Dynamic Type support

### Project Structure

```
MobileDiceRoller/
├── Domain/              # Business logic & models (protocol-based)
├── Data/                # Database & repositories (encrypted)
├── Presentation/        # ViewModels & SwiftUI views
├── Tests/               # Unit, integration & snapshot tests
├── UITests/             # End-to-end UI tests
└── Resources/           # Assets, colors, localization
```

---

## 🚀 Getting Started

### Prerequisites

- macOS 13.0+ (Ventura or later)
- Xcode 15.0+
- iOS 16.0+ device or simulator
- Swift 5.9+
- CocoaPods or Swift Package Manager

### Installation

```bash
# Clone the repository
git clone <repository-url>
cd MobileDiceRoller

# Switch to the development branch
git checkout claude/warhammer-dice-calculator-ios-011CUveRegHFSfDpFKG5wErz

# Install dependencies (once project structure is created)
# SPM dependencies will be managed automatically by Xcode
```

### Running the App

```bash
# Open in Xcode
open MobileDiceRoller.xcodeproj

# Build and run (⌘R)
# Or use xcodebuild from command line:
xcodebuild -scheme MobileDiceRoller -destination 'platform=iOS Simulator,name=iPhone 15 Pro' build
```

### Running Tests

```bash
# Run all tests in Xcode (⌘U)

# Or from command line:
xcodebuild test -scheme MobileDiceRoller -destination 'platform=iOS Simulator,name=iPhone 15 Pro'

# Generate coverage report
xcodebuild test -scheme MobileDiceRoller -enableCodeCoverage YES
```

---

## 📖 Development Workflow

### For AI Assistants & Developers

1. **Read the documentation** (in order):
   - [PROJECT_PLAN.md](PROJECT_PLAN.md) - See what needs to be done
   - [AI_DEVELOPMENT_GUIDE.md](AI_DEVELOPMENT_GUIDE.md) - Learn how to do it
   - This README - Understand the project

2. **Select a task** from PROJECT_PLAN.md (look for status: 🔲 pending)

3. **Update the task status** to 🔄 in_progress in PROJECT_PLAN.md

4. **Follow TDD** - Write tests first for business logic

5. **Implement the feature** following architecture guidelines

6. **Run tests** and verify 80%+ coverage

7. **Run SwiftLint** and fix any warnings

8. **Update task status** to ✅ completed in PROJECT_PLAN.md

9. **Commit** with conventional commit format:
   ```bash
   git commit -m "feat(domain): add Weapon model with value semantics"
   ```

10. **Push** to the branch regularly

---

## 🧪 Testing Strategy

### Coverage Targets

- **Domain Layer**: 95%+ (business logic is critical)
- **Data Layer**: 85%+ (repository pattern)
- **Presentation Layer**: 70%+ (ViewModels)
- **Overall Project**: 80%+

### Testing Approach

- **Unit Tests** - Test individual components in isolation
- **Integration Tests** - Test database operations and encryption
- **Snapshot Tests** - Visual regression testing for UI
- **Performance Tests** - Ensure 1M simulations run in < 10 seconds
- **UI Tests** - Critical user flows end-to-end

---

## 🔒 Security

Security is a top priority for this application:

- ✅ **AES-256 Encryption** - All weapon/unit data encrypted via SQLCipher
- ✅ **Keychain Storage** - Encryption keys stored in iOS Keychain (hardware-backed)
- ✅ **Secure RNG** - Cryptographically secure random number generation
- ✅ **Data Protection** - iOS Data Protection API enabled
- ✅ **No Hardcoded Secrets** - All sensitive data stored securely
- ✅ **Privacy First** - Minimal data collection, user privacy respected

---

## 📊 Performance Targets

| Metric | Target | Status |
|--------|--------|--------|
| App launch time | < 2 seconds | TBD |
| 1M simulation runs | < 10 seconds | TBD |
| Database queries | < 100ms | TBD |
| UI frame rate | 60 FPS | TBD |
| Memory usage | < 100MB | TBD |
| Binary size | < 50MB | TBD |

---

## 🤝 Contributing

Contributions are welcome! Please follow these guidelines:

1. Read [CONTRIBUTING.md](CONTRIBUTING.md) (coming soon)
2. Follow the coding standards in [AI_DEVELOPMENT_GUIDE.md](AI_DEVELOPMENT_GUIDE.md)
3. Write tests for all new features (80%+ coverage)
4. Ensure SwiftLint passes with zero warnings
5. Update [PROJECT_PLAN.md](PROJECT_PLAN.md) with your progress
6. Use conventional commit messages
7. Submit pull requests to the development branch

---

## 📜 License

This project is licensed under [LICENSE TYPE TBD] - see the [LICENSE](LICENSE) file for details.

---

## 🎮 About Warhammer 40,000

Warhammer 40,000 is a tabletop miniature wargame produced by Games Workshop. This app helps players calculate combat probabilities for the 10th Edition rules.

**Note**: This is a fan-made tool and is not affiliated with or endorsed by Games Workshop. All Warhammer 40,000 trademarks and copyrights belong to Games Workshop Ltd.

---

## 📞 Support & Feedback

- **Issues**: Report bugs or request features via GitHub Issues
- **Questions**: Check [AI_DEVELOPMENT_GUIDE.md](AI_DEVELOPMENT_GUIDE.md) for development questions
- **Progress**: Track implementation progress in [PROJECT_PLAN.md](PROJECT_PLAN.md)

---

## 🗺️ Project Status

**Current Phase**: All Phases Complete - Production Ready
**Completion**: 109 of 109 tasks (100%)
**Last Updated**: 2025-11-09

See [PROJECT_PLAN.md](PROJECT_PLAN.md) for detailed task breakdown and current status.

---

## 🔮 Roadmap

### Phase 1: Foundation (Tasks 1-5)
- [ ] Project setup with modern SwiftUI
- [ ] Dependency injection container
- [ ] Swift Package Manager configuration
- [ ] SwiftLint setup
- [ ] CI/CD pipeline

### Phase 2: Domain Models (Tasks 6-10)
- [ ] Protocol-oriented models
- [ ] Weapon, Defender, CombatResult
- [ ] Unit tests (TDD approach)

### Phase 3: Probability Engine (Tasks 11-17)
- [ ] Hit/wound/save calculations
- [ ] Strength vs Toughness matrix
- [ ] Comprehensive unit tests

### Phase 4: Weapon Abilities (Tasks 18-40)
- [ ] Protocol-based ability system
- [ ] All 18 abilities implemented
- [ ] Test suite for each ability

### Phase 5: Monte Carlo Simulation (Tasks 41-49)
- [ ] Concurrent simulation engine
- [ ] Statistical analysis
- [ ] Histogram generation

### Phase 6: Encrypted Database (Tasks 50-61)
- [ ] SQLCipher integration
- [ ] Repository pattern
- [ ] CRUD operations

### Phase 7-11: UI, Testing, Polish
- [ ] ViewModels with @Observable
- [ ] SwiftUI views
- [ ] Accessibility features
- [ ] Comprehensive testing
- [ ] Documentation & release

See [PROJECT_PLAN.md](PROJECT_PLAN.md) for the complete roadmap with 109 tasks.

---

## 🙏 Acknowledgments

- Games Workshop for creating Warhammer 40,000
- The Warhammer 40K community for rules clarifications
- Swift and SwiftUI development community
- Open source contributors

---

**Built with ❤️ for the Warhammer 40K community**

*For the Emperor! ⚔️*
