//
//  PushNotification.swift
//  MeetUp
//
//  Created by Chris Duan on 4/05/16.
//  Copyright © 2016 Chris. All rights reserved.
//

import Foundation
class PushNotification {
    
    static let BROADCAST_NOTIFICATION_KEY = "co.nz.estimeet.pushmessage"
    
    static let sharedInstance = PushNotification()
    private init() {
    }
    
    func receivePushMessage(message: [NSObject : AnyObject]) {
        let data: [String: String] = message["aps"] as! [String: String]
        
        NSNotificationCenter.defaultCenter().postNotificationName(PushNotification.BROADCAST_NOTIFICATION_KEY, object: self, userInfo: message)
    }
}