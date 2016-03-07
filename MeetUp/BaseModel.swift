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
    let userDefaults: MeetUpUserDefaults
    
    enum HttpError {
        case AuthError, GenericError
    }
    
    init(serviceHelper: ServiceHelper, userDefaults: MeetUpUserDefaults) {
        self.serviceHelper = serviceHelper
        self.userDefaults = userDefaults
    }
    
    func isTokenExpired(expireTime: CLong) -> Bool {
        return CLong(NSDate().timeIntervalSinceReferenceDate) > expireTime
    }
    
    func processTokenResponse(statusCode: Int, tokenResponse: TokenResponse?, listener: BaseListener) -> Bool {
        guard !self.isRenewTokenError(statusCode, listener: listener) else {
            return false
        }
        
        MeetUpUserDefaults.sharedInstance.updateUserToken(tokenResponse!.accessToken, expireInSeconds: tokenResponse!.expiresIn)
        return true
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
    
    private func isRenewTokenError(statusCode: Int, listener: BaseListener) -> Bool {
        guard statusCode != 200 else {
            return false
        }
        
        statusCode >= 400 && statusCode < 500 ? listener.onAuthFail() : listener.onError("An error has occured")
        return true
    }
}

protocol BaseListener {
    func onError(message: String)
    //if auth failed, nav user back to login screen
    //generally this shouldn't happen
    func onAuthFail()
}