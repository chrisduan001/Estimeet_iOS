//
//  BaseModel.swift
//  MeetUp
//
//  Created by Chris Duan on 3/03/16.
//  Copyright © 2016 Chris. All rights reserved.
//

import Foundation
import Alamofire

class BaseModel: NSObject {
    let serviceHelper: ServiceHelper
    let userDefaults: MeetUpUserDefaults
    var baseUser: User?
    
    init(serviceHelper: ServiceHelper, userDefaults: MeetUpUserDefaults) {
        self.serviceHelper = serviceHelper
        self.userDefaults = userDefaults
        
        baseUser = userDefaults.getUserFromDefaults()
    }
    
    func isTokenExpired(expireTime: Int) -> Bool {
        return Int(NSDate().timeIntervalSinceReferenceDate) > expireTime
    }
    
    func makeNetworkRequest() {
        if isTokenExpired((baseUser?.expireTime)!) {
            serviceHelper.requestAuthToken(baseUser!.userId!, password: baseUser!.password!) {
                response in
                print("Token response: \(response.response)")
                guard self.processTokenResponse(response) else {
                    return
                }
                self.startNetworkRequest()
            }
        } else {
            startNetworkRequest()
        }
    }
    
    func processTokenResponse(response: Response<TokenResponse, NSError>) -> Bool {
        if self.isRenewTokenError(response) {
            return false
        }
        
        let tokenResponse = response.result.value!
        baseUser?.token = tokenResponse.accessToken
        //should renew 10 min before expires
        let expireTimeInSec = Int(NSDate().timeIntervalSinceReferenceDate) + tokenResponse.expiresIn - 600
        baseUser?.expireTime = expireTimeInSec
        MeetUpUserDefaults.sharedInstance.updateUserToken(tokenResponse.accessToken, expireInSeconds: expireTimeInSec)
        return true
    }
    
    func generateErrorMessage(errorCode: Int) {
        onError(ErrorFactory.generateErrorWithCode(errorCode)) 
    }
    
    //MARK: CHECK ERROR
    //check both http error(eg: internet, auth etc) and request error(eg: inconsisitent data)
    func isAnyErrors<T:BaseResponse>(response: Response<T, NSError>) -> Bool {
        if isHttpRequestError(response.response) || isHttpSessionError(response.response!.statusCode) {
            return true
        }
        
        let errorMessage = response.result.value == nil ?
            ErrorFactory.generateGenericErrorMessage() : response.result.value!.getErrorMessage()

        guard !errorMessage.isEmpty else {
            return false
        }
        
        onError(errorMessage)
        return true
    }
    
    //server not available, url not valid etc.
    private func isHttpRequestError(httpResponse: NSHTTPURLResponse?) -> Bool {
        guard httpResponse != nil else {
            onError(ErrorFactory.generateErrorWithCode(ErrorFactory.ERROR_NETWORK))
            return true
        }
        
        return false
    }
    
    //auth error, with status code == 400, 500 etc
    private func isHttpSessionError(statusCode: Int) -> Bool {
        guard statusCode == 200 else {
            isAuthError(statusCode) ? onAuthError() : onError(ErrorFactory.generateGenericErrorMessage())
            return true
        }
        
        return false
    }
    
    private func isRenewTokenError(statusCode: Int) -> Bool {
        if statusCode == 200 {
            return false
        }
        
        isAuthError(statusCode) ? onAuthError() : onError(ErrorFactory.generateGenericErrorMessage())
        return true
    }
    
    private func isRenewTokenError<T:BaseResponse>(response: Response<T, NSError>) -> Bool {
        return isHttpRequestError(response.response) || isHttpSessionError(response.response!.statusCode)
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