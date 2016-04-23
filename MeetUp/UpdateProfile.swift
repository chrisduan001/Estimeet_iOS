//
//  UpdateProfile.swift
//  MeetUp
//
//  Created by Chris Duan on 6/03/16.
//  Copyright © 2016 Chris. All rights reserved.
//

import Foundation
import ObjectMapper

class UpdateProfile: Mappable {
    var userId: Int?
    var userUId: CLong?
    var imageString: String?
    var userRegion: String?
    var userName: String?
    
    init(userId: Int, userUId: CLong, imageString: String, userRegion: String, userName: String) {
        self.userId = userId
        self.userUId = userUId
        self.imageString = imageString
        self.userRegion = userRegion
        self.userName = userName
    }
    
    required init?(_ map: Map) {
    }
    
    func mapping(map: Map) {
        userId      <- map["id"]
        userUId     <- map["userId"]
        imageString <- map["imageString"]
        userRegion  <- map["userRegion"]
        userName    <- map["userName"]
    }
}
