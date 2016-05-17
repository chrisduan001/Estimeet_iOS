//
//  Friend.swift
//  MeetUp
//
//  Created by Chris Duan on 1/05/16.
//  Copyright © 2016 Chris. All rights reserved.
//

import Foundation
import CoreData


class Friend: NSManagedObject {

    //used for sorting
    var timeToExpireSorter: NSNumber {
        get {
            if session == nil || session!.expireInMillis == nil {
                return 0
            }
            return session!.expireInMillis!
        }
    }
}
