//
//  FabricLogger.swift
//  MeetUp
//
//  Created by Chris Duan on 2/07/16.
//  Copyright © 2016 Chris. All rights reserved.
//

import Crashlytics

class FabricLogger {
    static let sharedInstance = FabricLogger()
    private init() {}
    
    func logError(message: String, className: String, code: Int, userInfo: [NSObject: AnyObject]?) {
        let errorMsg = "\(message). Class: \(className). UserId: \(ModelFactory.sharedInstance.provideUserDefaults().getUserUid())"
        Crashlytics.sharedInstance().recordError(NSError(domain: errorMsg, code: code, userInfo: userInfo))
    }
}
