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
    var id: Int!
    var userId: CLong!
    var contacts: String!
    
    init(id: Int, userId: CLong, contacts: String) {
        self.id = id
        self.userId = userId
        self.contacts = contacts
    }
    
    required init?(_ map: Map) {}
    
    func mapping(map: Map) {
        id          <- map["id"]
        userId      <- map["userId"]
        contacts    <- map["contacts"]
    }
}