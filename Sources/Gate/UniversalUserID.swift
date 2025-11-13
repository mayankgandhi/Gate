//
//  UniversalUserID.swift
//  Gate
//
//  Copyright © 2025 m. All rights reserved.
//

import Foundation

/// Manages universal user ID across devices with configurable storage
public final class UniversalUserID {
    public enum UserIDSource {
        case generated
        case iCloudKeychain
        case migrated
    }

    private let userDefaultsKey: String
    private let userDefaults: UserDefaults
    private let migrationKey: String?

    /// Initialize UniversalUserID with configurable storage
    /// - Parameters:
    ///   - userDefaultsKey: The key to use for storing the user ID
    ///   - userDefaults: The UserDefaults instance to use (default: .standard)
    ///   - migrationKey: Optional key to migrate from (if different from userDefaultsKey)
    public init(
        userDefaultsKey: String,
        userDefaults: UserDefaults = .standard,
        migrationKey: String? = nil
    ) {
        self.userDefaultsKey = userDefaultsKey
        self.userDefaults = userDefaults
        self.migrationKey = migrationKey
    }

    public func getUserID() async -> (id: String, source: UserIDSource) {
        // Check if we have a stored user ID at the primary location
        if let existingID = userDefaults.string(forKey: userDefaultsKey) {
            return (id: existingID, source: .generated)
        }

        // Check if we need to migrate from an old key
        if let migrationKey = migrationKey,
           let migratedID = userDefaults.string(forKey: migrationKey) {
            // Migrate the ID to the new key
            userDefaults.set(migratedID, forKey: userDefaultsKey)
            print("✅ Migrated user ID from '\(migrationKey)' to '\(userDefaultsKey)'")
            return (id: migratedID, source: .migrated)
        }

        // Generate new UUID
        let newID = UUID().uuidString
        userDefaults.set(newID, forKey: userDefaultsKey)
        return (id: newID, source: .generated)
    }
}
