//
//  NotificationResponse.swift
//  MeetUp
//
//  Created by Chris Duan on 5/05/16.
//  Copyright © 2016 Chris. All rights reserved.
//

import Foundation
import ObjectMapper

class NotificationResponse: BaseResponse {
    var notificationId: Int!
    var identifier: Int!
    var appendix: String!
    var senderId: Int!
    var receiverId: Int!
    var receiverUId: String!
    
    required init?(_ map: Map) {
        super.init(map)
    }
    
    override init() {
        super.init()
    }
    
    init(notificationId: Int, identifier: Int, appendix: String, senderId: Int, receiverId: Int, receiverUId: String) {
        self.notificationId = notificationId
        self.identifier = identifier
        self.appendix = appendix
        self.senderId = senderId
        self.receiverId = receiverId
        self.receiverUId = receiverUId
        
        super.init()
    }
    
    override func mapping(map: Map) {
        notificationId      <- map["notificationId"]
        identifier          <- map["identifier"]
        appendix            <- map["appendix"]
        senderId            <- map["senderId"]
        receiverId          <- map["receiverId"]
        receiverUId         <- map["receiverUId"]
    }
}