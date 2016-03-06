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
    var id: Int?
    var userId: CLong?
    var userName: String?
    var dpUri: String?
    var phoneNumber: String?
    var password: String?
    var token: String?
    var expireTime: CLong?
    
    required init?(_ map: Map) {
        super.init(map)
    }
    
    override init() {
        super.init()
    }
    
    init(id:Int, userId:CLong, userName:String, dpUri:String, phoneNumber:String, password:String, token:String, expireTime:CLong) {
        self.id = id
        self.userId = userId
        self.userName = userName
        self.dpUri = dpUri
        self.phoneNumber = phoneNumber
        self.password = password
        self.token = token
        self.expireTime = expireTime
        
        super.init()
    }
    
    override func mapping(map: Map) {
        id          <- map["id"]
        userId      <- map["userId"]
        userName    <- map["userName"]
        dpUri       <- map["dpUri"]
        phoneNumber <- map["phoneNumber"]
        password    <- map["password"]
        token       <- map["token"]
        expireTime  <- map["expires_in"]
        super.mapping(map)
    }
}