//
//  ICloutKit+fetch.swift
//  
//
//  Created by Kamaal M Farah on 01/11/2021.
//

import CloudKit

extension ICloutKit {
    public func fetch(ofType objectType: String,
                      by predicate: NSPredicate,
                      completion: @escaping (Result<[CKRecord], Error>) -> Void) {
        _fetch(ofType: objectType, by: predicate, completion: completion)
    }

    @available(iOS 13.0.0, macOS 10.15.0, *)
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

    private func _fetch(ofType objectType: String,
                        by predicate: NSPredicate,
                        completion: @escaping (Result<[CKRecord], Error>) -> Void) {
        getAccountStatus { result in
            switch result {
            case .failure(let failure): completion(.failure(failure))
            case .success: handleFetchAvailable(objectType: objectType, predicate: predicate, completion: completion)
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
}
