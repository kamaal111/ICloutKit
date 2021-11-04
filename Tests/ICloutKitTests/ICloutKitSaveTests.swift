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
        XCTAssertEqual(true, true)
    }
}

struct TestContainer: CloutContainerable {
    private let container: CKContainer

    init() {
        self.container = CKContainer(identifier: "does not exist")
    }

    var publicCloudDatabase: CloutDatabasable {
        CloutDatabase(database: container.publicCloudDatabase)
    }

    var privateCloudDatabase: CloutDatabasable {
        CloutDatabase(database: container.privateCloudDatabase)
    }

    var sharedCloudDatabase: CloutDatabasable {
        CloutDatabase(database: container.sharedCloudDatabase)
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
