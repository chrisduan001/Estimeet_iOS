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
    private var updateModel: UpdateProfile!
    private var isRegister: Bool!
    
    init(serviceHelper: ServiceHelper, userDefaults: MeetUpUserDefaults, listener: ProfileListener) {
        self.listener = listener
    
        super.init(serviceHelper: serviceHelper, userDefaults: userDefaults)
    }
    
    func onStartUpdateProfile(name: String, imageString: String, isRegister: Bool) {
        self.isRegister = isRegister
        updateModel = UpdateProfile(userId: baseUser!.userId!, userUId: baseUser!.userUId!, imageString: imageString, userRegion: "", userName: name)
        
        makeNetworkRequest()
    }
    
    func saveUserImage(image: NSData) {
        userDefaults.saveUserImageData(image)
    }
    
    func resetUserProfile() {
        listener.onResetUserProfile(userDefaults.getUserFromDefaults()!)
    }
    
    //MARK EXTEND SUPER
    override func startNetworkRequest() {
        serviceHelper.updateProfile(updateModel, isRegister: isRegister, token: baseUser!.token!) {
            response in
            let user = response.result.value
            guard !self.isAnyErrors(response) else {
                return
            }
            print("Update profile response:\(response.response)")
            self.userDefaults.updateUserProfile(user!.userName!, imageUri: user!.dpUri!)
            
            self.listener.onProfileUpdated()
        }
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
    func onResetUserProfile(user: User)
}