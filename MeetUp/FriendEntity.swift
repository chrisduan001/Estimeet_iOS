//
//  Friend.swift
//  MeetUp
//
//  Created by Chris Duan on 23/04/16.
//  Copyright © 2016 Chris. All rights reserved.
//

import Foundation
import ObjectMapper

class FriendEntity: BaseResponse {
    var userId: Int!
    var userUId: String!
    var uidNumber: NSNumber!
    var userName: String!
    var dpUri: String!
    var image: NSData?
    var isFavourite: Bool! = false
    
    required init?(_ map: Map) {
        super.init(map)
    }
    
    override init() {
        super.init()
    }
    
    init(userId: Int, userUId: String, userName: String, dpUri: String, image: NSData?, isFavourite: Bool) {
        self.userId = userId
        self.userUId = userUId
        self.userName = userName
        self.dpUri = dpUri
        self.image = image
        self.isFavourite = isFavourite
        super.init()
    }
    
    override func mapping(map: Map) {
        userId          <- map["id"]
        uidNumber       <- map["userId"]
        userName        <- map["userName"]
        dpUri           <- map["dpUri"]
        //the server returns int value, need to transfer to string value
        userUId = "\(uidNumber!)"
    }
}