//
//  FriendListModel.swift
//  MeetUp
//
//  Created by Chris Duan on 23/04/16.
//  Copyright © 2016 Chris. All rights reserved.
//

import Foundation

class FriendListModel: BaseModel {
    unowned let listener: FriendListListener
    private let dataHelper: DataHelper
    
    init(serviceHelper: ServiceHelper, userDefaults: MeetUpUserDefaults, dataHelper: DataHelper, listener: FriendListListener) {
        self.listener = listener
        self.dataHelper = dataHelper
        super.init(serviceHelper: serviceHelper, userDefaults: userDefaults)
    }
    
    func getFriendList() {
        makeNetworkRequest()
    }
    
    func getDbFriends() {
        listener.onGetFriendList(dataHelper.getFriends())
    }
    
    func saveFriendImage(id: Int, imgData: NSData) {
        dataHelper.saveFriendImage(id, imgData: imgData)
    }
    
    //MARK EXTEND SUPER
    override func startNetworkRequest() {
        serviceHelper.getFriendList(baseUser!.userId!, userUId: baseUser!.userUId!, token: baseUser!.token!) {
            response in
            let listItem = response.result.value
            guard !self.isAnyErrors(response.response!.statusCode, response: listItem) else {
                return
            }
            
            if listItem?.items != nil {
                let friendsList = listItem?.items as [FriendEntity]!
                self.dataHelper.storeFriendList(friendsList)
            }
            self.listener.onGetFriendList(listItem?.items)
        }
    }
    
    override func onAuthError() {
        listener.onGetFriendList(nil)
    }
    
    override func onError(message: String) {
        listener.onGetFriendList(nil)
    }
}

protocol FriendListListener: BaseListener {
    func onGetFriendList(friends: [FriendEntity]?)
}
