//
//  ICloutKit.swift
//
//
//  Created by Kamaal M Farah on 23/02/2021.
//

import CloudKit

protocol CloutDatabasable {
    func save(_ record: CKRecord, completion: @escaping (_ record: CKRecord?, _ error: Error?) -> Void)
}

protocol CloutContainerable {
    var publicCloudDatabase: CloutDatabasable { get }
    var privateCloudDatabase: CloutDatabasable { get }
    var sharedCloudDatabase: CloutDatabasable { get }
}

extension CKModifyRecordsOperation {
    func setDatabase(enabled: Bool = true, database: CKDatabase?) {
        if enabled, let database = database {
            self.database = database
        }
    }
}

struct CloutDatabase: CloutDatabasable {

    internal let database: CKDatabase

    init(database: CKDatabase) {
        self.database = database
    }

    func save(_ record: CKRecord, completion: @escaping (CKRecord?, Error?) -> Void) {
        database.save(record, completionHandler: completion)
    }
}

struct CloutContainer: CloutContainerable {

    private let container: CKContainer

    init(containerID: String) {
        self.container = CKContainer(identifier: containerID)
    }

    var publicCloudDatabase: CloutDatabasable {
        CloutDatabase(database: container.publicCloudDatabase)
    }

    var privateCloudDatabase: CloutDatabasable {
        CloutDatabase(database: container.privateCloudDatabase)
    }
    
    var sharedCloudDatabase: CloutDatabasable {
        CloutDatabase(database: container.sharedCloudDatabase)
    }
}

/// CloudKit helper
public struct ICloutKit {
    private let container: CloutContainerable
    private let database: CloutDatabasable

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

    /// Access control of the container
    public enum DatabaseType {
        case `public`
        case shared
        case `private`
    }

    /// Save record to iCloud container
    /// - Parameters:
    ///   - record: Record to save
    ///   - completion:
    ///     - Success: The record to save, or nil if CloudKit can’t save the record.
    ///     - Failure: An error if a problem occurs, or nil if CloudKit successfully saves the record.
    public func save(_ record: CKRecord, completion: @escaping (Result<CKRecord?, Error>) -> Void) {
        getAccountStatus { (result: Result<Bool, Error>) in
            switch result {
            case .failure(let failure): completion(.failure(failure))
            case .success:
                database.save(record) { (record: CKRecord?, error: Error?) in
                    if let error = error {
                        completion(.failure(error))
                        return
                    }
                    completion(.success(record))
                }
            }
        }
    }

    @available(iOS 15.0.0, macOS 12.0.0, *)
    public func save(_ record: CKRecord) async throws -> CKRecord? {
        return try await withCheckedThrowingContinuation { continuation in
            save(record) { result in
                switch result {
                case .failure(let failure): return continuation.resume(throwing: failure)
                case .success(let success): return continuation.resume(returning: success)
                }
            }
        }
    }

    public func saveMultiple(_ records: [CKRecord], completion: @escaping (Result<[CKRecord], Error>) -> Void) {
        guard !records.isEmpty else {
            completion(.success(records))
            return
        }
        getAccountStatus { (result: Result<Bool, Error>) in
            switch result {
            case .failure(let failure): completion(.failure(failure))
            case .success:
                let modification = CKModifyRecordsOperation(recordsToSave: records, recordIDsToDelete: nil)
//                modification.setDatabase(enabled: , database: )
                modification.database = database
                let queue = OperationQueue()
                queue.addOperations([modification], waitUntilFinished: false)
                modification.modifyRecordsCompletionBlock = { (savedRecords, _, error)  in
                    if let error = error {
                        completion(.failure(error))
                        return
                    }
                    guard let savedRecords = savedRecords else {
                        completion(.failure(Errors.recordMissing))
                        return
                    }
                    completion(.success(savedRecords))
                }
            }
        }
    }

    @available(iOS 15.0.0, macOS 12.0.0, *)
    public func saveMultiple(_ records: [CKRecord]) async throws -> [CKRecord] {
        return try await withCheckedThrowingContinuation { continuation in
            saveMultiple(records) { result in
                switch result {
                case .failure(let failure): return continuation.resume(throwing: failure)
                case .success(let success): return continuation.resume(returning: success)
                }
            }
        }
    }

