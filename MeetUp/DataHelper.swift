//
//  Datahelper
//  MeetUp
//
//  Created by Chris Duan on 23/04/16.
//  Copyright © 2016 Chris. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class DataHelper {
    
    private let context:NSManagedObjectContext
    
    static let sharedInstance = DataHelper(context: DataHelper.getManagedContext())
    private init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    private static func getManagedContext() -> NSManagedObjectContext {
        return (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    }
    
    func storeFriendList(friends: [FriendEntity]) {
        let entity = NSEntityDescription.entityForName(DataEntity.ENTITY_FRIEND, inManagedObjectContext: context)
        
        deleteAllFriends()
        
        for friend in friends {
            let friendObj = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: context)
            friendObj.setValue(friend.userId, forKey: DataEntity.FRIEND_ATTR_USERID)
            friendObj.setValue(friend.userUId, forKey: DataEntity.FRIEND_ATTR_USERUID)
            friendObj.setValue(friend.userName, forKey: DataEntity.FRIEND_ATTR_USERNAME)
            friendObj.setValue(friend.isFavourite == nil ? true : false, forKey: DataEntity.FRIEND_ATTR_FAVOURITE)
            friendObj.setValue(friend.image, forKey: DataEntity.FRIEND_ATTR_IMAGE)
            friendObj.setValue(friend.dpUri, forKey: DataEntity.FRIEND_ATTR_IMAGEURI)
        }
        
        do {
            try context.save()
        } catch {
            //TODO..ADD PROPER EXCEPTION HANDLING
        }
    }
    
    func getFriends() -> [FriendEntity] {
        let request = NSFetchRequest(entityName: DataEntity.ENTITY_FRIEND)
        var friendList = [FriendEntity]()
        
        do {
            let results = try context.executeFetchRequest(request)
            for result in results {
                let id = result.valueForKey(DataEntity.FRIEND_ATTR_USERID) as! Int
                let uid = result.valueForKey(DataEntity.FRIEND_ATTR_USERUID) as! CLong
                let name = result.valueForKey(DataEntity.FRIEND_ATTR_USERNAME) as! String
                let favourite = result.valueForKey(DataEntity.FRIEND_ATTR_FAVOURITE) as! Bool
                let image = result.valueForKey(DataEntity.FRIEND_ATTR_IMAGE) as? NSData
                let uri = result.valueForKey(DataEntity.FRIEND_ATTR_IMAGEURI) as! String
                
                let friendObj = FriendEntity(userId: id, userUId: uid, userName: name, dpUri: uri, image: image, isFavourite: favourite)
                friendList.append(friendObj)
            }
            
        } catch {}
        
        return friendList
    }
    
    func deleteAllFriends() {
        let request = NSFetchRequest(entityName: DataEntity.ENTITY_FRIEND)
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: request)
        
        do {
            try context.executeRequest(deleteRequest)
        } catch {}
    }
}





