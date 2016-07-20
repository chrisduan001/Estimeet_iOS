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
    unowned let listener: LoginListener
    var contactModel:Contacts!
    
    init(serviceHelper: ServiceHelper, userDefaults: MeetUpUserDefaults, listener: LoginListener) {
        self.listener = listener
        super.init(serviceHelper: serviceHelper, userDefaults: userDefaults)
    }
    
    func onStartSignin(signinAuth: SigninAuth) {
        serviceHelper.signInUser(signinAuth) {
            response in
            print("sign in response: \(response.response)")
            let user = response.result.value
            if !self.isAnyErrors(response) {
                self.userDefaults.saveUserDefault(user!)
                //update baseuser data. password will be changed
                self.baseUser = self.userDefaults.getUserFromDefaults()
                if let name = user?.userName where !name.isEmpty {
                    self.userDefaults.updateUserProfile(name, imageUri: user!.dpUri!)
                }
                
                self.listener.setUser(user!)
            }
        }
    }
    
    func onManualSignin(userName: String, password: String) {
        serviceHelper.manualSignIn(userName, password: password) { (response) in
            print("sign in response: \(response.response)")
            let user = response.result.value
            if !self.isAnyErrors(response) {
                self.userDefaults.saveUserDefault(user!)
                //update baseuser data. password will be changed
                self.baseUser = self.userDefaults.getUserFromDefaults()
                if let name = user?.userName where !name.isEmpty {
                    self.userDefaults.updateUserProfile(name, imageUri: user!.dpUri!)
                }
                
                self.listener.setUser(user!)
            }
        }
    }
    
    func sendContactList(contactList: String) {
        guard !contactList.isEmpty else {
            return
        }
        contactModel = Contacts(userId: baseUser!.userId!, userUId: baseUser!.userUId!, contacts: contactList)
        makeNetworkRequest()
    }
    
    //MARK EXTEND SUPER
    //this will only called when the previous call is successful
    override func startNetworkRequest() {
        serviceHelper.sendUserContacts(contactModel, token: baseUser!.token!)
    }
    
    override func onError(message: String) {
        listener.onError(message)
    }
}

protocol LoginListener: BaseListener {
    func setUser(user: User)
}