    public func delete(_ record: CKRecord, completion: @escaping (Result<CKRecord.ID, Error>) -> Void) {
        getAccountStatus { (result: Result<Bool, Error>) in
            switch result {
            case .failure(let failure): completion(.failure(failure))
            case .success:
                database.delete(withRecordID: record.recordID) { (recordID: CKRecord.ID?, error: Error?) in
                    if let error = error {
                        completion(.failure(error))
                        return
                    }
                    guard let recordID = recordID else {
                        completion(.failure(Errors.recordMissing))
                        return
                    }
                    completion(.success(recordID))
                }
            }
        }
    }

    @available(iOS 15.0.0, macOS 12.0.0, *)
    public func delete(_ record: CKRecord) async throws -> CKRecord.ID {
        return try await withCheckedThrowingContinuation({ continuation in
            delete(record) { result in
                switch result {
                case .failure(let failure): return continuation.resume(throwing: failure)
                case .success(let success): return continuation.resume(returning: success)
                }
            }
        })
    }

    public func deleteMultiple(_ records: [CKRecord], completion: @escaping (Result<[CKRecord], Error>) -> Void) {
        guard !records.isEmpty else {
            completion(.success(records))
            return
        }
        getAccountStatus { (result: Result<Bool, Error>) in
            switch result {
            case .failure(let failure): completion(.failure(failure))
            case .success:
                let modification = CKModifyRecordsOperation(recordsToSave: nil,
                                                            recordIDsToDelete: records.map(\.recordID))
                modification.database = database
                let queue = OperationQueue()
                queue.addOperations([modification], waitUntilFinished: false)
                modification.modifyRecordsCompletionBlock = { (savedRecords, _, error)  in
                    if let error = error {
                        completion(.failure(error))
                        return
                    }
                    guard let savedRecords = savedRecords else {
                        completion(.failure(Errors.recordMissing))
                        return
                    }
                    completion(.success(savedRecords))
                }
            }
        }
    }

    @available(iOS 15.0.0, macOS 12.0.0, *)
    public func deleteMultiple(_ records: [CKRecord]) async throws -> [CKRecord] {
        return try await withCheckedThrowingContinuation({ continuation in
            deleteMultiple(records) { result in
                switch result {
                case .failure(let failure): return continuation.resume(throwing: failure)
                case .success(let success): return continuation.resume(returning: success)
                }
            }
        })
    }

    public func subscribe(toType objectType: String,
                          by predicate: NSPredicate,
                          completion: @escaping (Result<CKSubscription, Error>) -> Void) {
        _subscribe(toType: objectType, by: predicate, completion: completion)
    }

    @available(iOS 15.0.0, macOS 12.0.0, *)
    public func subscribe(toType objectType: String, by predicate: NSPredicate) async throws -> CKSubscription {
        return try await withCheckedThrowingContinuation({ continuation in
            subscribe(toType: objectType, by: predicate) { result in
                switch result {
                case .failure(let failure): return continuation.resume(throwing: failure)
                case .success(let success): return continuation.resume(returning: success)
                }
            }
        })
    }

    public func fetchAllSubscriptions(completion: @escaping (Result<[CKSubscription], Error>) -> Void) {
        getAccountStatus { (result: Result<Bool, Error>) in
            switch result {
            case .failure(let failure): completion(.failure(failure))
            case .success:
                database.fetchAllSubscriptions { (subscriptions: [CKSubscription]?, error: Error?) in
                    if let error = error {
                        completion(.failure(error))
                        return
                    }
                    guard let subscriptions = subscriptions else {
                        completion(.failure(Errors.subscriptionMissing))
                        return
                    }
                    completion(.success(subscriptions))
                }
            }
        }
    }

    @available(iOS 15.0.0, macOS 12.0.0, *)
    public func fetchAllSubscriptions() async throws -> [CKSubscription] {
        return try await withCheckedThrowingContinuation({ continuation in
            fetchAllSubscriptions { result in
                switch result {
                case .failure(let failure): return continuation.resume(throwing: failure)
                case .success(let success): return continuation.resume(returning: success)
                }
            }
        })
    }

    public func fetch(ofType objectType: String,
                      by predicate: NSPredicate,
                      completion: @escaping (Result<[CKRecord], Error>) -> Void) {
        _fetch(ofType: objectType, by: predicate, completion: completion)
    }

    @available(iOS 15.0.0, macOS 12.0.0, *)
    public func fetch(ofType objectType: String, by predicate: NSPredicate) async throws -> [CKRecord] {
        return try await withCheckedThrowingContinuation({ continuation in
            fetch(ofType: objectType, by: predicate) { result in
                switch result {
                case .failure(let failure): return continuation.resume(throwing: failure)
                case .success(let success): return continuation.resume(returning: success)
                }
            }
        })
    }

