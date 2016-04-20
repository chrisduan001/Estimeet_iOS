//
//  BaseModel.swift
//  MeetUp
//
//  Created by Chris Duan on 3/03/16.
//  Copyright © 2016 Chris. All rights reserved.
//

import Foundation
import Alamofire

protocol BaseModel1 {
    func abc()
}

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
    
    func makeNetworkRequest() {
        if isTokenExpired((baseUser?.expireTime)!) {
            serviceHelper.requestAuthToken(baseUser!.id!, password: baseUser!.password!) {
                response in
                print("Token response: \(response.response)")
                guard self.processTokenResponse(response.response!.statusCode, tokenResponse: response.result.value) else {
                    return
                }
                self.startNetworkRequest()
            }
        } else {
            startNetworkRequest()
        }
    }
    
    func processTokenResponse(statusCode: Int, tokenResponse: TokenResponse?) -> Bool {
        if self.isRenewTokenError(statusCode) {
            return false
        }
        
        baseUser?.token = tokenResponse!.accessToken
        baseUser?.expireTime = tokenResponse!.expiresIn
        MeetUpUserDefaults.sharedInstance.updateUserToken(tokenResponse!.accessToken, expireInSeconds: tokenResponse!.expiresIn)
        return true
    }
    
    //MARK: CHECK ERROR
    //check both http error(eg: internet, auth etc) and request error(eg: inconsisitent data)
    func isAnyErrors(statusCode: Int, response: BaseResponse?) -> Bool {
        guard statusCode == 200 else {
            isAuthError(statusCode) ? onAuthError() : onError(ErrorFactory.generateGenericErrorMessage())
            return true
        }
        
        guard let errorMessage = response?.getErrorMessage() where !errorMessage.isEmpty else {
            return false
        }
    
        onError(errorMessage)
        return true
    }
    
    private func isRenewTokenError(statusCode: Int) -> Bool {
        if statusCode == 200 {
            return false
        }
        
        isAuthError(statusCode) ? onAuthError() : onError(ErrorFactory.generateGenericErrorMessage())
        return true
    }
    
    private func isAuthError(statusCode: Int) -> Bool {
        return statusCode >= 400 && statusCode < 500
    }
    
    //MARK SUB CLASS IMPLEMENTATION
    func startNetworkRequest() {
        throwUnImplementException()
    }
    
    func onAuthError()  {}
    
    func onError(message: String) {}
    
    private func throwUnImplementException() {
        NSException(name: "Not implement exception", reason: "This method has to be implemented", userInfo: nil).raise()
    }
}

protocol BaseListener: class {
    func onError(message: String)
    //if auth failed, nav user back to login screen
    //generally this shouldn't happen
    func onAuthFail()
}