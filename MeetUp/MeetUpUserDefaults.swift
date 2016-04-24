//
//  MeetUpUserDefaults.swift
//  MeetUp
//
//  Created by Chris Duan on 6/03/16.
//  Copyright © 2016 Chris. All rights reserved.
//

import Foundation

class MeetUpUserDefaults {
    private let ID = "ID"
    private let USER_ID = "USER_ID"
    private let NAME = "USER_NAME"
    private let DP = "USER_DP"
    private let PHONE = "PHONE_NUMBER"
    private let PASSWORD = "PASSWORD"
    private let TOKEN = "AUTH_TOKEN"
    private let EXPIRES = "TOKEN_EXPIRE_TIME"

    static let sharedInstance = MeetUpUserDefaults()
    private init() {}
    
    func getUserFromDefaults() -> User? {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        let id = userDefaults.objectForKey(ID) as? Int
        let userId = userDefaults.objectForKey(USER_ID) as? CLong
        var name = userDefaults.objectForKey(NAME) as? String
        var dpUri = userDefaults.objectForKey(DP) as? String
        var phone = userDefaults.objectForKey(PHONE) as? String
        var password = userDefaults.objectForKey(PASSWORD) as? String
        var token = userDefaults.objectForKey(TOKEN) as? String
        var expire = userDefaults.objectForKey(EXPIRES) as? CLong
        
        guard id != nil && userId != nil else {
            return nil
        }

        name = name == nil ? "" : name!
        dpUri = dpUri == nil ? "" : dpUri!
        phone = phone == nil ? "" : phone!
        password = password == nil ? "" : password!
        token = token == nil ? "" : token!
        expire = expire == nil ? 0 : expire!
        
        
        return User(id: id!, userId: userId!, userName: name!, dpUri: dpUri!, phoneNumber: phone!, password: password!, token: token!, expireTime: expire!)
    }
    
    func saveUserDefault(user: User) {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        userDefaults.setInteger(user.userId!, forKey: ID)
        userDefaults.setInteger(user.userUId!, forKey: USER_ID)
        userDefaults.setObject(user.phoneNumber!, forKey: PHONE)
        userDefaults.setObject(user.password!, forKey: PASSWORD)
        
        userDefaults.synchronize()
    }
    
    func updateUserProfile(name: String, imageUri: String) {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        userDefaults.setObject(name, forKey: NAME)
        userDefaults.setObject(imageUri, forKey: DP)
        
        userDefaults.synchronize()
    }
    
    func updateUserToken(token:String, expireInSeconds: CLong) {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        userDefaults.setObject(token, forKey: TOKEN)
        let timeInSecond =  CLong(NSDate().timeIntervalSinceReferenceDate) + expireInSeconds
        //should renew 10 min before expires
        userDefaults.setInteger(timeInSecond - 600, forKey: EXPIRES)
        
        userDefaults.synchronize()
    }
    
    func removeUserDefault() {
//        NSUserDefaults.standardUserDefaults().removePersistentDomainForName(NSBundle.mainBundle().bundleIdentifier!)
    }
}


