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
    
    private var friendObj: Friend!
    private var notificationModel: NotificationEntity!
    
    init(serviceHelper: ServiceHelper, userDefaults: MeetUpUserDefaults, dataHelper: DataHelper, sessionListener: SessionListener) {
        self.dataHelper = dataHelper
        self.sessionListener = sessionListener
        super.init(serviceHelper: serviceHelper, userDefaults: userDefaults)
    }
    
    func sendSessionRequest(friendObj: Friend) {
        self.friendObj = friendObj
        notificationModel = NotificationEntity(senderId: baseUser!.userId!, receiverId: friendObj.userId! as Int, receiverUId: friendObj.userUId!)
        makeNetworkRequest()
        dataHelper.createSession(friendObj)
    }
    
    func checkSessionExpiration() {
        SessionFactory.sharedInstance.checkSession(dataHelper)
    }
    
    //MARK: EXTEND SUPER
    override func startNetworkRequest() {
        serviceHelper.sendRequestSession(notificationModel, length: 0, token: baseUser!.token!) { (response) in
            if !response {
                self.onError(ErrorFactory.generateGenericErrorMessage())
            }
        }
    }
    
    override func onAuthError() {
        sessionListener.onAuthFail()
    }
    
    override func onError(message: String) {
        if friendObj.session != nil {
            dataHelper.deleteSession(friendObj.session!)
        }
        sessionListener.onError(message)
    }
}

protocol SessionListener: BaseListener {
    func onCheckSessionExpiration(result: Bool?)
}