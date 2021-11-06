//
//  CKModifyRecordsOperation+extensions.swift
//  
//
//  Created by Kamaal M Farah on 01/11/2021.
//

import CloudKit

extension CKModifyRecordsOperation {
    func setDatabase(enabled: Bool = true, database: CKDatabase?) {
        if enabled, let database = database {
            self.database = database
        }
    }
}
