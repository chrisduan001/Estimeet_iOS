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
    private var request_type_send_request: Bool!
    private var request_type_create_session: Bool!
    
    private var tempSessionModel: TempSessionModel!
    
    init(serviceHelper: ServiceHelper, userDefaults: MeetUpUserDefaults, dataHelper: DataHelper, sessionListener: SessionListener) {
        self.dataHelper = dataHelper
        self.sessionListener = sessionListener
        super.init(serviceHelper: serviceHelper, userDefaults: userDefaults)
    }
    
    //called when app on resume & when session completed or cancelled
    func checkSessionExpiration() {
        sessionListener.onCheckSessionExpiration(SessionFactory.sharedInstance.checkSession(dataHelper))
    }
    
    func sendSessionRequest(friendObj: Friend) {
        resetRequestType()
        request_type_send_request = true
        self.friendObj = friendObj
        notificationModel = NotificationEntity(senderId: baseUser!.userId!, receiverId: friendObj.userId! as Int, receiverUId: friendObj.userUId!)
        makeNetworkRequest()
        dataHelper.createSession(friendObj)
    }
    
    func cancelSession(friendObj: Friend) {
        resetRequestType()
        request_type_cancel_session = true
        storeTempSession(friendObj)
        removeSessionFromDb(friendObj)
        checkSessionExpiration()
        makeNetworkRequest()
    }
    
    func acceptNewSession(friendObj: Friend) {
        resetRequestType()
        request_type_create_session = true
        storeTempSession(friendObj)
        SessionFactory.sharedInstance.createActiveSession(friendObj.session!,
                                                          friendId: friendObj.userId!.integerValue,
                                                          sessionId: 0,
                                                          sessionLid: "",
                                                          expireInMillis: friendObj.session!.expireInMillis!,
                                                          length: friendObj.session!.sessionRequestedTime!.integerValue)
        
        notificationModel = NotificationEntity(senderId: baseUser!.userId!, receiverId: friendObj.userId!.integerValue, receiverUId: friendObj.userUId!)
        
        makeNetworkRequest()
    }
    
    private func storeTempSession(friendObj: Friend) {
        self.friendObj = friendObj
        tempSessionModel = TempSessionModel()
        tempSessionModel.translateSessionToTempModel(friendObj.session!)
    }
    
    private func resetRequestType() {
        request_type_cancel_session = false
        request_type_send_request = false
        request_type_create_session = false
    }
    
    func removeSessionFromDb(friendObj: Friend) {
        SessionFactory.sharedInstance.deleteFriendSession(dataHelper, friend: friendObj)
        if dataHelper.getAllSessions().count <= 0 {
            sessionListener.onNoSessionsAvailable()
        }
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
        } else if request_type_send_request! {
            serviceHelper.sendRequestSession(notificationModel, length: 0, token: baseUser!.token!) { (response) in
                if !response {
                    self.onError(ErrorFactory.generateGenericErrorMessage())
                    self.checkSessionExpiration()
                }
            }
        } else if request_type_create_session! {
            serviceHelper.createSession(SessionFactory.sharedInstance
                .getRequestTimeInMinutes(tempSessionModel.sessionRequestedTime!.integerValue),
                                        length: tempSessionModel.sessionRequestedTime!.integerValue,
                                        notificationEntity: notificationModel,
                                        token: baseUser!.token!,
                                        completionHandler: { (response) in
                                            guard !self.isAnyErrors(response) else {
                                                self.createSessionResponse = response.result.value
                                                return
                                            }
                                            
                                            let sessionResponse = response.result.value!
                                            SessionFactory.sharedInstance.updateSessionId(self.dataHelper,
                                                sessionId: sessionResponse.sessionId,
                                                sessionLid: sessionResponse.sessionLId,
                                                friend: self.friendObj)
                                            
                                            self.checkSessionExpiration()
            })
        }
    }
    
    override func onAuthError() {
        sessionListener.onAuthFail()
    }
    
    //check if the error is session expired error, need to delete session if the session has expired
    private var createSessionResponse: BaseResponse?
    override func onError(message: String) {
        if request_type_create_session! {
            if createSessionResponse?.errorCode == ErrorFactory.ERROR_SESSION_EXPIRED {
                SessionFactory.sharedInstance.deleteFriendSession(dataHelper, friend: friendObj)
            } else {
                SessionFactory.sharedInstance.insertSession(dataHelper, session: tempSessionModel, friend: friendObj)
            }
            
            return
        }
        if friendObj.session != nil {
            dataHelper.deleteSession(friendObj.session!)
        }
        sessionListener.onError(message)
    }
}

protocol SessionListener: BaseListener {
    func onCheckSessionExpiration(timeToExpire: NSNumber?)
    func onNoSessionsAvailable()
}