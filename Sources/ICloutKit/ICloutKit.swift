//
//  ICloutKit.swift
//
//
//  Created by Kamaal M Farah on 23/02/2021.
//

import CloudKit

/// CloudKit helper
public struct ICloutKit {
    internal let container: CloutContainerable
    internal let database: CloutDatabasable

    /// Create an instance from the provided value.
    /// - Parameters:
    ///   - containerID: ID of the cloudkit container
    ///   - databaseType: Access control of the container
    public init(containerID: String, databaseType: DatabaseType) {
        let container = CloutContainer(containerID: containerID)
        self.container = container
        switch databaseType {
        case .public: self.database = container.publicCloudDatabase
        case .private: self.database = container.privateCloudDatabase
        case .shared: self.database = container.sharedCloudDatabase
        }
    }

    internal init(container: CloutContainerable, database: CloutDatabasable) {
        self.container = container
        self.database = database
    }

    /// Access control of the container
    public enum DatabaseType {
        case `public`
        case shared
        case `private`
    }

    public enum Errors: Error {
        case recordMissing
        case subscriptionMissing
    }

    public enum AccountErrors: Error {
        case accountStatusCouldNotDetermine
        case accountStatusNoAccount
        case accountStatusRestricted
        case accountStatusUnknown
        case accountTemporarilyUnavailable
    }

    public enum CloudKitErrors: Error {
        case cloudKitNotAuthenticated
        case cloudKitNetworkError
        case cloudKitQuotaExeded
    }
}
