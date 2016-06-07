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
    static let REQUEST_LOCATION_KEY = "co.nz.estimeet.requestLocation"
    
    var bgTask: UIBackgroundTaskIdentifier!
    
    static let sharedInstance = PushNotification()
    private init() {
    }
    
    func receivePushMessage(message: [NSObject : AnyObject]) {
        let isAppActive = UIApplication.sharedApplication().applicationState == .Active
        guard let pushMessage = message["message"] as? String else {
            if isAppActive {
                sendPushBroadcastMessage(PushNotification.GENERAL_NOTIFICATION_KEY, userInfo: nil)
            }
            return
        }
        
        let msgArray = pushMessage.componentsSeparatedByString(",")
        let code = Int(msgArray[0])!
        
        switch code {
        case 102:
            if isAppActive {
                //friend accepted session
                sendPushBroadcastMessage(PushNotification.GENERAL_NOTIFICATION_KEY, userInfo: nil)
            } else {
                let numberFormatter = NSNumberFormatter()
                numberFormatter.numberStyle = .DecimalStyle
                if let timeToExpire = numberFormatter.numberFromString(msgArray[1]) {
                    //when user send the session request, the timer will start to run for default amount of minutes, if friends accepted the session, need to update the expire time here
                    SessionFactory.sharedInstance.setSessionTrackingExpireTime(timeToExpire)
                }
            }
            break
        case 103:
            //session cancelled, delete item from db
            onSessionCancelled(Int(msgArray[1])!, isAppActive: isAppActive)
            break
        case 104:
            onActiveSessionCancelled()
            break
        case 105:
            onRequestedOneOffLocation(msgArray[1], appActive: isAppActive)
            break
        default: break
        }
    }
    
    private func onSessionCancelled(friendId: Int, isAppActive: Bool) {
        let sessionFactory = SessionFactory.sharedInstance
        let dataHelper = ModelFactory.sharedInstance.dataHelper
        sessionFactory.deleteSessionById(dataHelper, friendId: friendId)
        let timeLeft = sessionFactory.checkSession(dataHelper)
        if timeLeft == nil || timeLeft <= 0 {
            AppDelegate.SESSION_TIME_TO_EXPIRE = nil
            if isAppActive {
                //send broadcast if the app is active, will need to reset the toolbar
                sendPushBroadcastMessage(PushNotification.NO_SESSION_KEY, userInfo: nil)
            }
        }
    }
    
    private func onActiveSessionCancelled() {
        
    }
    
    //MARK: LOCATION SERVICE
    lazy var oneOffLocation: OneOffLocationService = {
       return ModelFactory.sharedInstance.provideLocationServicemodel(nil)
    }()
    
    private func onRequestedOneOffLocation(msg: String, appActive: Bool) {
        requestOneOffLocation()
    }
    
    private func requestOneOffLocation()  {
        oneOffLocation.makeOneOffLocationRequest()
    }
    
    func requestLocationWithTimer() {
        oneOffLocation.makeRequestWithTimer()
    }
    
    //will cause app to fetch data from server
    private func sendPushBroadcastMessage(key: String, userInfo: [NSObject: AnyObject]?) {
        NSNotificationCenter.defaultCenter().postNotificationName(key, object: self, userInfo: userInfo)
    }
}