//
//  DataEntity.swift
//  MeetUp
//
//  Created by Chris Duan on 23/04/16.
//  Copyright © 2016 Chris. All rights reserved.
//

import Foundation
class DataEntity {
    static let sharedInstance = DataEntity()
    private init() {}
    
    func translateFriendEntityToDBFriend(friendEntity: FriendEntity, dbFriend: Friend) {
        dbFriend.userId = friendEntity.userId
        dbFriend.userUId = friendEntity.userUId
        dbFriend.userName = friendEntity.userName
        dbFriend.favourite = friendEntity.isFavourite == nil ? false : friendEntity.isFavourite
        dbFriend.image = friendEntity.image
        dbFriend.imageUri = friendEntity.dpUri
    }
    
//    func translateFriendObjToFriendEntity(friendObj: AnyObject) -> FriendEntity {
//        let favourite = friendObj.valueForKey(DataEntity.FRIEND_ATTR_FAVOURITE) as! Bool
//        let image = friendObj.valueForKey(DataEntity.FRIEND_ATTR_IMAGE) as? NSData
//        let imageUri = friendObj.valueForKey(DataEntity.FRIEND_ATTR_IMAGEURI) as! String
//        let userId = friendObj.valueForKey(DataEntity.FRIEND_ATTR_USERID) as! Int
//        let userName = friendObj.valueForKey(DataEntity.FRIEND_ATTR_USERNAME) as! String
//        let userUId = friendObj.valueForKey(DataEntity.FRIEND_ATTR_USERUID) as! String
//        
//        return FriendEntity(userId: userId,
//                           userUId: userUId,
//                          userName: userName,
//                             dpUri: imageUri,
//                             image: image,
//                       isFavourite: favourite)
//    }
}