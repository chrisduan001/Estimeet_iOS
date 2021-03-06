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
    var userId: Int?
    var userUId: String?
    var userName: String?
    var dpUri: String?
    var phoneNumber: String?
    var password: String?
    var token: String?
    var expireTime: Int?
    var image: NSData?
    var uidIntValue: NSNumber?
    
    required init?(_ map: Map) {
        super.init(map)
    }
    
    override init() {
        super.init()
    }
    
    init(id:Int, userId:String, userName:String, dpUri:String, phoneNumber:String, password:String, token:String, expireTime:Int, imageData: NSData?) {
        self.userId = id
        self.userUId = userId
        self.userName = userName
        self.dpUri = dpUri
        self.phoneNumber = phoneNumber
        self.password = password
        self.token = token
        self.expireTime = expireTime
        self.image = imageData
        
        super.init()
    }
    
    override func mapping(map: Map) {
        userId      <- map["id"]
        uidIntValue <- map["userId"]
        userName    <- map["userName"]
        dpUri       <- map["dpUri"]
        phoneNumber <- map["phoneNumber"]
        password    <- map["password"]
        token       <- map["token"]
        expireTime  <- map["expires_in"]
        //the server returns int value, need to transfer to string value
        userUId = "\(uidIntValue!)"
    
        super.mapping(map)
    }
}





