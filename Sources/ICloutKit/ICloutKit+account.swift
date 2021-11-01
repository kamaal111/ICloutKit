//
//  ICloutKit+account.swift
//  
//
//  Created by Kamaal M Farah on 01/11/2021.
//

import CloudKit

extension ICloutKit {
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
}
