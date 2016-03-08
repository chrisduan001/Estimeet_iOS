//
//  ProfileModel.swift
//  MeetUp
//
//  Created by Chris Duan on 6/03/16.
//  Copyright © 2016 Chris. All rights reserved.
//

import Foundation

class ProfileModel: BaseModel {
    let listener: ProfileListener
    
    init(serviceHelper: ServiceHelper, userDefaults: MeetUpUserDefaults, listener: ProfileListener) {
        self.listener = listener
        super.init(serviceHelper: serviceHelper, userDefaults: userDefaults)
    }
    
    func onStartUpdateProfile(name: String, imageString: String) {
        let user = userDefaults.getUserFromDefaults()!
        if isTokenExpired(user.expireTime!) {
            serviceHelper.requestAuthToken(user.id!, password: user.password!) {
                response in
                print("Token response: \(response.response)")
                let tokenResponse = response.result.value
                guard self.processTokenResponse(response.response!.statusCode, tokenResponse: response.result.value, listener: self.listener) else {
                    return
                }
                user.token = tokenResponse!.accessToken
                self.updateProfile(user, imageString: imageString, name: name)
            }
        } else {
            updateProfile(user, imageString: imageString, name: name)
        }
    }
    
    private func updateProfile(user: User, imageString: String, name: String) {
        let updateModel = UpdateProfile(id: user.id!, userId: user.userId!, imageString: imageString, userRegion: "", userName: name)
        serviceHelper.updateProfile(updateModel, token: user.token!) {
            response in
            let user = response.result.value
            guard !self.isAnyErrors(response.response!.statusCode, response: user, listener: self.listener) else {
                return
            }
            print("Update profile response:\(response.response)")
            self.userDefaults.updateUserProfile(user!.userName!, imageUri: user!.dpUri!)
            
            self.listener.onProfileUpdated()
        }
    }
}

protocol ProfileListener: BaseListener {
    func onProfileUpdated()
}