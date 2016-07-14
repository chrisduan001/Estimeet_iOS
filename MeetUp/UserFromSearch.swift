//
//  UserFromSearch.swift
//  MeetUp
//
//  Created by Chris Duan on 14/07/16.
//  Copyright © 2016 Chris. All rights reserved.
//

import Foundation
import ObjectMapper

class UserFromSearch: User {
    var isFriend: Bool?
    
    required init?(_ map: Map) {
        super.init(map)
    }
    
    override init() {
        super.init()
    }
    
    init(id:Int, userId:String, userName:String, dpUri:String, phoneNumber:String, password:String, token:String, expireTime:Int, imageData: NSData?, isFriend: Bool?) {
        self.isFriend = isFriend
        
        super.init(id: id, userId: userId, userName: userName, dpUri: dpUri, phoneNumber: phoneNumber, password: password, token: token, expireTime: expireTime, imageData: imageData)
    }
}