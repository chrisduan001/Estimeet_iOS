//
//  RequestLocationEntity.swift
//  MeetUp
//
//  Created by Chris Duan on 10/05/16.
//  Copyright © 2016 Chris. All rights reserved.
//

import Foundation
import ObjectMapper

class RequestLocationEntity: Mappable {
    var userId: Int!
    var userUid: String!
    var friendId: Int!
    var friendUid: String!
    var sessionId: Int!
    var sessionLid: String!
    var travelMode: Int!
    var userGeo: String!
    
    init(userId: Int, userUid: String, friendId: Int, friendUid: String, sessionId: Int, sessionLid: String, travelMode: Int, userGeo: String) {
        self.userId = userId
        self.userUid = userUid
        self.friendId = friendId
        self.friendUid = friendUid
        self.sessionId = sessionId
        self.sessionLid = sessionLid
        self.travelMode = travelMode
        self.userGeo = userGeo
    }
    
    required init?(_ map: Map) {}
    
    func mapping(map: Map) {
        userId          <- map["userId"]
        userUid         <- map["userUid"]
        friendId        <- map["friendId"]
        friendUid       <- map["friendUid"]
        sessionId       <- map["sessionId"]
        sessionLid      <- map["sessionLid"]
        travelMode      <- map["travelMode"]
        userGeo         <- map["userGeo"]
    }
}