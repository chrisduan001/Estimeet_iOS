//
//  SigninAuth.swift
//  MeetUp
//
//  Created by Chris Duan on 6/03/16.
//  Copyright © 2016 Chris. All rights reserved.
//

import Foundation
import ObjectMapper

class SigninAuth: Mappable {
    var authHeader: String?
    var authUri: String?
    var userId: CLong?
    var phoneNumber: String?
    
    init(authHeader: String, authUri: String, userId: CLong, phoneNumber: String) {
        self.authHeader = authHeader
        self.authUri = authUri
        self.userId = userId
        self.phoneNumber = phoneNumber
    }
    
    required init?(_ map: Map) {
    }
    
    func mapping(map: Map) {
        authHeader <- map["authHeader"]
        authUri    <- map["authUri"]
        userId     <- map["userId"]
        phoneNumber <- map["phoneNumber"]
    }
}
