//
//  Navigator.swift
//  MeetUp
//
//  Created by Chris Duan on 6/03/16.
//  Copyright © 2016 Chris. All rights reserved.
//

import Foundation
import UIKit

class Navigator {
    static let sharedInstance = Navigator()
    
    private init() {}
    
    func navigateToLogin(vc: BaseViewController) {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.setLoginRootViewController()
        vc.navigationController?.popToRootViewControllerAnimated(true)
    }
    
    func navigateToProfilePage(vc: BaseViewController) {
        let modalVc = ProfileViewController(nibName: "ProfileViewController", bundle: nil)
        vc.presentViewController(modalVc, animated: true, completion: nil)
    }
    
    func navigateToFriendList(vc: BaseViewController) {
        let controller = ManageFriendViewController(nibName: "ManageFriendViewController", bundle: nil)
        vc.navigationController?.pushViewController(controller, animated: true)
    }
    
    func navigateToManageProfile(vc: BaseViewController) {
        let controller = ManageProfileViewController(nibName: "ManageProfileViewController", bundle: nil)
        vc.navigationController?.pushViewController(controller, animated: true)
    }
}