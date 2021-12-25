//
//  ICloutKit+subscribe.swift
//  
//
//  Created by Kamaal M Farah on 01/11/2021.
//

import CloudKit

extension ICloutKit {
    public func subscribe(toType objectType: String,
                          by predicate: NSPredicate,
                          completion: @escaping (Result<CKSubscription, Error>) -> Void) {
        _subscribe(toType: objectType, by: predicate, completion: completion)
    }

    @available(iOS 13.0.0, macOS 10.15.0, *)
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
        getAccountStatus { result in
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

    @available(iOS 13.0.0, macOS 10.15.0, *)
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

    private func _subscribe(toType objectType: String,
                            by predicate: NSPredicate,
                            completion: @escaping (Result<CKSubscription, Error>) -> Void) {
        getAccountStatus { result in
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
}
