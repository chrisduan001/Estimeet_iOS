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
    private let userDefaults: MeetUpUserDefaults = MeetUpUserDefaults.sharedInstance
    let dataHelper: DataHelper = DataHelper.sharedInstance
    
    func provideUserDefaults() -> MeetUpUserDefaults {
        return MeetUpUserDefaults.sharedInstance
    }
    
    func provideVersionNumber() -> String {
        let dictionary = NSBundle.mainBundle().infoDictionary!
        let build = dictionary["CFBundleVersion"] as! String
        
        return build
    }
    
    func provideLoginModel(listener: LoginListener) -> LoginModel {
        return LoginModel(serviceHelper: serviceHelper, userDefaults: userDefaults, listener: listener)
    }
    
    func provideProfileModel(listener: ProfileListener) -> ProfileModel {
        return ProfileModel(serviceHelper: serviceHelper, userDefaults: userDefaults, listener: listener)
    }
    
    func provideFriendListModel(listener: FriendListListener?) -> FriendListModel {
        return FriendListModel(serviceHelper: serviceHelper, userDefaults: userDefaults, dataHelper: dataHelper, listener: listener)
    }
    
    func provideManageProfileModel(listener: BaseListener) -> ManageProfileModel {
        return ManageProfileModel(serviceHelper: serviceHelper, userDefaults: userDefaults, listener: listener)
    }
    
    func provideMainModel(listener: MainModelListener) -> MainModel {
        return MainModel(serviceHelper: serviceHelper, userDefaults: userDefaults, dataHelper: dataHelper, listener: listener)
    }
    
    func provideSessionModel(listener: SessionListener) -> SessionModel {
        return SessionModel(serviceHelper: serviceHelper, userDefaults: userDefaults, dataHelper: dataHelper, sessionListener: listener)
    }
    
    func providePushChannelModel() -> PushChannelModel {
        return PushChannelModel(serviceHelper: serviceHelper, userDefaults: userDefaults, build: provideVersionNumber())
    }
    
    func provideGetNotificationModel(listener: GetNotificationListener) -> GetNotificationModel {
        return GetNotificationModel(serviceHelper: serviceHelper, userDefaults: userDefaults, dataHelper: dataHelper, listener: listener)
    }
    
    func provideLocationServicemodel<T : LocationServiceModel>(listener: LocationServiceListener?) -> T {
        return T(serviceHelper: serviceHelper, userDefaults: userDefaults, listener: listener)
    }
}