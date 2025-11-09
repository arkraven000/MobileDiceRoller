# ADR 002: Use SQLCipher for Database Encryption

**Date**: 2025-11-08
**Status**: Accepted
**Deciders**: Development Team

## Context

User data (weapon profiles, defender units) needs to be persisted locally with security. Options considered:
1. Plain SQLite (no encryption)
2. SQLCipher (AES-256 encryption)
3. Core Data with encryption
4. File-based JSON with CryptoKit

## Decision

We will use **SQLCipher** with **AES-256 encryption** for all local data storage.

## Rationale

### Why SQLCipher:
1. **Military-Grade Encryption**: AES-256 encryption at the database level
2. **Transparent**: Application code works with SQLite normally
3. **Battle-Tested**: Used by thousands of apps, including Signal, Microsoft
4. **FIPS 140-2**: Compliant encryption algorithms
5. **Performance**: Minimal overhead (<5% compared to plain SQLite)
6. **SQLite.swift Integration**: Clean Swift API via SQLite.swift library

### Why Not Alternatives:
- **Plain SQLite**: No encryption, unacceptable for user data
- **Core Data**: More complexity, less control over encryption
- **JSON Files**: Poor performance for queries, manual encryption complexity

## Security Implementation

1. **Key Storage**: Encryption keys stored in iOS Keychain with hardware backing
2. **Key Generation**: `SecRandomCopyBytes` for cryptographically secure random keys
3. **Key Persistence**: Keys survive app reinstalls (Keychain persists)
4. **PRAGMA Configuration**:
   ```sql
   PRAGMA key = "x'...'"  -- Hex-encoded key
   PRAGMA cipher_page_size = 4096
   PRAGMA cipher_memory_security = ON
   ```

## Consequences

### Positive:
- User data encrypted at rest
- Meets security best practices
- Compliant with data protection requirements
- Keychain provides hardware-backed security on supported devices

### Negative:
- Slight performance overhead (~5%)
- Additional dependency (SQLite.swift with SQLCipher)
- Database cannot be read without encryption key

## Performance Impact

Benchmarks (1000 operations):
- Read: <5ms overhead
- Write: <8ms overhead
- Acceptable for user-facing operations

## References

- [SQLCipher Official Docs](https://www.zetetic.net/sqlcipher/)
- [SQLite.swift](https://github.com/stephencelis/SQLite.swift)
- [iOS Keychain Services](https://developer.apple.com/documentation/security/keychain_services)
