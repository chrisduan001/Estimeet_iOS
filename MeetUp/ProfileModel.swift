//
//  ProfileModel.swift
//  MeetUp
//
//  Created by Chris Duan on 6/03/16.
//  Copyright © 2016 Chris. All rights reserved.
//

import Foundation

class ProfileModel: BaseModel {
    unowned let listener: ProfileListener
    var updateModel: UpdateProfile!
    
    init(serviceHelper: ServiceHelper, userDefaults: MeetUpUserDefaults, listener: ProfileListener) {
        self.listener = listener
    
        super.init(serviceHelper: serviceHelper, userDefaults: userDefaults)
    }
    
    func onStartUpdateProfile(name: String, imageString: String) {
//        updateModel = UpdateProfile(id: baseUser!.userId!, userId: baseUser!.userUId!, imageString: imageString, userRegion: "", userName: name)
        makeNetworkRequest()
    }
    
    //MARK EXTEND SUPER
    override func startNetworkRequest() {
        //TODO..TEST ONLY
//        serviceHelper.updateProfile(updateModel, token: baseUser!.token!) {
//            response in
//            let user = response.result.value
//            guard !self.isAnyErrors(response.response!.statusCode, response: user) else {
//                return
//            }
//            print("Update profile response:\(response.response)")
//            self.userDefaults.updateUserProfile(user!.userName!, imageUri: user!.dpUri!)
//            
//            self.listener.onProfileUpdated()
//        }
        
        self.listener.onProfileUpdated()
    }
    
    override func onError(message: String) {
        listener.onError(message)
    }
    
    override func onAuthError() {
        listener.onAuthFail()
    }
}

protocol ProfileListener: BaseListener {
    func onProfileUpdated()
}