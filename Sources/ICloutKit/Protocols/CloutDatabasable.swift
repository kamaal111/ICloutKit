//
//  CloutDatabasable.swift
//  
//
//  Created by Kamaal M Farah on 01/11/2021.
//

import CloudKit

protocol CloutDatabasable {
    var original: CKDatabase { get }

    func save(_ record: CKRecord, completion: @escaping (_ record: CKRecord?, _ error: Error?) -> Void)
    func perform(_ query: CKQuery, inZoneWith zoneID: CKRecordZone.ID?, completionHandler: @escaping ([CKRecord]?, Error?) -> Void))
}
