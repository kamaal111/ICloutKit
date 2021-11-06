//
//  ICloutKit+delete.swift
//  
//
//  Created by Kamaal M Farah on 01/11/2021.
//

import CloudKit

extension ICloutKit {
    public func delete(_ record: CKRecord, completion: @escaping (Result<CKRecord.ID, Error>) -> Void) {
        getAccountStatus { result in
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
        deleteMultiple(records, enableModification: true, completion: completion)
    }

    internal func deleteMultiple(_ records: [CKRecord], enableModification: Bool, completion: @escaping (Result<[CKRecord], Error>) -> Void) {
        guard !records.isEmpty else {
            completion(.success(records))
            return
        }
        getAccountStatus { result in
            switch result {
            case .failure(let failure): completion(.failure(failure))
            case .success:
                let modification = CKModifyRecordsOperation(recordsToSave: nil,
                                                            recordIDsToDelete: records.map(\.recordID))
                modification.setDatabase(enabled: enableModification, database: database.original)
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
}
