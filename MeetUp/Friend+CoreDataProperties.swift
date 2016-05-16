//
//  Friend+CoreDataProperties.swift
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

extension Friend {

    @NSManaged var favourite: NSNumber?
    @NSManaged var image: NSData?
    @NSManaged var imageUri: String?
    @NSManaged var sectionHeader: String?
    @NSManaged var userId: NSNumber?
    @NSManaged var userName: String?
    @NSManaged var userUId: String?
    @NSManaged var dateUpdated: NSNumber?
    @NSManaged var session: SessionColumn?

}
