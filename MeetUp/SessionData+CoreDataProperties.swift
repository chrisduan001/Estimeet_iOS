//
//  SessionData+CoreDataProperties.swift
//  Estimeet
//
//  Created by Chris Duan on 25/07/16.
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
    @NSManaged var timeOnWaitingUpdate: NSNumber?
    @NSManaged var travelMode: NSNumber?
    @NSManaged var location: String?
    @NSManaged var sessionColumn: SessionColumn?

}
