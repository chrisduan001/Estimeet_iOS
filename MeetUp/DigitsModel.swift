//
//  DigitsModel.swift
//  MeetUp
//
//  Created by Chris Duan on 5/03/16.
//  Copyright © 2016 Chris. All rights reserved.
//

import Foundation
import DigitsKit

class DigitsModel {
    static func onSignInClicked(completionHandler: (signinAuth: SigninAuth?) -> Void) {
        
        let digits = Digits.sharedInstance()
        
        let configuration = DGTAuthenticationConfiguration(accountFields: .DefaultOptionMask)
        
        configuration.appearance = DGTAppearance()
        configuration.appearance.accentColor = UIColor().primaryColor()
        configuration.phoneNumber = "+64"
        
        digits.authenticateWithViewController(nil, configuration: configuration) {
            (session, error) in
            guard session != nil else {
                completionHandler(signinAuth: nil)
                return
            }
            
            let oauthSigning = DGTOAuthSigning(authConfig: digits.authConfig, authSession: digits.session())
            let authHeader = oauthSigning.OAuthEchoHeadersToVerifyCredentials()
            
            let uri = authHeader["X-Auth-Service-Provider"] as! String
            let header = authHeader["X-Verify-Credentials-Authorization"] as! String
            let phoneNumber = session!.phoneNumber.stringByReplacingOccurrencesOfString("+", withString: "")
            let model = SigninAuth(authHeader: header, authUri: uri, userId: CLong(session!.userID)!, phoneNumber: phoneNumber)
            completionHandler(signinAuth: model)
        }
    }
}