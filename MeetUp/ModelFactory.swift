//
//  ModelFactory.swift
//  MeetUp
//
//  Created by Chris Duan on 23/04/16.
//  Copyright © 2016 Chris. All rights reserved.
//

import Foundation
class ModelFactory {
    
    static let sharedInstance = ModelFactory()
    private init() {}
    
    let serviceHelper: ServiceHelper = ServiceHelper.sharedInstance
    let userDefaults: MeetUpUserDefaults = MeetUpUserDefaults.sharedInstance
    let dataHelper: DataHelper = DataHelper.sharedInstance
    
    func provideLoginModel(listener: LoginListener) -> LoginModel {
        return LoginModel(serviceHelper: serviceHelper, userDefaults: userDefaults, listener: listener)
    }
    
    func provideProfileModel(listener: ProfileListener) -> ProfileModel {
        return ProfileModel(serviceHelper: serviceHelper, userDefaults: userDefaults, listener: listener)
    }
    
    func provideFriendListModel(listener: FriendListListener) -> FriendListModel {
        return FriendListModel(serviceHelper: serviceHelper, userDefaults: userDefaults, dataHelper: dataHelper, listener: listener)
    }
}