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
    var id: Int?
    var userId: CLong?
    var imageString: String?
    var userRegion: String?
    var userName: String?
    
    init(id: Int, userId: CLong, imageString: String, userRegion: String, userName: String) {
        self.id = id
        self.userId = userId
        self.imageString = imageString
        self.userRegion = userRegion
        self.userName = userName
    }
    
    required init?(_ map: Map) {
    }
    
    func mapping(map: Map) {
        id          <- map["id"]
        userId      <- map["userId"]
        imageString <- map["imageString"]
        userRegion  <- map["userRegion"]
        userName    <- map["userName"]
    }
}
