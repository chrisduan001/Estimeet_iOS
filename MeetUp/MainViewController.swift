//
//  ViewController.swift
//  MeetUp
//
//  Created by Chris Duan on 16/02/16.
//  Copyright © 2016 Chris. All rights reserved.
//

import UIKit

class MainViewController: BaseViewController {    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //TODO:
        self.title = "Main"
    }
    
    override func viewWillAppear(animated: Bool) {
        
    }
    
    override func viewDidAppear(animated: Bool) {
        let user = MeetUpUserDefaults.sharedInstance.getUserFromDefaults()
        //TODO: test only nav to profile page
//        if user == nil {
//            Navigator.sharedInstance.navigateToLogin(self)
//        } else if user?.userName == "" {
//            Navigator.sharedInstance.navigateToProfilePage(self)
//        }
        
        Navigator.sharedInstance.navigateToProfilePage(self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    @IBAction func tempButton(sender: UIButton) {
        Navigator.sharedInstance.navigateToLogin(self)
        MeetUpUserDefaults.sharedInstance.removeUserDefault()
    }
}

