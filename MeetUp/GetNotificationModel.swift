//
//  GetNotificationModel.swift
//  MeetUp
//
//  Created by Chris Duan on 5/05/16.
//  Copyright © 2016 Chris. All rights reserved.
//

import Foundation
class GetNotificationModel: BaseModel {
    private let getNotificationListener: GetNotificationListener!
    private let dataHelper: DataHelper!
    
    init(serviceHelper: ServiceHelper, userDefaults: MeetUpUserDefaults, dataHelper: DataHelper, listener: GetNotificationListener) {
        self.getNotificationListener = listener
        self.dataHelper = dataHelper
        
        super.init(serviceHelper: serviceHelper, userDefaults: userDefaults)
    }
    
    func getAllNotifications() {
        if baseUser == nil {
            return
        }
        makeNetworkRequest()
    }
    
    private func processFriendRequest(appendix: String) {
        let appendixArray = appendix.componentsSeparatedByString(",")
        let userId = Int(appendixArray[0])
        let userUId = appendixArray[1]
        let userName = appendixArray[2]
        let dpUri = appendixArray[3]
        let friendEntity = FriendEntity(userId: userId!, userUId: userUId, userName: userName, dpUri: dpUri, image: nil, isFavourite: false)
        
        dataHelper.saveFriend(friendEntity)
    }
    
    private func processSessionRequest(appendix: String) {
        let appendixArray = appendix.componentsSeparatedByString(",")
        let friendId = Int(appendixArray[0])
        //request length to share (0,1,2)
        let length = Int(appendixArray[1])
        guard let friendObj = dataHelper.getFriend(friendId!) else {
            return
        }
        
        dataHelper.createPendingSession(friendId!, requestedTime: length!, friendObj: friendObj)
    }
    
    private func createNewSession(appendix: String) {
        let appendixArray = appendix.componentsSeparatedByString(",")
        let friendId = Int(appendixArray[0])
        let sessionId = Int(appendixArray[1])
        let sessionLId = appendixArray[2]
        let length = Int(appendixArray[3])
        let expireInMillis = NSNumber(longLong: CLongLong(appendixArray[5])!)
        
        guard let friendObj = dataHelper.getFriend(friendId!) else {
            return
        }
        
        dataHelper.createActiveSession(friendId!, sessionId: sessionId!, sessionLId: sessionLId, expireInMillis: expireInMillis, length: length!, friendObj: friendObj)
    }
    
    private func deleteNotification(notificationId: Int) {
        serviceHelper.deleteNotifications(baseUser!.userId!, userUid: baseUser!.userUId!, notificationId: notificationId, token: baseUser!.token!) { (response) in
            if response {
                self.userDefaults.setNotificationId(0)
            }
        }
    }
    
    //MARK: EXTEND SUPER
    override func startNetworkRequest() {
        serviceHelper.getAllNotifications(baseUser!.userId!, userUId: baseUser!.userUId!, token: baseUser!.token!) { (response) in
            print("get all notification \(response.response)")
            
            let listItem = response.result.value
            guard !self.isAnyErrors(response.response!.statusCode, response: listItem) else {
                return
            }
            
            let storedNotificationId = self.userDefaults.getNotificaitonId()
            var notificationId = 0
            if listItem?.items != nil {
                for item in listItem!.items {
                    //notification item already processed
                    if storedNotificationId > item.notificationId {
                        continue
                    }
                    
                    switch item.identifier {
                    case self.NOTIFICATION_FRIEND_REQUEST:
                        self.processFriendRequest(item.appendix)
                        break
                    case self.NOTIFICATION_SESSION_REQUEST:
                        self.processSessionRequest(item.appendix)
                        break
                    case self.NOTIFICAITON_SESSION_ACCEPTANCE:
                        self.createNewSession(item.appendix)
                        break
                    default:break
                    }
                    
                    if item.notificationId > notificationId {
                        notificationId = item.notificationId
                    }
                }
            }
            self.userDefaults.setNotificationId(notificationId)
            if notificationId != 0 {
                self.deleteNotification(notificationId)
            }
        }
    }
    
    override func onAuthError() {
        getNotificationListener.onAuthFail()
    }
    
    override func onError(message: String) {
        getNotificationListener.onError(message)
    }
    
    private let NOTIFICATION_FRIEND_REQUEST = 0
    private let NOTIFICATION_SESSION_REQUEST = 1
    private let NOTIFICAITON_SESSION_ACCEPTANCE = 2
}

protocol GetNotificationListener: BaseListener {
    func onCreateNewSession(expireTimeInMilli: NSNumber)
}




