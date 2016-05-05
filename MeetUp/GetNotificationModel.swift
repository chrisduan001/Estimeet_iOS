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
        makeNetworkRequest()
    }
    
    //MARK: EXTEND SUPER
    override func startNetworkRequest() {
        serviceHelper.getAllNotifications(baseUser!.userId!, userUId: baseUser!.userUId!, token: baseUser!.token!) { (response) in
            print("get all notification \(response.response)")
            
            let listItem = response.result.value
            guard !self.isAnyErrors(response.response!.statusCode, response: listItem) else {
                return
            }
            
            if listItem?.items != nil {
                for item in listItem!.items {
                    switch item.identifier {
                    case self.NOTIFICATION_FRIEND_REQUEST:
                        break
                    case self.NOTIFICATION_SESSION_REQUEST:
                        break
                    case self.NOTIFICAITON_SESSION_ACCEPTANCE:
                        break
                    default:break
                    }
                }
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