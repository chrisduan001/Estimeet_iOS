//
//  SessionEntity.swift
//  MeetUp
//
//  Created by Chris Duan on 30/04/16.
//  Copyright © 2016 Chris. All rights reserved.
//

import Foundation

class SessionEntity {
    var sessionId: Int?
    var sessionLId: NSNumber?
    var dateCreated: NSNumber?
    var dateUpdated: NSNumber?
    var timeToExpire: NSNumber?
    var distance: Int?
    var eta: Int?
    var location: String?
    var type: Int?
    var requestLength: Int?
    var travelMode: Int?
    var friendName: String!
    var friendId: Int!
    var friendDp: NSData!
    
    init() {}
}