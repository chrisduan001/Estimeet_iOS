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
            friendObj.sectionHeader = SECTION_HEADER_FRIEND
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
    func createSession(friendObj: Friend) {
        if friendObj.session == nil {
            let newSession = NSEntityDescription.insertNewObjectForEntityForName(String(SessionColumn), inManagedObjectContext: context) as! SessionColumn
            SessionFactory.sharedInstance.createRequestedSession(newSession, friendId: friendObj.userId!)
        } else {
            SessionFactory.sharedInstance.createRequestedSession(friendObj.session!, friendId: friendObj.userId!)
        }
        
        do {
            try context.save()
            friendObj.sectionHeader = SECTION_HEADER_SESSION
        } catch {
            print("error while save new session")
        }
    }
    
    func getAllSessions() -> [SessionColumn] {
        let request = NSFetchRequest(entityName: String(SessionColumn))
        do {
            return try context.executeFetchRequest(request) as! [SessionColumn]
        } catch {}
        
        return []
    }
    
    func deleteSession(session: SessionColumn) {
        session.friend!.sectionHeader = SECTION_HEADER_FRIEND
        context.deleteObject(session)
        
        do {
            try context.save()
        } catch {}
    }
    
    func deleteAllSession() {
        let request = NSFetchRequest(entityName: String(SessionColumn))
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: request)
        do {
            try context.executeRequest(deleteRequest)
        } catch {}
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
        let sort = NSSortDescriptor(key: "sectionHeader", ascending: true)
        request.predicate = predict
        request.sortDescriptors = [sort]
        
        return NSFetchedResultsController(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: "sectionHeader", cacheName: nil)
    }
    
    private let SECTION_HEADER_FRIEND = "Friend"
    private let SECTION_HEADER_SESSION = "Active"
}










