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
    
    func signInUser(authModel: SigninAuth, completionHandler: (response: Response<User, NSError>) -> Void) {
        let signInUri = ServiceHelper.BASE_URL + "/signin/signinuser"
        let request = Alamofire.request(.POST, signInUri, parameters: getJsonString(authModel), encoding: .JSON)
        request.responseObject {
            (response: Response<User, NSError>) in
            completionHandler(response: response)
        }
        
        logDebugInfo(request)
    }
    
    func updateProfile(updateModel: UpdateProfile, token: String, completionHandler: (response: Response<User, NSError>) -> Void) {
        let profileUri = ServiceHelper.BASE_URL + "/profile/updateuserprofile"
        let request = Alamofire.request(.POST, profileUri, parameters: getJsonString(updateModel), encoding: .JSON, headers: getAuthHeader(token))
        request.responseObject {
            (response: Response<User, NSError>) in
            completionHandler(response: response)
        }
        print("update profile request: \(request.request)")
    }
    
    func sendUserContacts(contactModel: Contacts, token: String) {
        let sendContactUri = ServiceHelper.BASE_URL + "/Profile/buildFriendsFromContacts"
        let request = Alamofire.request(.POST, sendContactUri, parameters: getJsonString(contactModel), encoding: .JSON, headers: getAuthHeader(token))

        print("send contact: \(request.request)")
    }
    
    func getFriendList(id: Int, userUId: CLong, token: String, completionHandler: (response: Response<ListItem<Friend>, NSError>) -> Void) {
        let getFriendListUri = "\(ServiceHelper.BASE_URL)/user/getfriendslist?id=\(id)&userid=\(userUId)"
        let request = Alamofire.request(.GET, getFriendListUri, parameters: nil, encoding: .JSON, headers: getAuthHeader(token))
        
        request.responseObject {
            (response: Response<ListItem<Friend>, NSError>) in
            completionHandler(response: response)
        }
        
        print("get friend list: \(request.request)")
    }
    
    private func getAuthHeader(token: String) -> [String: String] {
        return ["Authorization" : "Bearer \(token)"]
    }
    
    private func getJsonString<T:Mappable>(model: T) -> [String: AnyObject] {
        return Mapper().toJSON(model)
    }
    
    private func logDebugInfo(request:Request) {
        print("debug descriptin: \(request.debugDescription)")
    }
}


