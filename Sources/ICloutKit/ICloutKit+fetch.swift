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
                      limit: Int? = nil,
                      completion: @escaping (Result<[CKRecord], Error>) -> Void) {
        _fetch(ofType: objectType, by: predicate, limit: limit, completion: completion)
    }

    @available(iOS 13.0.0, macOS 10.15.0, *)
    public func fetch(ofType objectType: String, by predicate: NSPredicate, limit: Int? = nil) async throws -> [CKRecord] {
        return try await withCheckedThrowingContinuation({ continuation in
            fetch(ofType: objectType, by: predicate, limit: limit) { result in
                switch result {
                case .failure(let failure): return continuation.resume(throwing: failure)
                case .success(let success): return continuation.resume(returning: success)
                }
            }
        })
    }

    private func _fetch(ofType objectType: String,
                        by predicate: NSPredicate,
                        limit: Int? = nil,
                        completion: @escaping (Result<[CKRecord], Error>) -> Void) {
        getAccountStatus { result in
            switch result {
            case .failure(let failure):
                completion(.failure(failure))
                return
            case .success: break
            }

            let query = CKQuery(recordType: objectType, predicate: predicate)
            let queryOperation = CKQueryOperation(query: query)
            if let limit {
                queryOperation.resultsLimit = limit
            }

            var fetchedRecords: [CKRecord] = []
            if #available(macOS 12.0, *) {
                func fetchWithQueryOperation(_ operation: CKQueryOperation) {
                    operation.recordMatchedBlock = { recordID, recordResult in
                        switch recordResult {
                        case .failure(let failure): completion(.failure(failure))
                        case .success(let success): fetchedRecords.append(success)
                        }
                    }
                    operation.queryResultBlock = { operationResult in
                        let cursor: CKQueryOperation.Cursor?
                        switch operationResult {
                        case .failure(let failure):
                            completion(.failure(failure))
                            return
                        case .success(let success): cursor = success
                        }

                        if let cursor {
                            let cursorQueryOperation = CKQueryOperation(cursor: cursor)
                            fetchWithQueryOperation(cursorQueryOperation)
                            return
                        }

                        completion(.success(fetchedRecords))
                    }
                }

                fetchWithQueryOperation(queryOperation)
            } else {
                func fetchWithQueryOperation(_ operation: CKQueryOperation) {
                    operation.recordFetchedBlock = { record in
                        fetchedRecords.append(record)
                    }
                    operation.queryCompletionBlock = { cursor, error in
                        if let error {
                            completion(.failure(error))
                            return
                        }

                        if let cursor {
                            let cursorQueryOperation = CKQueryOperation(cursor: cursor)
                            fetchWithQueryOperation(cursorQueryOperation)
                            return
                        }

                        completion(.success(fetchedRecords))
                    }
                }

                fetchWithQueryOperation(queryOperation)
            }

            database.add(operation: queryOperation)
        }
    }
}
