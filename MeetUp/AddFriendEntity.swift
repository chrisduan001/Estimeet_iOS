//
//  AddFriendEntity.swift
//  MeetUp
//
//  Created by Chris Duan on 11/07/16.
//  Copyright © 2016 Chris. All rights reserved.
//

import Foundation
import ObjectMapper

class AddFriendEntity: Mappable {
    var senderId: Int!
    var senderUid: String!
    var friendId: Int!
    var friendUid: String!
    
    required init?(_ map: Map) {}
    
    init(senderId: Int, senderUid: String, friendId: Int, friendUid: String) {
        self.senderId = senderId
        self.senderUid = senderUid
        self.friendId = friendId
        self.friendUid = friendUid
    }
    
    func mapping(map: Map) {
        senderId        <- map["senderId"]
        senderUid       <- map["senderUid"]
        friendId        <- map["friendId"]
        friendUid       <- map["friendUid"]
    }
}