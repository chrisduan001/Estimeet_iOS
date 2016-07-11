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
    
    private var phoneNumber: String!
    
    init(serviceHelper: ServiceHelper, userDefaults: MeetUpUserDefaults, listener: SearchFriendListener) {
        self.listener = listener
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
            if let listItem = response.result.value,
                let data = listItem.items,
                let friendList = data as [User]? {
                self.listener.onSearchResult(friendList)
            }
        }
    }
    
    override func onAuthError() {}
    
    override func onError(message: String) {}
}
protocol SearchFriendListener: BaseListener {
    func onSearchResult(users: [User])
}