//
//  CloutContainerable.swift
//  
//
//  Created by Kamaal M Farah on 01/11/2021.
//

import CloudKit

protocol CloutContainerable {
    var publicCloudDatabase: CloutDatabasable { get }
    var privateCloudDatabase: CloutDatabasable { get }
    var sharedCloudDatabase: CloutDatabasable { get }

    func fetchUserRecordID(completionHandler: @escaping (CKRecord.ID?, Error?) -> Void)
    func accountStatus(completionHandler: @escaping (CKAccountStatus, Error?) -> Void)
}
