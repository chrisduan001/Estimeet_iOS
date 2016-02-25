//
//  ViewController.swift
//  MeetUp
//
//  Created by Chris Duan on 16/02/16.
//  Copyright © 2016 Chris. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Main"
    }
    
    override func viewWillAppear(animated: Bool) {

    }
    
    override func viewDidAppear(animated: Bool) {
        let modalVC = LoginViewController(nibName: "LoginViewController", bundle: nil)
        presentViewController(modalVC, animated: true, completion: nil)
    }
    
    
    @IBAction func startNav(sender: UIButton) {
        let modalVC = LoginViewController(nibName: "LoginViewController", bundle: nil)
        presentViewController(modalVC, animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

