//
//  LoginModel.swift
//  MeetUp
//
//  Created by Chris Duan on 25/02/16.
//  Copyright © 2016 Chris. All rights reserved.
//

import Foundation
import DigitsKit

class LoginModel: BaseModel {
    let listener: LoginListener
    
    init(serviceHelper: ServiceHelper, userDefaults: MeetUpUserDefaults, listener: LoginListener) {
        self.listener = listener
        super.init(serviceHelper: serviceHelper, userDefaults: userDefaults)
    }
    
    func onStartSignin(signinAuth: SigninAuth) {
        serviceHelper.signInUser(signinAuth) {
            response in
            let user = response.result.value
            if !self.isAnyErrors((response.response?.statusCode)!, response: user, listener: self.listener) {
                self.userDefaults.saveUserDefault(user!)
                
                if let name = user?.userName where !name.isEmpty {
                    self.userDefaults.updateUserProfile(name, imageUri: user!.dpUri!)
                }
                
                self.listener.onLoginSuccess(user!)
            }
        }
    }
}

protocol LoginListener: BaseListener {
    func onLoginSuccess(user: User)
}