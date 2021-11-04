//
//  ICloutKitSaveTests.swift
//  
//
//  Created by Kamaal M Farah on 04/11/2021.
//

import XCTest
import CloudKit
@testable import ICloutKit

final class ICloutKitSaveTests: XCTestCase {
    func testExample() {
        let container = TestContainer()
        let _ = ICloutKit(container: container, database: TestDatabase(original: container.original.publicCloudDatabase))
        XCTAssertEqual(true, true)
    }
}

struct TestContainer: CloutContainerable {
    let original: CKContainer

    init() {
        self.original = CKContainer(identifier: "does not exist")
    }

    var publicCloudDatabase: CloutDatabasable {
        CloutDatabase(database: original.publicCloudDatabase)
    }

    var privateCloudDatabase: CloutDatabasable {
        CloutDatabase(database: original.privateCloudDatabase)
    }

    var sharedCloudDatabase: CloutDatabasable {
        CloutDatabase(database: original.sharedCloudDatabase)
    }

    func fetchUserRecordID(completionHandler: @escaping (CKRecord.ID?, Error?) -> Void) {
        completionHandler(nil, nil)
    }

    func accountStatus(completionHandler: @escaping (CKAccountStatus, Error?) -> Void) {
        completionHandler(.available, nil)
    }
}

struct TestDatabase: CloutDatabasable {
    var original: CKDatabase

    func save(_ record: CKRecord, completion: @escaping (CKRecord?, Error?) -> Void) {
        completion(nil, nil)
    }

    func perform(_ query: CKQuery, inZoneWith zoneID: CKRecordZone.ID?, completionHandler: @escaping ([CKRecord]?, Error?) -> Void) {
        completionHandler(nil, nil)
    }

    func fetchAllSubscriptions(completionHandler: @escaping ([CKSubscription]?, Error?) -> Void) {
        completionHandler(nil, nil)
    }

    func save(_ subscription: CKSubscription, completionHandler: @escaping (CKSubscription?, Error?) -> Void) {
        completionHandler(nil, nil)
    }

    func delete(withRecordID recordID: CKRecord.ID, completionHandler: @escaping (CKRecord.ID?, Error?) -> Void) {
        completionHandler(nil, nil)
    }
}
