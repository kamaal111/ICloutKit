//
//  ICloutKit.swift
//
//
//  Created by Kamaal M Farah on 23/02/2021.
//

import CloudKit

public struct ICloutKit {
    private let container: CKContainer
    private let database: CKDatabase

    public init(containerID: String) {
        let container = CKContainer(identifier: containerID)
        self.container = container
        self.database = container.privateCloudDatabase
    }

    public func save(_ record: CKRecord, completion: @escaping (Result<CKRecord, Error>) -> Void) {
        getAccountStatus { (result: Result<Bool, Error>) in
            switch result {
            case .failure(let failure): completion(.failure(failure))
            case .success:
                database.save(record) { (record: CKRecord?, error: Error?) in
                    if let error = error {
                        completion(.failure(error))
                        return
                    }
                    guard let record = record else {
                        completion(.failure(Errors.recordMissing))
                        return
                    }
                    completion(.success(record))
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

    public func subscribe(toType objectType: String,
                          by predicate: NSPredicate,
                          completion: @escaping (Result<CKSubscription, Error>) -> Void) {
        _subscribe(toType: objectType, by: predicate, completion: completion)
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

    public func fetch(ofType objectType: String,
                      by predicate: NSPredicate,
                      completion: @escaping (Result<[CKRecord], Error>) -> Void) {
        _fetch(ofType: objectType, by: predicate, completion: completion)
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
            @unknown default: completion(.failure(AccountErrors.accountStatusUnknown))
            }
        }
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
    }

    public enum CloudKitErrors: Error {
        case cloudKitNotAuthenticated
        case cloudKitNetworkError
        case cloudKitQuotaExeded
    }
}
