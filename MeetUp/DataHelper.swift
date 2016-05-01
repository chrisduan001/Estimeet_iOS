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
    
    //MARK: FRIEND ACTIONS
    func storeFriendList(friends: [FriendEntity]) {
        let entity = NSEntityDescription.entityForName(String(Friend), inManagedObjectContext: context)

        deleteAllFriends()
        
        for friend in friends {
            let friendObj = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: context) as! Friend
            DataEntity.sharedInstance.translateFriendEntityToDBFriend(friend, dbFriend: friendObj)
        }
        
        do {
            try context.save()
        } catch {
            //TODO..ADD PROPER EXCEPTION HANDLING
        }
    }
    
    func saveFriendImage(friendObj: Friend, imgData: NSData) {
        friendObj.image = imgData
        
        dispatch_async(dispatch_get_main_queue()) {
            do {
                try self.context.save()
            } catch {}
        }
    }
    
    func setFavouriteFriend(friendObj: Friend) {        
        friendObj.favourite = !friendObj.favourite!.boolValue
        
        do {
            try context.save()
        } catch {}
    }
    
    func deleteAllFriends() {
        let request = NSFetchRequest(entityName: String(Friend))
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: request)
        
        do {
            try context.executeRequest(deleteRequest)
        } catch {}
    }
    
    //MARK: SESSION ACTIONS
    func createSession(friendObj: Friend, withSessionType: Int) {
        if friendObj.session == nil {
            let newSession = NSEntityDescription.insertNewObjectForEntityForName(String(SessionColumn), inManagedObjectContext: context) as! SessionColumn
            newSession.friendId = friendObj.userId
            newSession.sessionType = withSessionType
            friendObj.session = newSession
        } else {
            friendObj.session!.friendId = friendObj.userId
            friendObj.session!.sessionType = withSessionType
        }
        
        do {
            try context.save()
        } catch {
            print("error while save new session")
        }
    }
    
    //MARK: FETCHED RESULTS
    func getFriendsFetchedResults() -> NSFetchedResultsController {
        let request = NSFetchRequest(entityName: String(Friend))
        let sort = NSSortDescriptor(key: "userName", ascending: true)
        request.sortDescriptors = [sort]
        return NSFetchedResultsController(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: "manageFriendCache")
    }
    
    func getSessionFetchedResults() -> NSFetchedResultsController {
        let request = NSFetchRequest(entityName: String(Friend))
        let predict = NSPredicate(format: "favourite == %@", NSNumber(bool: true))
        let sort = NSSortDescriptor(key: "userName", ascending: true)
        request.predicate = predict
        request.sortDescriptors = [sort]
        
        return NSFetchedResultsController(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: "isActiveSesion", cacheName: "sessionCache")
    }
}










