//
//  TokenRepository.swift
//  
//
//  Created by Ilian Konchev on 26.11.21.
//

import Fetcher
import Foundation
import SwiftKeychainWrapper
import UIKit
import ZeplinKit

/// A repository actor to manage the Zeplin tokens
public actor TokenRepository {
    private let key: String
    private let accessibility: KeychainItemAccessibility?
    private let keychain: KeychainWrapper

    private let refreshTokenURL: ZeplinAPIURL
    private var getTokenTask: Task<Token?, Error>?
    private var refreshTokenTask: Task<Token?, Error>?
    private var updateTokenTask: Task<Token?, Error>?

    /// Initialize a token repository
    /// - Parameters:
    ///   - key: The key to store the token to
    ///   - accessibility: The accessibility level of the stored data
    ///   - serviceName: The name of the service to set for the keychain item
    ///   - appTarget: The app target whose group identifier is going be used for setting the access group
    public init(key: String,
                accessibility: KeychainItemAccessibility? = nil,
                serviceName: String,
                appTarget: AppTarget,
                configuration: ZeplinAPIConfiguration) {
        self.keychain = KeychainWrapper(serviceName: serviceName, accessGroup: appTarget.groupIdentifier)
        self.key = key
        self.accessibility = accessibility
        self.refreshTokenURL = ZeplinAPIURL.refreshToken(configuration)
    }

    @MainActor
    private func isProtectedDataAvailable() -> Bool {
        UIApplication.shared.isProtectedDataAvailable
    }

    /// Stores the token to the keychain without any modifications
    /// - Parameters:
    ///   - token: The token to store
    ///   - logger: A logger to log actions to
    @discardableResult
    public func updateToken(to token: Token?, logger: FetcherLogger?) async throws -> Token? {
        if let handle = updateTokenTask {
            return try await handle.value
        }

        let task = Task { () throws -> Token? in
            defer { updateTokenTask = nil }
            var attempt = 0
            while attempt < 5 {
                if await isProtectedDataAvailable() {
                    guard token != nil, let data = try? JSONEncoder().encode(token) else {
                        keychain.removeObject(forKey: key)
                        await logger?.logMessage("Storing empty token done")
                        return token
                    }
                    keychain.set(data, forKey: key, withAccessibility: accessibility)
                    await logger?.logMessage("Storing token done")
                    return token
                } else {
                    try await Task.sleep(nanoseconds: 1_000_000_000)
                    attempt += 1
                }
            }
            throw APIError.protectedDataUnavailable
        }

        updateTokenTask = task
        return try await task.value
    }

    /// Attempts to refresh the token
    /// - Parameters:
    ///   - token: A token with a non-expired refreshToken
    ///   - fetcher: An instance of `Fetcher` to use for making the URL request
    /// - Returns: An updated refresh token
    @discardableResult
    public func refreshToken(_ token: Token?, using fetcher: Fetcher) async throws -> Token? {
        if let handle = refreshTokenTask {
            return try await handle.value
        }

        if let handle = updateTokenTask {
           return try await handle.value
        }

        let logger = fetcher.environment.apiErrorsLogger
        let environment = fetcher.environment

        let task = Task { () throws -> Token? in
            defer { refreshTokenTask = nil }
            var attempt = 0
            while attempt < 5 {
                if await isProtectedDataAvailable() {
                    await logger?.logMessage("Refreshing token")
                    let responseToken: Token? = try await fetcher.fetch(refreshTokenURL, token: token)
                    await logger?.logMessage("Got fresh token, storing")
                    return try await environment.updateToken(to: responseToken, logger: logger)
                } else {
                    try await Task.sleep(nanoseconds: 1_000_000_000)
                    attempt += 1
                }
            }
            throw APIError.protectedDataUnavailable
        }

        refreshTokenTask = task
        return try await task.value
    }

    /// Gets the current token
    /// - Parameter logger: A logger to log actions on
    /// - Returns: An optional token
    public func getToken(logger: FetcherLogger?) async throws -> Token? {
        if let handle = refreshTokenTask {
            return try await handle.value
        }

        if let handle = updateTokenTask {
            return try await handle.value
        }

        if let handle = getTokenTask {
            return try await handle.value
        }

        let task = Task { () throws -> Token? in
            defer { getTokenTask = nil }
            var attempt = 0
            while attempt < 5 {
                if await isProtectedDataAvailable() {
                    guard let data = keychain.data(forKey: key, withAccessibility: accessibility),
                          let token = try? JSONDecoder().decode(Token.self, from: data)
                    else {
                        await logger?.logMessage("Unable to decode the token from the keychain, returning nil.")
                        return nil
                    }
                    return token
                } else {
                    try await Task.sleep(nanoseconds: 1_000_000_000)
                    attempt += 1
                }
            }
            throw APIError.protectedDataUnavailable
        }

        getTokenTask = task
        return try await task.value
    }
}
