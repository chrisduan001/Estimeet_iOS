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
    //time to expire after session request
    private let DEFAULT_EXPIRE_TIME = 5
    
    private func setupSessionTimeWithDefaultValue(session: SessionColumn) {
        session.expireInMillis = TimeConverter.sharedInstance.convertToMilliseconds(TimeType.MINUTES, value: DEFAULT_EXPIRE_TIME)
        session.dateCreated = NSDate.timeIntervalSinceReferenceDate() * 1000
    }
    
    func createRequestedSession(session: SessionColumn, friendId: NSNumber) {
        session.friendId = friendId
        session.sessionType = SENT_SESSION
        setupSessionTimeWithDefaultValue(session)
    }
    
    func checkSession(dataHelper: DataHelper) -> Bool {
        let sessions = dataHelper.getAllSessions()
        
        var isAnyActiveSession:Bool?
        for session in sessions {
        }
        
        return false
    }
    
    private let SENT_SESSION = 100
    private let RECEIVED_SESSION = 102
    private let ACTIVE_SESSION = 103
}