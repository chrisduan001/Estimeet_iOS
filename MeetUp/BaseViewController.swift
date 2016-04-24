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
        //TODO: SET UP PROPER LOGOUT
        Navigator.sharedInstance.navigateToLogin(self)
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
    
    func showAlert(title: String, message: String, button: String, onOkClicked: (UIAlertAction) -> Void) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: button, style: UIAlertActionStyle.Default, handler: onOkClicked))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    //MARK: LISTENER
    func onAuthFail() {
        endActivityIndicator()
        showAlert("Auth Error", message: "Auth error", button: "ok", onOkClicked: {_ in})
        self.logOut()
    }
    
    func onError(message: String) {
        endActivityIndicator()
        showAlert(NSLocalizedString(GlobalString.alert_title_error, comment: "error title"),
                                            message: message,
                                             button: NSLocalizedString(GlobalString.alert_button_ok, comment: "error button"),
                                             onOkClicked: {_ in })
    }
}