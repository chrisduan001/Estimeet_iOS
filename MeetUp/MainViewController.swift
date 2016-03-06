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
        if user == nil {
            let modalVC = LoginViewController(nibName: "LoginViewController", bundle: nil)
            presentViewController(modalVC, animated: true, completion: nil)
        } else if user?.userName == "" {
            let modalVc = ProfileViewController(nibName: "ProfileViewController", bundle: nil)
            presentViewController(modalVc, animated: true, completion: nil)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    @IBAction func tempButton(sender: UIButton) {
        let modalVC = LoginViewController(nibName: "LoginViewController", bundle: nil)
        presentViewController(modalVC, animated: true, completion: nil)
        MeetUpUserDefaults.sharedInstance.removeUserDefault()
    }
}

