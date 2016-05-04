//
//  PushModel.swift
//  MeetUp
//
//  Created by Chris Duan on 4/05/16.
//  Copyright © 2016 Chris. All rights reserved.
//

import Foundation
class PushModel: BaseModel {
    
    private let buildNumber: String!
    
    init(serviceHelper: ServiceHelper, userDefaults: MeetUpUserDefaults, build: String) {
        self.buildNumber = build
        super.init(serviceHelper: serviceHelper, userDefaults: userDefaults)
    }
    
    func registerPushChannel(deviceToken: NSData) {
        let hub = SBNotificationHub(connectionString: "Endpoint=sb://meetup.servicebus.windows.net/;SharedAccessKeyName=DefaultListenSharedAccessSignature;SharedAccessKey=3XEU5LpvQH7DsLfWIj4t+6csDar4B0PE83rxlm1qJDE=", notificationHubPath: "meetup")
        
        if userDefaults.getVersionCode() == nil || userDefaults.getVersionCode()! != buildNumber {
            userDefaults.setVersionCode(buildNumber)
            makeNetworkRequest()
        }

        let tag: Set<String> = [baseUser!.userUId!]
        do {
            try hub.registerNativeWithDeviceToken(deviceToken, tags: tag)
        } catch {}
    }
    
    //MARK: EXTEND SUPER
    override func startNetworkRequest() {
        serviceHelper.registerPushChannel(baseUser!.userId!, userUId: baseUser!.userUId!, token: baseUser!.token!) {
            (response) in
            print("register channel \(response.response)")
            
            self.isAnyErrors(response.response!.statusCode, response: response.result.value)
        }
    }
    
    override func onAuthError() {
        userDefaults.setVersionCode("")
    }
    
    override func onError(message: String) {
        userDefaults.setVersionCode("")
    }
}