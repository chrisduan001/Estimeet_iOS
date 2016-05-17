//
//  TempSessionModel.swift
//  MeetUp
//
//  Created by Chris Duan on 17/05/16.
//  Copyright © 2016 Chris. All rights reserved.
//

import Foundation
//this model is used to hold session model temporarily, if the network call failed, this model will be used to re-insert value
class TempSessionModel {
    var dateCreated: NSNumber?
    var expireInMillis: NSNumber?
    var friendId: NSNumber?
    var sessionId: NSNumber?
    var sessionLId: String?
    var sessionLocation: String?
    var sessionRequestedTime: NSNumber?
    var sessionType: NSNumber?
    var friend: Friend?
    var sessionData: SessionData?
    
    func translateSessionToTempModel(session: SessionColumn) {
        dateCreated = session.dateCreated
        expireInMillis = session.expireInMillis
        friendId = session.friendId
        sessionId = session.sessionId
        sessionLId = session.sessionLId
        sessionLocation = session.sessionLocation
        sessionRequestedTime = session.sessionRequestedTime
        sessionType = session.sessionType
    }
    
    func translateTempModelToSession(session: SessionColumn) {
        session.dateCreated = dateCreated
        session.expireInMillis = expireInMillis
        session.friendId = friendId
        session.sessionId = sessionId
        session.sessionLId = sessionLId
        session.sessionLocation = sessionLocation
        session.sessionRequestedTime = sessionRequestedTime
        session.sessionType = sessionType
    }
}