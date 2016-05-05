//
//  NotificationEntity.swift
//  MeetUp
//
//  Created by Chris Duan on 5/05/16.
//  Copyright © 2016 Chris. All rights reserved.
//
import Foundation
import ObjectMapper

class NotificationEntity: Mappable {
    var senderId: Int!
    var receiverId: Int!
    var receiverUId: String!
    
    init(senderId: Int, receiverId: Int, receiverUId: String) {
        self.senderId = senderId
        self.receiverId = receiverId
        self.receiverUId = receiverUId
    }
    
    required init?(_ map: Map) {}
    
    func mapping(map: Map) {
        senderId       <- map["senderId"]
        receiverId     <- map["receiverId"]
        receiverUId    <- map["receiverUId"]
    }
}