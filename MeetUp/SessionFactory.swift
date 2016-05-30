//
//  SessionFactory.swift
//  MeetUp
//
//  Created by Chris Duan on 1/05/16.
//  Copyright © 2016 Chris. All rights reserved.
//

import Foundation
class SessionFactory {
    static let sharedInstance = SessionFactory()
    private init() {}
    
    private func setupSessionTimeWithDefaultValue(session: SessionColumn) {
        session.expireInMillis = TimeConverter.sharedInstance.convertToMilliseconds(TimeType.MINUTES, value: DEFAULT_EXPIRE_TIME)
        session.dateCreated = NSDate.timeIntervalSinceReferenceDate() * 1000
    }
    
    private func setUpSessionTime(expireTime: NSNumber, session: SessionColumn) {
        session.expireInMillis = expireTime
        session.dateCreated = NSDate.timeIntervalSinceReferenceDate() * 1000
    }
    
    func createRequestedSession(session: SessionColumn, friendId: NSNumber) {
        session.friendId = friendId
        session.sessionType = SENT_SESSION
        setupSessionTimeWithDefaultValue(session)
    }
    
    func createPendingSession(session: SessionColumn, friendId: Int, requestedTime: Int) -> SessionColumn {
        session.friendId = friendId
        session.sessionRequestedTime = requestedTime
        session.sessionType = RECEIVED_SESSION
        setupSessionTimeWithDefaultValue(session)
        
        return session
    }
    
    func createActiveSession(session: SessionColumn, friendId: Int, sessionId: Int, sessionLid: String, expireInMillis: NSNumber, length: Int) -> SessionColumn {
        session.sessionId = sessionId
        session.sessionLId = sessionLid
        session.friendId = friendId
        session.sessionType = ACTIVE_SESSION
        session.sessionRequestedTime = length
        setUpSessionTime(expireInMillis, session: session)
        
        return session
    }
    
    func setSessionTrackingExpireTime(trackingLength: NSNumber) {
        //take the longest tracking time
        let timeToExpire = NSDate.timeIntervalSinceReferenceDate() * 1000 + trackingLength.doubleValue
        if AppDelegate.SESSION_TIME_TO_EXPIRE == nil || AppDelegate.SESSION_TIME_TO_EXPIRE!.doubleValue < timeToExpire {
            AppDelegate.SESSION_TIME_TO_EXPIRE = timeToExpire
        }
    }
    
    func deleteFriendSession(dataHelper: DataHelper, friend: Friend) {
        dataHelper.deleteFriendSession(friend)
    }
    
    func deleteSessionById(dataHelper: DataHelper, friendId: Int) {
        dataHelper.deleteSessionById(friendId)
    }
    
    func insertSession(dataHelper: DataHelper, session: TempSessionModel, friend: Friend) {
        dataHelper.insertSession(session, friend: friend)
    }
    
    func acceptNewSession(dataHelper: DataHelper, friend: Friend) {
        friend.session!.dateCreated = NSDate.timeIntervalSinceReferenceDate() * 1000
        friend.session!.sessionType = ACTIVE_SESSION
        
        dataHelper.acceptNewSession(friend)
    }
    
    func updateSessionId(dataHelper: DataHelper, sessionId: Int, sessionLid: String, friend: Friend) {
        dataHelper.updateSessionId(friend, sessionId: sessionId, sessionLId: sessionLid)
    }
    
    func getRequestTimeInMinutes(requestLength: Int) -> Int {
        switch requestLength {
        case 0:
            return 15
        case 1:
            return 30
        case 2:
            return 60
        default:
            return 15
        }
    }
    
    //nil == no session available, no == no active session, yes == active session
    func checkSession(dataHelper: DataHelper) -> Int? {
        let sessions = dataHelper.getAllSessions()
        let currentMillis: NSNumber = NSDate.timeIntervalSinceReferenceDate() * 1000
        
        var timeToExpire: Int?
        for session in sessions {
            let sessionTimeLeft: Int = (session.dateCreated!.longLongValue + session.expireInMillis!.longLongValue) - currentMillis.longLongValue
            if sessionTimeLeft <= 0 {
                //session expired, delete session
                dataHelper.deleteSession(session)
            } else {
                //not expired, if session is active or request is sent and waiting for acceptance,
                //get the session with longest time to expire
                if session.sessionType == ACTIVE_SESSION || session.sessionType == SENT_SESSION {
                    if timeToExpire == nil || timeToExpire! < sessionTimeLeft {
                        timeToExpire = sessionTimeLeft
                    }
                } else {
                    if timeToExpire == nil {
                        timeToExpire = 0
                    }
                }
            }
        }
        //time left
        return timeToExpire
    }
    
    let SENT_SESSION = 100
    let RECEIVED_SESSION = 102
    let ACTIVE_SESSION = 103
    //time to expire after session request
    let DEFAULT_EXPIRE_TIME = 5.0
}