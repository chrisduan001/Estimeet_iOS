//
//  FriendListModel.swift
//  MeetUp
//
//  Created by Chris Duan on 23/04/16.
//  Copyright © 2016 Chris. All rights reserved.
//

import Foundation

class FriendListModel: BaseModel {
    weak var listener: FriendListListener?
    private let dataHelper: DataHelper
    
    init(serviceHelper: ServiceHelper, userDefaults: MeetUpUserDefaults, dataHelper: DataHelper, listener: FriendListListener?) {
        self.listener = listener
        self.dataHelper = dataHelper
        super.init(serviceHelper: serviceHelper, userDefaults: userDefaults)
    }
    
    func getFriendList() {
        makeNetworkRequest()
    }
    
    func saveFriendImage(friendObj: Friend, imgData: NSData) {
        dataHelper.saveFriendImage(friendObj, imgData: imgData)
    }
    
    func setFavouriteFriend(friendObj: Friend) {
        dataHelper.setFavouriteFriend(friendObj)
    }
    
    func getFriendFetchedResultsController() {
        listener!.setFriendFetchedResultsController(dataHelper.getFriendsFetchedResults())
    }
    
    //MARK EXTEND SUPER
    override func startNetworkRequest() {
        serviceHelper.getFriendList(baseUser!.userId!, userUId: baseUser!.userUId!, token: baseUser!.token!) {
            response in
            print("get friend list response \(response.response)")
            let listItem = response.result.value
            guard !self.isAnyErrors(response) else {
                return
            }
            
            if listItem?.items != nil {
                let friendsList = listItem?.items as [FriendEntity]!
                self.dataHelper.storeFriendList(friendsList)
            }
            self.listener!.onGetFriendList()
        }
    }
    
    override func onAuthError() {
        super.onAuthError()
        listener!.onGetFriendList()
    }
    
    override func onError(message: String) {
        listener!.onGetFriendList()
    }
}

protocol FriendListListener: BaseListener {
    func onGetFriendList()
    func setFriendFetchedResultsController(fetchedResultsController: NSFetchedResultsController)
}
