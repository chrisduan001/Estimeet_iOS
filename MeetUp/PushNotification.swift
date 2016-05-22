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
    static let NO_SESSION_KEY = "co.nz.estimeet.nosession"
    
    static let sharedInstance = PushNotification()
    private init() {
    }
    
    func receivePushMessage(message: [NSObject : AnyObject]) {
        
        guard let pushMessage = message["message"] as? String else {
            sendPushBroadcastMessage(PushNotification.GENERAL_NOTIFICATION_KEY)
            return
        }
        
        let msgArray = pushMessage.componentsSeparatedByString(",")
        let code = Int(msgArray[0])!
        
        switch code {
        case 102:
            //friend accepted session
            sendPushBroadcastMessage(PushNotification.GENERAL_NOTIFICATION_KEY)
            break
        case 103:
            //session cancelled, delete item from db
            onSessionCancelled(Int(msgArray[1])!)
            break
        default: break
        }
    }
    
    private func onSessionCancelled(friendId: Int) {
        let sessionFactory = SessionFactory.sharedInstance
        let dataHelper = ModelFactory.sharedInstance.dataHelper
        sessionFactory.deleteSessionById(dataHelper, friendId: friendId)
        let isActiveSession = sessionFactory.checkSession(dataHelper)
        if isActiveSession == nil || !isActiveSession!.boolValue {
            ModelFactory.sharedInstance.provideLocationServicemodel(nil).startTracking(-1)
            if isActiveSession == nil {
                sendPushBroadcastMessage(PushNotification.NO_SESSION_KEY)
            }
        }
    }
    //will cause app to fetch data from server
    private func sendPushBroadcastMessage(key: String) {
        NSNotificationCenter.defaultCenter().postNotificationName(key, object: self, userInfo: nil)
    }
}