    public func fetchUserID(completion: @escaping (Result<String, Error>) -> Void) {
        getAccountStatus { (result: Result<Bool, Error>) in
            switch result {
            case .failure(let failure): completion(.failure(failure))
            case .success:
                container.fetchUserRecordID { (recordID: CKRecord.ID?, error: Error?) in
                    if let error = error {
                        completion(.failure(error))
                        return
                    }
                    guard let recordID = recordID else {
                        completion(.failure(Errors.recordMissing))
                        return
                    }
                    completion(.success(recordID.recordName))
                }
            }
        }
    }

    @available(iOS 15.0.0, macOS 12.0.0, *)
    public func fetchUserID() async throws -> String {
        return try await withCheckedThrowingContinuation({ continuation in
            fetchUserID { result in
                switch result {
                case .failure(let failure): return continuation.resume(throwing: failure)
                case .success(let success): return continuation.resume(returning: success)
                }
            }
        })
    }

    private func _subscribe(toType objectType: String,
                            by predicate: NSPredicate,
                            completion: @escaping (Result<CKSubscription, Error>) -> Void) {
        getAccountStatus { (result: Result<Bool, Error>) in
            switch result {
            case .failure(let failure): completion(.failure(failure))
            case .success:
                let subscriptionOptions: CKQuerySubscription.Options = [
                    .firesOnRecordCreation,
                    .firesOnRecordDeletion,
                    .firesOnRecordUpdate
                ]
                let subscriptionQuery = CKQuerySubscription(recordType: objectType,
                                                            predicate: predicate,
                                                            options: subscriptionOptions)

                let notification = CKSubscription.NotificationInfo()
                notification.shouldSendContentAvailable = true
                subscriptionQuery.notificationInfo = notification

                database.save(subscriptionQuery) { (subscription: CKSubscription?, error: Error?) in
                    if let error = error {
                        completion(.failure(error))
                        return
                    }
                    guard let subscription = subscription else {
                        completion(.failure(Errors.subscriptionMissing))
                        return
                    }
                    completion(.success(subscription))
                }
            }
        }
    }

    private func _fetch(ofType objectType: String,
                        by predicate: NSPredicate,
                        completion: @escaping (Result<[CKRecord], Error>) -> Void) {
        getAccountStatus { (result: Result<Bool, Error>) in
            switch result {
            case .failure(let failure): completion(.failure(failure))
            case .success: handleFetchAvailable(objectType: objectType, predicate: predicate, completion: completion)
            }
        }
    }

    public func getAccountStatus(completion: @escaping (Result<Bool, Error>) -> Void) {
        container.accountStatus { (status: CKAccountStatus, error: Error?) in
            if let error = error as? CKError {
                switch error.code {
                case .notAuthenticated: completion(.failure(CloudKitErrors.cloudKitNotAuthenticated))
                case .networkFailure, .networkUnavailable: completion(.failure(CloudKitErrors.cloudKitNetworkError))
                case .quotaExceeded: completion(.failure(CloudKitErrors.cloudKitQuotaExeded))
                default: completion(.failure(error))
                }
                return
            }
            switch status {
            case .available: completion(.success(true))
            case .couldNotDetermine: completion(.failure(AccountErrors.accountStatusCouldNotDetermine))
            case .noAccount: completion(.failure(AccountErrors.accountStatusNoAccount))
            case .restricted: completion(.failure(AccountErrors.accountStatusRestricted))
            case .temporarilyUnavailable: completion(.failure(AccountErrors.accountTemporarilyUnavailable))
            @unknown default: completion(.failure(AccountErrors.accountStatusUnknown))
            }
        }
    }

    @available(iOS 15.0.0, macOS 12.0.0, *)
    public func getAccountStatus() async throws -> Bool {
        return try await withCheckedThrowingContinuation({ continuation in
            getAccountStatus { result in
                switch result {
                case .failure(let failure): return continuation.resume(throwing: failure)
                case .success(let success): return continuation.resume(returning: success)
                }
            }
        })
    }

    private func handleFetchAvailable(objectType: String,
                                      predicate: NSPredicate,
                                      completion: @escaping (Result<[CKRecord], Error>) -> Void) {
        let query = CKQuery(recordType: objectType, predicate: predicate)
        database.perform(query, inZoneWith: .default) { (records: [CKRecord]?, error: Error?) in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let records = records else {
                completion(.failure(Errors.recordMissing))
                return
            }
            completion(.success(records))
        }
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
