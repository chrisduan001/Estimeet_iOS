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
    var userUId: CLong!
    var userName: String!
    var dpUri: String!
    var image: NSData?
    var isFavourite: Bool!
    
    required init?(_ map: Map) {
        super.init(map)
    }
    
    override init() {
        super.init()
    }
    
    init(userId: Int, userUId: CLong, userName: String, dpUri: String, image: NSData?, isFavourite: Bool) {
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
        userUId         <- map["userId"]
        userName        <- map["userName"]
        dpUri           <- map["dpUri"]
    }
}