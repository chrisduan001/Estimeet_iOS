//
//  SessionColumn+CoreDataProperties.swift
//  MeetUp
//
//  Created by Chris Duan on 16/05/16.
//  Copyright © 2016 Chris. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension SessionColumn {

    @NSManaged var dateCreated: NSNumber?
    @NSManaged var expireInMillis: NSNumber?
    @NSManaged var friendId: NSNumber?
    @NSManaged var sessionId: NSNumber?
    @NSManaged var sessionLId: String?
    @NSManaged var sessionLocation: String?
    @NSManaged var sessionRequestedTime: NSNumber?
    @NSManaged var sessionType: NSNumber?
    @NSManaged var friend: Friend?
    @NSManaged var sessionData: SessionData?

}
