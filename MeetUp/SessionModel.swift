//
//  SessionModel.swift
//  MeetUp
//
//  Created by Chris Duan on 30/04/16.
//  Copyright © 2016 Chris. All rights reserved.
//

import Foundation
class SessionModel: BaseModel {
    private let sessionListener: SessionListener!
    
    private let dataHelper: DataHelper
    
    init(serviceHelper: ServiceHelper, userDefaults: MeetUpUserDefaults, dataHelper: DataHelper, sessionListener: SessionListener) {
        self.dataHelper = dataHelper
        self.sessionListener = sessionListener
        super.init(serviceHelper: serviceHelper, userDefaults: userDefaults)
    }
    
    func sendSessionRequest(friendObj: Friend) {
        dataHelper.createSession(friendObj)
    }
    
    func checkSessionExpiration() {
        SessionFactory.sharedInstance.checkSession(dataHelper)
    }
}

protocol SessionListener: BaseListener {
    func onCheckSessionExpiration(result: Bool?)
}