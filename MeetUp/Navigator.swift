//
//  Navigator.swift
//  MeetUp
//
//  Created by Chris Duan on 6/03/16.
//  Copyright © 2016 Chris. All rights reserved.
//

import Foundation
class Navigator {
    static let sharedInstance = Navigator()
    
    private init() {
    }
    
    func navigateToLogin(vc: BaseViewController) {
        let modalVC = LoginViewController(nibName: "LoginViewController", bundle: nil)
        vc.presentViewController(modalVC, animated: true, completion: nil)
    }
    
    func navigateToProfilePage(vc: BaseViewController) {
        let modalVc = ProfileViewController(nibName: "ProfileViewController", bundle: nil)
        vc.presentViewController(modalVc, animated: true, completion: nil)
    }
}