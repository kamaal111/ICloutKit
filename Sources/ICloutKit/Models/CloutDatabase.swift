//
//  CloutDatabase.swift
//  
//
//  Created by Kamaal M Farah on 01/11/2021.
//

import CloudKit

struct CloutDatabase: CloutDatabasable {
    let original: CKDatabase

    init(database: CKDatabase) {
        self.original = database
    }

    func save(_ record: CKRecord, completion: @escaping (CKRecord?, Error?) -> Void) {
        original.save(record, completionHandler: completion)
    }

    func perform(_ query: CKQuery, inZoneWith zoneID: CKRecordZone.ID?, completionHandler: @escaping ([CKRecord]?, Error?) -> Void) {
        original.perform(query, inZoneWith: zoneID, completionHandler: completionHandler)
    }
}
