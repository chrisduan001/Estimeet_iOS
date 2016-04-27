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
    var userUId: String?
    var phoneNumber: String?
    
    init(authHeader: String, authUri: String, userUId: String, phoneNumber: String) {
        self.authHeader = authHeader
        self.authUri = authUri
        self.userUId = userUId
        self.phoneNumber = phoneNumber
    }
    
    required init?(_ map: Map) {
    }
    
    func mapping(map: Map) {
        authHeader  <- map["authHeader"]
        authUri     <- map["authUri"]
        userUId     <- map["userId"]
        phoneNumber <- map["phoneNumber"]
    }
}
