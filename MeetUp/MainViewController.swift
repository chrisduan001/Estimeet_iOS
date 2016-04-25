//
//  ViewController.swift
//  MeetUp
//
//  Created by Chris Duan on 16/02/16.
//  Copyright © 2016 Chris. All rights reserved.
//

import UIKit

class MainViewController: BaseViewController {
    var isAnyFriends: Bool = false
    
    private var user: User?
    
    //MARK: LIFECYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let headerImg = UIImage(named: "navigation_icon")
        self.navigationItem.titleView = UIImageView(image: headerImg)
        
        user = MeetUpUserDefaults.sharedInstance.getUserFromDefaults()
    }
    
    override func viewDidAppear(animated: Bool) {
        guard user != nil && !(user?.userName?.isEmpty)! else{
            if user == nil {
                Navigator.sharedInstance.navigateToLogin(self)
            } else {
                Navigator.sharedInstance.navigateToProfilePage(self)
            }
            return
        }
        
        if isAnyFriends {
            Navigator.sharedInstance.navigateToFriendList(self)
        }
    }
    
    @IBAction func onManageFriend(sender: UIBarButtonItem) {
        Navigator.sharedInstance.navigateToFriendList(self)
    }
    
    @IBAction func onManageProfile(sender: UIBarButtonItem) {
        Navigator.sharedInstance.navigateToManageProfile(self, user: user!)
    }
}

