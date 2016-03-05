//
//  BaseModel.swift
//  MeetUp
//
//  Created by Chris Duan on 3/03/16.
//  Copyright © 2016 Chris. All rights reserved.
//

import Foundation

class BaseModel {
    
    let serviceHelper: ServiceHelper
    let plistDic: NSDictionary
    
    enum HttpError {
        case AuthError, GenericError
    }
    
    init(serviceHelper: ServiceHelper) {
        self.serviceHelper = serviceHelper
        
        let filePath = NSBundle.mainBundle().pathForResource("GlobalVariable", ofType: "plist")
        plistDic = NSDictionary(contentsOfFile: filePath!)!
    }
    
    func checkErrors(statusCode: Int, listener: BaseListener) -> Bool {
        guard statusCode == 200 else {
            statusCode == plistDic.objectForKey("error_auth") as! Int ? listener.onAuthFail() : listener.onError("An error has occured")
            return false
        }
    
        return true
    }
}

protocol BaseListener {
    func onError(message: String)
    //if auth failed, nav user back to login screen
    //generally this shouldn't happen
    func onAuthFail()
}