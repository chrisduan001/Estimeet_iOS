//
//  BaseViewController.swift
//  MeetUp
//
//  Created by Chris Duan on 3/03/16.
//  Copyright © 2016 Chris. All rights reserved.
//

import UIKit
import DigitsKit

class BaseViewController: UIViewController, BaseListener {
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func logOut() {
        Digits.sharedInstance().logOut()
    }
    
    func startActivityIndicator() {
        UIApplication.sharedApplication().beginIgnoringInteractionEvents()
        activityIndicator.startAnimating()
    }
    
    func endActivityIndicator() {
        if activityIndicator != nil && activityIndicator.isAnimating() {
            UIApplication.sharedApplication().endIgnoringInteractionEvents()
            activityIndicator.stopAnimating()
        }
    }
    
    //MARK: LISTENER
    func onAuthFail() {
        endActivityIndicator()
        self.logOut()
    }
    
    func onError(message: String) {
        endActivityIndicator()
        
        let alert = UIAlertController(title: NSLocalizedString(GlobalString.error_alert_title, comment: "error title"), message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString(GlobalString.error_alert_button, comment: "error button"), style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
}
