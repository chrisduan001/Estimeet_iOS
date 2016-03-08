//
//  Facebook.swift
//  MeetUp
//
//  Created by Chris Duan on 8/03/16.
//  Copyright © 2016 Chris. All rights reserved.
//

import Foundation
import FBSDKLoginKit
import FBSDKCoreKit

class FacebookModel{
    func onStartFacebookLogin(viewController: UIViewController, listener: FbCallbackListener) {
        let fbLoginManager = FBSDKLoginManager()
        if FBSDKAccessToken.currentAccessToken() != nil {
            self.getFbData(listener)
        } else {
            fbLoginManager.logInWithReadPermissions(["public_profile"], fromViewController: viewController) {
                (result, error) -> Void in
                guard result.token != nil else {
                    return
                }
                self.getFbData(listener)
            }
        }
    }
    
    func getFbData(listener: FbCallbackListener) {
        let graphRequest: FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me?fields=id,name", parameters: nil)
        graphRequest.startWithCompletionHandler({ (connection, result:AnyObject!, error) -> Void in
            guard error == nil else {
                return
            }
            let id = result.valueForKey("id") as! String
            let userName = result.valueForKey("name") as! String
            print("Facebook login data: id \(id), name \(userName)")
            listener.onFacebookSuccessful(id, userName: userName)
        })
    }
}

protocol FbCallbackListener {
    func onFacebookSuccessful(id: String, userName: String)
}