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
    static func onSignInClicked() {
        
        let digits = Digits.sharedInstance()
//        digits.logOut()
        let configuration = DGTAuthenticationConfiguration(accountFields: .DefaultOptionMask)
        
        configuration.appearance = DGTAppearance()
        
        configuration.appearance.accentColor = UIColor().primaryColor()
        
        digits.authenticateWithViewController(nil, configuration: configuration) {
            (session, error) in
        }
    }
}