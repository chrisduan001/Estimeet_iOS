//
//  ServiceHelper.swift
//  MeetUp
//
//  Created by Chris Duan on 2/03/16.
//  Copyright © 2016 Chris. All rights reserved.
//

import Foundation
import Alamofire
import AlamofireObjectMapper
import ObjectMapper

class ServiceHelper {
    static let BASE_URL = "https://estimeetprojapi.azurewebsites.net/api"
    
    static let sharedInstance = ServiceHelper()
    private init() {} //prevents other from using init() initlizer, will throw error if do so
    
    func requestSampleData(completionHandler: (response: Response<User, NSError>) -> Void) {
        let sampleDataUri = ServiceHelper.BASE_URL + "/signin/getsimpledata"
        Alamofire.request(.GET, sampleDataUri).responseObject {
            (response: Response<User, NSError>) in
            completionHandler(response: response)
        }
    }
    
    func signInUser(authModel: SigninAuth, completionHandler: (response: Response<User, NSError>) -> Void) {
        let signInUri = ServiceHelper.BASE_URL + "/signin/signinuser"
        let jsonString = Mapper().toJSON(authModel)
        let request = Alamofire.request(.POST, signInUri, parameters: jsonString, encoding: .JSON)
        request.responseObject {
            (response: Response<User, NSError>) in
            completionHandler(response: response)
        }
        logDebugInfo(request)
    }
    
    func requestAuthToken(id: Int, password: String, completionHandler: (response: Response<TokenResponse, NSError>) -> Void) {
        let tokenUri = ServiceHelper.BASE_URL + "/estimeetauth/token"
        let json = ["grant_type":"password", "username":id, "password":password]
        let request = Alamofire.request(.POST, tokenUri, parameters: json as? [String : AnyObject])
        request.responseObject {
            (response: Response<TokenResponse, NSError>) in
            completionHandler(response: response)
        }
        logDebugInfo(request)
    }
    
    private func logDebugInfo(request:Request) {
        print("debug descriptin: \(request.debugDescription)")
    }
}