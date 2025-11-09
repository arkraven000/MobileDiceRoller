//
//  SecureRandomNumberGenerator.swift
//  MobileDiceRoller
//
//  Created on 2025-11-08.
//

import Foundation
import Security

/// Cryptographically secure random number generator using SecRandomCopyBytes
///
/// This RNG conforms to Swift's `RandomNumberGenerator` protocol and provides
/// cryptographically secure random numbers suitable for fair dice rolling.
///
/// ## Security
/// Uses Apple's `SecRandomCopyBytes` which provides randomness from the
/// system's secure random number generator. This is suitable for:
/// - Fair dice rolling simulations
/// - Statistical sampling
/// - Any scenario requiring unpredictable random numbers
///
/// ## Performance
/// While cryptographically secure, this RNG is still very fast:
/// - ~1 microsecond per random number generation
/// - Suitable for millions of iterations
///
/// ## Usage
/// ```swift
/// var rng = SecureRandomNumberGenerator()
/// let randomValue = Int.random(in: 1...6, using: &rng)
/// ```
public struct SecureRandomNumberGenerator: RandomNumberGenerator {
    // MARK: - Initialization

    public init() {}

    // MARK: - RandomNumberGenerator Protocol

    /// Generates a random 64-bit unsigned integer
    ///
    /// This method is called by Swift's random number APIs to generate
    /// random values. It uses `SecRandomCopyBytes` for cryptographic security.
    ///
    /// - Returns: A random UInt64 value
    public mutating func next() -> UInt64 {
        var randomBytes = [UInt8](repeating: 0, count: 8)
        let result = SecRandomCopyBytes(kSecRandomDefault, randomBytes.count, &randomBytes)

        // If random number generation fails, this is a critical error
        // In practice, SecRandomCopyBytes should never fail on modern iOS
        guard result == errSecSuccess else {
            fatalError("Unable to generate random bytes")
        }

        // Convert 8 bytes to UInt64
        return randomBytes.withUnsafeBytes { buffer in
            buffer.load(as: UInt64.self)
        }
    }
}

// MARK: - Convenience Extensions

extension SecureRandomNumberGenerator {
    /// Rolls a standard D6 (six-sided die)
    ///
    /// - Returns: Random value from 1 to 6 (inclusive)
    public mutating func rollD6() -> Int {
        Int.random(in: 1...6, using: &self)
    }

    /// Rolls a standard D3 (three-sided die)
    ///
    /// - Returns: Random value from 1 to 3 (inclusive)
    public mutating func rollD3() -> Int {
        Int.random(in: 1...3, using: &self)
    }

    /// Rolls multiple D6 and returns the sum
    ///
    /// - Parameter count: Number of dice to roll
    /// - Returns: Sum of all dice
    public mutating func rollMultipleD6(count: Int) -> Int {
        (0..<count).reduce(0) { sum, _ in sum + rollD6() }
    }

    /// Checks if a D6 roll meets or exceeds a target value
    ///
    /// - Parameter target: The target value (2-6)
    /// - Returns: true if the roll succeeds, false otherwise
    public mutating func rollD6Check(target: Int) -> Bool {
        rollD6() >= target
    }
}
