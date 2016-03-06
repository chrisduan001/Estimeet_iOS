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
    
    enum HttpError {
        case AuthError, GenericError
    }
    
    init(serviceHelper: ServiceHelper) {
        self.serviceHelper = serviceHelper
    }
    
    //check both http error(eg: internet, auth etc) and request error(eg: inconsisitent data)
    func isAnyErrors(statusCode: Int, response: BaseResponse?, listener: BaseListener) -> Bool {
        guard statusCode == 200 else {
            statusCode == AppDelegate.plistDic?.objectForKey("error_auth") as! Int ? listener.onAuthFail() : listener.onError("An error has occured")
            return true
        }
        
        guard let errorMessage = response?.getErrorMessage() where !errorMessage.isEmpty else {
            return false
        }
    
        listener.onError(errorMessage)
        return true
    }
}

protocol BaseListener {
    func onError(message: String)
    //if auth failed, nav user back to login screen
    //generally this shouldn't happen
    func onAuthFail()
}