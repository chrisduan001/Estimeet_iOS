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
    
    private var request_type_cancel_session: Bool!
    private var session: SessionColumn!
    private var tempSessionModel: TempSessionModel!
    
    init(serviceHelper: ServiceHelper, userDefaults: MeetUpUserDefaults, dataHelper: DataHelper, sessionListener: SessionListener) {
        self.dataHelper = dataHelper
        self.sessionListener = sessionListener
        super.init(serviceHelper: serviceHelper, userDefaults: userDefaults)
    }
    
    func sendSessionRequest(friendObj: Friend) {
        request_type_cancel_session = false
        self.friendObj = friendObj
        notificationModel = NotificationEntity(senderId: baseUser!.userId!, receiverId: friendObj.userId! as Int, receiverUId: friendObj.userUId!)
        makeNetworkRequest()
        dataHelper.createSession(friendObj)
    }
    
    func checkSessionExpiration() {
        sessionListener.onCheckSessionExpiration(SessionFactory.sharedInstance.checkSession(dataHelper))
    }
    
    func cancelSession(friendObj: Friend) {
        request_type_cancel_session = true
        self.friendObj = friendObj
        session = friendObj.session!
        tempSessionModel = TempSessionModel()
        tempSessionModel.translateSessionToTempModel(session)
        SessionFactory.sharedInstance.deleteFriendSession(dataHelper, friend: friendObj)
        makeNetworkRequest()
    }
    
    //MARK: EXTEND SUPER
    override func startNetworkRequest() {
        if request_type_cancel_session! {
            serviceHelper.cancelSession(
            NotificationEntity(senderId: baseUser!.userId!,
                             receiverId: friendObj.userId!.integerValue,
                            receiverUId: friendObj.userUId!),
            token: baseUser!.token!) { (response) in
                if !response {
                    SessionFactory.sharedInstance.insertSession(self.dataHelper, session: self.tempSessionModel, friend: self.friendObj)
                    self.sessionListener.onError(ErrorFactory.generateErrorWithCode(ErrorFactory.GENERIC_ERROR_MESSAGE))
                }
            }
            

        } else {
            serviceHelper.sendRequestSession(notificationModel, length: 0, token: baseUser!.token!) { (response) in
                if !response {
                    self.onError(ErrorFactory.generateGenericErrorMessage())
                }
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
    func onCheckSessionExpiration(timeToExpire: NSNumber?)
}