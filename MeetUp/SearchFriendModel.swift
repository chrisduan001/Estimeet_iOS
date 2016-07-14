//
//  SearchFriendModel.swift
//  MeetUp
//
//  Created by Chris Duan on 11/07/16.
//  Copyright © 2016 Chris. All rights reserved.
//

import Foundation

class SearchFriendModel: BaseModel {
    unowned let listener: SearchFriendListener
    private let dataHelper: DataHelper
    
    private var phoneNumber: String!
    
    init(serviceHelper: ServiceHelper, userDefaults: MeetUpUserDefaults, dataHelper: DataHelper, listener: SearchFriendListener) {
        self.listener = listener
        self.dataHelper = dataHelper
        super.init(serviceHelper: serviceHelper, userDefaults: userDefaults)
    }
    
    func searchFriendByPhoneNumber(phone: String) {
        phoneNumber = phone
        
        makeNetworkRequest()
    }
    
    //MARK EXTEND SUPER
    override func startNetworkRequest() {
        serviceHelper.searchFriendByPhoneNumber(phoneNumber!, token: baseUser!.token!) {
            response in
            print("Search friend result \(response.response)")
            guard !self.isAnyErrors(response) else {
                return
            }
            
            if let listItem = response.result.value,
                let data = listItem.items {
                
                let friendList: [UserFromSearch] = data.map { obj in
                    obj.isFriend = self.dataHelper.getFriend(obj.userId!) != nil
                    return obj
                }
                self.listener.onSearchResult(friendList)
            } else {
                self.listener.onSearchResult([])
            }
        }
    }
    
    override func onAuthError() {
        listener.onSearchFailed()
    }
    
    override func onError(message: String) {
        listener.onSearchFailed()
    }
}
protocol SearchFriendListener: BaseListener {
    func onSearchResult(users: [UserFromSearch])
    func onSearchFailed()
}