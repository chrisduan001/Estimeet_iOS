//
//  AddFriendModel.swift
//  MeetUp
//
//  Created by Chris Duan on 11/07/16.
//  Copyright © 2016 Chris. All rights reserved.
//

import Foundation
class AddFriendModel: BaseModel {
    unowned let listener: AddFriendListener
    private let dataHelper: DataHelper
    
    private var friend: User!
    
    init(serviceHelper: ServiceHelper, userDefaults: MeetUpUserDefaults, dataHelper: DataHelper, listener: AddFriendListener) {
        self.listener = listener
        self.dataHelper = dataHelper
        super.init(serviceHelper: serviceHelper, userDefaults: userDefaults)
    }
    
    func requestAddFriend(friend: User) {
        self.friend = friend
        makeNetworkRequest()
    }
    
    //MARK: EXTEND SUPER
    override func startNetworkRequest() {
        let entity = AddFriendEntity(senderId: baseUser!.userId!, senderUid: baseUser!.userUId!, friendId: friend.userId!, friendUid: friend.userUId!)
        serviceHelper.requestAddFriend(entity, token: baseUser!.token!) {
            response in
            if !response {
                self.onError(ErrorFactory.generateErrorWithCode(ErrorFactory.ERROR_ADD_FRIEND))
            } else {
                let friendEntity = FriendEntity(userId: self.friend.userId!, userUId: self.friend.userUId!, userName: self.friend.userName!, dpUri: self.friend.dpUri!, image: self.friend.image, isFavourite: true)
                self.dataHelper.saveFriend(friendEntity)
                self.listener.onAddFriendSuccessful()
            }
        }
    }
    
    override func onAuthError() {
        onError("")
    }
    
    override func onError(message: String) {
        listener.onAddFriendFailed(message)
    }
}

protocol AddFriendListener: BaseListener {
    func onAddFriendSuccessful()
    func onAddFriendFailed(message: String)
}