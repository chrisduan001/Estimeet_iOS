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
    
    func saveFriend(friend: FriendEntity) {
        let entity = NSEntityDescription.entityForName(String(Friend), inManagedObjectContext: context)
        
        let friendObj = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: context) as! Friend
        DataEntity.sharedInstance.translateFriendEntityToDBFriend(friend, dbFriend: friendObj)
        friendObj.sectionHeader = SECTION_HEADER_FRIEND
        
        do {
            try context.save()
        } catch {}
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
    
    func getFriend(id: Int) -> Friend? {
        let request = NSFetchRequest(entityName: String(Friend))
        let predict = NSPredicate(format: "userId == %@", NSNumber(integer: id))
        request.predicate = predict
        
        do {
            let result = try context.executeFetchRequest(request) as! [Friend]
            return result[0]
        } catch {}
        
        return nil
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
            friendObj.session = createNewSessionObject()
        }
        
        SessionFactory.sharedInstance.createRequestedSession(friendObj.session!, friendId: friendObj.userId!)
        friendObj.sectionHeader = SECTION_HEADER_SESSION
        do {
            try context.save()
        } catch {
            print("error while save new session")
        }
    }
    
    func createPendingSession(friendId: Int, requestedTime: Int, friendObj: Friend) {
        if friendObj.session == nil {
            friendObj.session = createNewSessionObject()
        }
        
        SessionFactory.sharedInstance.createPendingSession(friendObj.session!, friendId: friendId, requestedTime: requestedTime)
        friendObj.sectionHeader = SECTION_HEADER_SESSION
        do {
            try context.save()
        } catch {
            print("error while save session")
        }
    }
    
    func createActiveSession(friendId: Int, sessionId: Int, sessionLId: String, expireInMillis: NSNumber, length: Int, friendObj: Friend) -> NSNumber {
        if friendObj.session == nil {
            friendObj.session = createNewSessionObject()
        }
        
        SessionFactory.sharedInstance.createActiveSession(friendObj.session!, friendId: friendId, sessionId: sessionId, sessionLid: sessionLId, expireInMillis: expireInMillis, length: length)
        friendObj.sectionHeader = SECTION_HEADER_SESSION
        do {
            try context.save()
            
            return friendObj.session!.dateCreated!
        } catch {}
        
        return -1
    }
    
    private func createNewSessionObject() -> SessionColumn {
        let entity = NSEntityDescription.entityForName(String(SessionColumn), inManagedObjectContext: context)
        let newSession = SessionColumn(entity: entity!, insertIntoManagedObjectContext: context)
        return newSession
    }
    
    func getAllSessions() -> [SessionColumn] {
        let request = NSFetchRequest(entityName: String(SessionColumn))
        do {
            return try context.executeFetchRequest(request) as! [SessionColumn]
        } catch {}
        
        return []
    }
    
    func deleteSession(session: SessionColumn) {
        //reset the session from active to friend
        session.friend!.sectionHeader = SECTION_HEADER_FRIEND
        if session.sessionData != nil {
            context.deleteObject(session.sessionData!)
        }
        context.deleteObject(session)
        
        do {
            try context.save()
        } catch {
            print("error occurred while delete session")
        }
    }
    
    func deleteAllSession() {
        let request = NSFetchRequest(entityName: String(SessionColumn))
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: request)
        do {
            try context.executeRequest(deleteRequest)
        } catch {
            print("error occurred while delete all session")
        }
    }
    
    //MARK: SESSION DATA
    func storeSessionData(distance: Int, eta: Int, travelMode: Int, session: SessionColumn) {
        if session.sessionData == nil {
            session.sessionData = createNewSessionDataObject();
        }
        session.sessionData?.sessionColumn = session
        session.friend!.dateUpdated = NSDate.timeIntervalSinceReferenceDate() * 1000
        session.sessionData!.distance = distance
        session.sessionData!.eta = eta
        session.sessionData!.travelMode = travelMode
        
        do {
            try context.save()
        } catch {
            print("error occurred while save session data")
        }
    }
    
    func createNewSessionDataObject() -> SessionData {
        let entity = NSEntityDescription.entityForName(String(SessionData), inManagedObjectContext: context)
        let sessionData = SessionData(entity: entity!, insertIntoManagedObjectContext: context)
        return sessionData
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
        
        return NSFetchedResultsController(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: "sectionHeader", cacheName: "mainSessionCache")
    }
    
    private let SECTION_HEADER_FRIEND = "Friend"
    private let SECTION_HEADER_SESSION = "Active"
}










