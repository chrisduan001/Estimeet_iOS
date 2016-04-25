//
//  ViewController.swift
//  MeetUp
//
//  Created by Chris Duan on 16/02/16.
//  Copyright © 2016 Chris. All rights reserved.
//

import UIKit

class MainViewController: BaseViewController {
    var isAnyFriends: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let headerImg = UIImage(named: "navigation_icon")
        self.navigationItem.titleView = UIImageView(image: headerImg)
        
    }
    
    override func viewWillAppear(animated: Bool) {
        
    }
    
    override func viewDidAppear(animated: Bool) {
        let user = MeetUpUserDefaults.sharedInstance.getUserFromDefaults()

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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func tempButton(sender: UIButton) {
        Navigator.sharedInstance.navigateToLogin(self)
        MeetUpUserDefaults.sharedInstance.removeUserDefault()
    }
}

