//
//  SessionData+CoreDataProperties.swift
//  MeetUp
//
//  Created by Chris Duan on 1/05/16.
//  Copyright © 2016 Chris. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension SessionData {

    @NSManaged var distance: NSNumber?
    @NSManaged var eta: NSNumber?
    @NSManaged var sessionId: NSNumber?
    @NSManaged var travelMode: NSNumber?
    @NSManaged var sessionColumn: SessionColumn?

}
