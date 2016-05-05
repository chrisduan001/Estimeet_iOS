//
//  PushNotification.swift
//  MeetUp
//
//  Created by Chris Duan on 4/05/16.
//  Copyright © 2016 Chris. All rights reserved.
//

import Foundation
import UIKit

class PushNotification {

    static let GENERAL_NOTIFICATION_KEY = "co.nz.estimeet.pushmessage"
    
    static let sharedInstance = PushNotification()
    private init() {
    }
    
    func receivePushMessage(message: [NSObject : AnyObject]) {
        let pushData: [String: String] = message["aps"] as! [String: String]
        
        let pushMessage = pushData["message"]!
        let msgArray = pushMessage.componentsSeparatedByString(",")
        let code = Int(msgArray[0])!
        
        switch code {
        //100 general notification, need to pull data from server
        case 100:
            //new friend join
            sendGeneralNotification()
            break
        case 101:
            //new session request
            sendGeneralNotification()
            break
        case 102:
            //friend accepted session
            sendGeneralNotification()
            break
        case 103:
            //session cancelled, delete item from db
            onSessionCancelled()
            break
        case 999:
            break
        default: break
        }
    }
    
    private func onSessionCancelled() {
        
    }
    
    private func sendGeneralNotification() {
        NSNotificationCenter.defaultCenter().postNotificationName(PushNotification.GENERAL_NOTIFICATION_KEY, object: self, userInfo: nil)
    }
}