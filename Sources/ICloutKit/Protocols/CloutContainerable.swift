//
//  CloutContainerable.swift
//  
//
//  Created by Kamaal M Farah on 01/11/2021.
//

import Foundation

protocol CloutContainerable {
    var publicCloudDatabase: CloutDatabasable { get }
    var privateCloudDatabase: CloutDatabasable { get }
    var sharedCloudDatabase: CloutDatabasable { get }
}
