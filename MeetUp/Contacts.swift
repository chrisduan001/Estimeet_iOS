//
//  Contacts.swift
//  MeetUp
//
//  Created by Chris Duan on 17/04/16.
//  Copyright © 2016 Chris. All rights reserved.
//

import Foundation
import ObjectMapper

class Contacts: Mappable {
    var userId: Int!
    var userUId: String!
    var contacts: String!
    
    init(userId: Int, userUId: String, contacts: String) {
        self.userId = userId
        self.userUId = userUId
        self.contacts = contacts
    }
    
    required init?(_ map: Map) {}
    
    func mapping(map: Map) {
        userId      <- map["id"]
        userUId     <- map["userId"]
        contacts    <- map["contacts"]
    }
}