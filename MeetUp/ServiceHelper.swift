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
    
    func getFriendList(id: Int, userUId: String, token: String, completionHandler: (response: Response<ListItem<FriendEntity>, NSError>) -> Void) {
        let getFriendListUri = "\(ServiceHelper.BASE_URL)/user/getfriendslist?id=\(id)&userid=\(userUId)"
        let request = Alamofire.request(.GET, getFriendListUri, parameters: nil, encoding: .JSON, headers: getAuthHeader(token))
        
        request.responseObject {
            (response: Response<ListItem<FriendEntity>, NSError>) in
            completionHandler(response: response)
        }
        
        print("get friend list: \(request.request)")
    }
    
    func registerPushChannel(id: Int, userUId: String, token: String, completionHandler: (response: Response<BaseResponse, NSError>) -> Void) {
        let regChannelUri = "\(ServiceHelper.BASE_URL)/user/registerchannel?channeltype=apn&id=\(id)&userid=\(userUId)"
        let request = Alamofire.request(.GET, regChannelUri, parameters: nil, encoding: .JSON, headers: getAuthHeader(token))
        
        request.responseObject { (response: Response<BaseResponse, NSError>) in
            completionHandler(response: response)
        }
        
        logDebugInfo(request)
    }
    
    func sendRequestSession(notificationModel: NotificationEntity, length: Int, token: String, completionHandler: (response: Bool) -> Void) {
        let requestSessionUrl = "\(ServiceHelper.BASE_URL)/user/sendRequestSessionNotification?length=\(length)"
        let request = Alamofire.request(.POST, requestSessionUrl, parameters: getJsonString(notificationModel), encoding: .JSON, headers: getAuthHeader(token))
        
        request.responseString { (response: Response<String, NSError>) in
            print("request session result \(response.response)")
            var result = false
            if let value = response.result.value {
                result = value == "true"
            }
            completionHandler(response: result)
        }
        
        logDebugInfo(request)
    }
    
    func getAllNotifications(userId: Int, userUId: String, token: String, completionHandler: (response: Response<ListItem<NotificationResponse>, NSError>) -> Void) {
        let getNotificationUrl = "\(ServiceHelper.BASE_URL)/user/getallnotifications?id=\(userId)&userid=\(userUId)"
        let request = Alamofire.request(.GET, getNotificationUrl, parameters: nil, encoding: .JSON, headers: getAuthHeader(token))
        
        request.responseObject { (response: Response<ListItem<NotificationResponse>, NSError>) in
            completionHandler(response: response)
        }
        
        logDebugInfo(request)
    }
    
    func deleteNotifications(userId: Int, userUid: String, notificationId: Int, token: String, completionHandler: (response: Bool) -> Void) {
        let deleteNotificationUrl = "\(ServiceHelper.BASE_URL)/user/deleteNotifications?id=\(userId)&userId=\(userUid)&notificationId=\(notificationId)"
        let request = Alamofire.request(.GET, deleteNotificationUrl, parameters: nil, encoding: .JSON, headers: getAuthHeader(token))
        
        request.responseString { (response: Response<String, NSError>) in
            print("request session result \(response.response)")
            var result = false
            if let value = response.result.value {
                result = value == "true"
            }
            
            completionHandler(response: result)
        }
        
        logDebugInfo(request)
    }
    
    func getTravelInfo(entity: RequestLocationEntity, token: String, completionHandler: (response: Response<ListItem<LocationModelResponse>, NSError>) -> Void) {
        let getTravelInfoUrl = "\(ServiceHelper.BASE_URL)/session/getsessiondata"
        let request = Alamofire.request(.POST, getTravelInfoUrl, parameters: getJsonString(entity), encoding: .JSON, headers: getAuthHeader(token))
        
        request.responseObject { (response: Response<ListItem<LocationModelResponse>, NSError>) in
            completionHandler(response: response)
        }
        
        logDebugInfo(request)
    }
    
    func createSession(expireInMinutes: Int, length: Int, notificationEntity: NotificationEntity, token: String, completionHandler: (response: Response<SessionResponse, NSError>) -> Void) {
        let createSessionUrl = "\(ServiceHelper.BASE_URL)/session/createsession?expiretimeinminutes=\(expireInMinutes)&length=\(length)"
        let request = Alamofire.request(.POST, createSessionUrl, parameters: getJsonString(notificationEntity), encoding: .JSON, headers: getAuthHeader(token))
        
        request.responseObject { (response: Response<SessionResponse, NSError>) in
            completionHandler(response: response)
        }
        
        logDebugInfo(request)
    }
    
    func sendGeoData(geoData: String, userUid: String, travelMode: Int, token: String, notificationModel: NotificationEntity,
                     completionHandler: (response: Bool) -> Void) {
        let sendGeoUrl = "\(ServiceHelper.BASE_URL)/user/sendgeodata?data=\(geoData)&useruid=\(userUid)&travelmode=\(travelMode)&neednotify=\(false)"
        
        let request = Alamofire.request(.POST, sendGeoUrl, parameters: getJsonString(notificationModel), encoding: .JSON, headers: getAuthHeader(token))
        
        request.responseString { (response:Response<String, NSError>) in
            print("request result \(response.response)")
        }
        
        logDebugInfo(request)
    }
    
    func sendGeoDataWithNotify(notificationEntity: NotificationEntity, userUid: String, geoData: String, travelMode: Int, token: String) {
        let url = "\(ServiceHelper.BASE_URL)/user/sendgeodatawithnotify?data=\(geoData)&useruid=\(userUid)&travelmode=\(travelMode)"
        let request = Alamofire.request(.POST, url, parameters: getJsonString(notificationEntity), encoding: .JSON, headers: getAuthHeader(token))
        
        print("send geo data with notify: \(request.request)")
    }
    
    func cancelSession(notificationEntity: NotificationEntity, token: String, completionHandler: (response: Bool) -> Void) {
        let cancelSessionUrl = "\(ServiceHelper.BASE_URL)/session/cancelsession"
        
        let request = Alamofire.request(.POST, cancelSessionUrl, parameters: getJsonString(notificationEntity), encoding: .JSON, headers: getAuthHeader(token))
        
        request.responseString { (response: Response<String, NSError>) in
            print("request result \(response.response)")
            var result = false
            if let value = response.result.value {
                result = value == "true"
            }
            
            completionHandler(response: result)
        }
        
        logDebugInfo(request)
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


