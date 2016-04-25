//
//  DataEntity.swift
//  MeetUp
//
//  Created by Chris Duan on 23/04/16.
//  Copyright © 2016 Chris. All rights reserved.
//

import Foundation
class DataEntity {
    static let ENTITY_FRIEND = "Friend"
    static let FRIEND_ATTR_FAVOURITE = "favourite"
    static let FRIEND_ATTR_IMAGE = "image"
    static let FRIEND_ATTR_IMAGEURI = "imageUri"
    static let FRIEND_ATTR_USERID = "userId"
    static let FRIEND_ATTR_USERNAME = "userName"
    static let FRIEND_ATTR_USERUID = "userUId"
    
    static let sharedInstance = DataEntity()
    private init() {}
    
    func translateFriendObjToFriendEntity(friendObj: AnyObject) -> FriendEntity {
        let favourite = friendObj.valueForKey(DataEntity.FRIEND_ATTR_FAVOURITE) as! Bool
        let image = friendObj.valueForKey(DataEntity.FRIEND_ATTR_IMAGE) as? NSData
        let imageUri = friendObj.valueForKey(DataEntity.FRIEND_ATTR_IMAGEURI) as! String
        let userId = friendObj.valueForKey(DataEntity.FRIEND_ATTR_USERID) as! Int
        let userName = friendObj.valueForKey(DataEntity.FRIEND_ATTR_USERNAME) as! String
        let userUId = friendObj.valueForKey(DataEntity.FRIEND_ATTR_USERUID) as! CLong
        
        return FriendEntity(userId: userId,
                           userUId: userUId,
                          userName: userName,
                             dpUri: imageUri,
                             image: image,
                       isFavourite: favourite)
    }
}