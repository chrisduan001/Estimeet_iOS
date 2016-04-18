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
    var baseUser: User?
    
    init(serviceHelper: ServiceHelper, userDefaults: MeetUpUserDefaults) {
        self.serviceHelper = serviceHelper
        self.userDefaults = userDefaults
        
        baseUser = userDefaults.getUserFromDefaults()
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
            isAuthError(statusCode) ? listener.onAuthFail() : listener.onError(ErrorFactory.generateGenericErrorMessage())
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
        
        isAuthError(statusCode) ? listener.onAuthFail() : listener.onError(ErrorFactory.generateGenericErrorMessage())
        return true
    }
    
    private func isAuthError(statusCode: Int) -> Bool {
        return statusCode >= 400 && statusCode < 500
    }
}

protocol BaseListener: class {
    func onError(message: String)
    //if auth failed, nav user back to login screen
    //generally this shouldn't happen
    func onAuthFail()
}