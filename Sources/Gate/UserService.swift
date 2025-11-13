//
//  UserService.swift
//  Gate
//
//  Copyright © 2025 m. All rights reserved.
//

import Foundation

/// Service responsible for managing user identity and cross-device synchronization
public final class UserService: ApplicationService {

    public static let shared = UserService()

    public var initializationPriority: Int { ServicePriority.core }

    private var userIDManager: UniversalUserID?
    private var cachedUserID: String?
    private var isConfigured = false

    private init() {}

    /// Configure the UserService with storage settings
    /// - Parameters:
    ///   - userDefaultsKey: The key to use for storing the user ID
    ///   - userDefaults: The UserDefaults instance to use (default: .standard)
    ///   - migrationKey: Optional key to migrate from (if different from userDefaultsKey)
    public func configure(
        userDefaultsKey: String,
        userDefaults: UserDefaults = .standard,
        migrationKey: String? = nil
    ) {
        guard !isConfigured else {
            print("⚠️ UserService already configured, ignoring duplicate configuration")
            return
        }

        userIDManager = UniversalUserID(
            userDefaultsKey: userDefaultsKey,
            userDefaults: userDefaults,
            migrationKey: migrationKey
        )
        isConfigured = true
    }

    public func initialize() async throws {
        guard let userIDManager = userIDManager else {
            fatalError("UserService.initialize() called before configure(). Call configure() first.")
        }

        let userResult = await userIDManager.getUserID()
        cachedUserID = userResult.id
        print("User ID: \(userResult.id) from \(userResult.source)")
    }

    // MARK: - Public Interface

    /// Get the current user ID (synchronous access after initialization)
    public func getCurrentUserID() -> String {
        guard let cachedUserID = cachedUserID else {
            fatalError("UserService.getCurrentUserID() called before initialization completed")
        }
        return cachedUserID
    }

    /// Get the full user ID with source information
    public func getUserIDWithSource() async -> (id: String, source: UniversalUserID.UserIDSource) {
        guard let userIDManager = userIDManager else {
            fatalError("UserService.getUserIDWithSource() called before configure(). Call configure() first.")
        }
        return await userIDManager.getUserID()
    }

    public func cleanup() async {
        // Remove any notification observers if needed
        // UniversalUserID manages its own cleanup
    }
}
