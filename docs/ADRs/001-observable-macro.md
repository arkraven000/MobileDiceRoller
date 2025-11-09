# ADR 001: Use @Observable Macro Instead of @Published

**Date**: 2025-11-08
**Status**: Accepted
**Deciders**: Development Team

## Context

SwiftUI provides two main patterns for reactive state management:
1. `@Published` properties with `ObservableObject`
2. `@Observable` macro (iOS 17+)

## Decision

We will use the `@Observable` macro for all ViewModels instead of `@Published` with `ObservableObject`.

## Rationale

### Advantages of @Observable:
1. **Less Boilerplate**: No need to conform to `ObservableObject` or mark every property with `@Published`
2. **Better Performance**: Only tracks accessed properties, not all published properties
3. **Cleaner Code**: More intuitive Swift code without property wrappers everywhere
4. **Modern Swift**: Leverages Swift 5.9+ macro system
5. **Automatic Tracking**: Compiler automatically determines which properties need observation

### Trade-offs:
- Requires iOS 17.0+ (acceptable for new project in 2025)
- Developers must be familiar with modern SwiftUI patterns

## Consequences

### Positive:
- ViewModels are simpler and more readable
- Better performance with selective property observation
- Future-proof architecture aligned with SwiftUI direction

### Negative:
- Minimum iOS version increased from 16.0 to 17.0
- Some older SwiftUI patterns don't apply

## Example

```swift
// Before (@Published)
class ViewModel: ObservableObject {
    @Published var count: Int = 0
    @Published var name: String = ""
}

// After (@Observable)
@Observable
class ViewModel {
    var count: Int = 0
    var name: String = ""
}
```

## References

- [Swift Evolution SE-0395: Observation](https://github.com/apple/swift-evolution/blob/main/proposals/0395-observability.md)
- [WWDC 2023: Discover Observation in SwiftUI](https://developer.apple.com/videos/play/wwdc2023/10149/)
