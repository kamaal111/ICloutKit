//
//  CloutContainer.swift
//  
//
//  Created by Kamaal M Farah on 01/11/2021.
//

import CloudKit

struct CloutContainer: CloutContainerable {
    private let container: CKContainer

    init(containerID: String) {
        self.container = CKContainer(identifier: containerID)
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
        container.fetchUserRecordID(completionHandler: completionHandler)
    }

    func accountStatus(completionHandler: @escaping (CKAccountStatus, Error?) -> Void) {
        container.accountStatus(completionHandler: completionHandler)
    }
}
