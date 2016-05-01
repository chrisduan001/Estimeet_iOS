//
//  SessionModel.swift
//  MeetUp
//
//  Created by Chris Duan on 30/04/16.
//  Copyright © 2016 Chris. All rights reserved.
//

import Foundation
class SessionModel: BaseModel {
    
    private let dataHelper: DataHelper
    
    init(serviceHelper: ServiceHelper, userDefaults: MeetUpUserDefaults, dataHelper: DataHelper) {
        self.dataHelper = dataHelper
        super.init(serviceHelper: serviceHelper, userDefaults: userDefaults)
    }
    
    func sendSessionRequest(friendObj: Friend) {
        dataHelper.createSession(friendObj, withSessionType: SessionModel.SENT_SESSION)
    }
    
    static let SENT_SESSION = 100
    static let RECEIVED_SESSION = 102
    static let ACTIVE_SESSION = 103
}
