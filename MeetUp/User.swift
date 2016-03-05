//
//  User.swift
//  MeetUp
//
//  Created by Chris Duan on 2/03/16.
//  Copyright © 2016 Chris. All rights reserved.
//

import Foundation
import ObjectMapper

class User : BaseResponse {
    var userId: Int!
    var userName: String!
    
    override func mapping(map: Map) {
        userId <- map["userId"]
        userName <- map["userName"]
        super.mapping(map)
    }
}