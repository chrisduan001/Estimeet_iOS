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
    
    init(serviceHelper: ServiceHelper, listener: ProfileListener) {
        self.listener = listener
        super.init(serviceHelper: serviceHelper)
    }
    
    func onStartUpdateProfile(name: String, imageString: String) {
        let user = MeetUpUserDefaults.sharedInstance.getUserFromDefaults()!
        if isTokenExpired(user.expireTime!) {
            serviceHelper.requestAuthToken(user.id!, password: user.password!) {
                response in
                guard !self.isRenewTokenError(response.response!.statusCode, listener: self.listener) else {
                    return
                }
                print("Response: \(response.response)")
                let token = response.result.value
                MeetUpUserDefaults.sharedInstance.updateUserToken(token!.accessToken, expireInSeconds: token!.expiresIn)
            }
        }
    }
}

protocol ProfileListener: BaseListener {
    func onProfileUpdated()
}