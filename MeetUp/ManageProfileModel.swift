//
//  ManageProfileModel.swift
//  MeetUp
//
//  Created by Chris Duan on 25/04/16.
//  Copyright © 2016 Chris. All rights reserved.
//

import Foundation
class ManageProfileModel: BaseModel {
    private unowned let listener: BaseListener
    
    init(serviceHelper: ServiceHelper, userDefaults: MeetUpUserDefaults, listener: BaseListener) {
        self.listener = listener
        super.init(serviceHelper: serviceHelper, userDefaults: userDefaults)
    }
    
    func saveUserImage(image: NSData) {
        userDefaults.saveUserImageData(image)
    }
    
    func updateUserProfile(name: String, imageString: String) {
        
    }
    
    //MARK EXTEND SUPER
    override func startNetworkRequest() {
    }
    
    override func onAuthError() {}
    
    override func onError(message: String) {
    }
}