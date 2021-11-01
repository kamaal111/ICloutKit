//
//  ICloutKit+save.swift
//  
//
//  Created by Kamaal M Farah on 01/11/2021.
//

import CloudKit

extension ICloutKit {
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

    /// Save record to iCloud container
    /// - Parameter record: Record to save
    /// - Returns: The record to save, or nil if CloudKit can’t save the record.
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

    /// Save multiple records to iCloud container
    /// - Parameters:
    ///   - records: Records to save
    ///   - completion:
    ///     - Success: The records that successfully have saved.
    ///     - Failure: An error if a problem occurs, or nil if CloudKit successfully saves the record.
    public func saveMultiple(_ records: [CKRecord], completion: @escaping (Result<[CKRecord], Error>) -> Void) {
        saveMultiple(records, enableModificatoin: true, completion: completion)
    }

    /// Save multiple records to iCloud container
    /// - Parameter records: Records to save
    /// - Returns: The records that successfully have saved.
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

    func saveMultiple(_ records: [CKRecord], enableModificatoin: Bool, completion: @escaping (Result<[CKRecord], Error>) -> Void) {
        guard !records.isEmpty else {
            completion(.success(records))
            return
        }
        getAccountStatus { (result: Result<Bool, Error>) in
            switch result {
            case .failure(let failure): completion(.failure(failure))
            case .success:
                let modification = CKModifyRecordsOperation(recordsToSave: records, recordIDsToDelete: nil)
                modification.setDatabase(enabled: enableModificatoin, database: database.original)
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
}
