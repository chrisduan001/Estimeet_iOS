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
    let listener: ServiceListener
    
    init(serviceHelper: ServiceHelper, listener: ServiceListener) {
        self.listener = listener
        super.init(serviceHelper: serviceHelper)
    }
    
    func onStartSignin(signinAuth: SigninAuth) {
        serviceHelper.signInUser(signinAuth) {
            response in
            print(response.request)
            let user = response.result.value
            if !self.isAnyErrors((response.response?.statusCode)!, response: user, listener: self.listener) {
                MeetUpUserDefaults.sharedInstance.saveUserDefault(user!)
                self.listener.onLoginSuccess(user!)
            }
        }
    }
    
    func getData() -> String {
        return "AA"
    }
}

protocol ServiceListener: BaseListener {
    func onLoginSuccess(user: User)
}