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

    //MARK: LIFE CYCLE
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
    
    func showAlert(title: String, message: String, buttons: [String],
                   onOkClicked: (UIAlertAction) -> Void, onSecondButtonClicked: ((UIAlertAction) -> Void)?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: buttons[0], style: UIAlertActionStyle.Default, handler: onOkClicked))
        if buttons.count > 1 {
            alert.addAction(UIAlertAction(title: buttons[1], style: .Default, handler: onSecondButtonClicked))
        }
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    //MARK: LISTENER
    func onAuthFail() {
        endActivityIndicator()
        showAlert("Auth Error", message: "Auth error",
                  buttons: [NSLocalizedString(GlobalString.alert_button_ok, comment: "error button")],
                  onOkClicked: {_ in},
                  onSecondButtonClicked: nil)
        self.logOut()
    }
    
    func onError(message: String) {
        endActivityIndicator()
        showAlert(NSLocalizedString(GlobalString.alert_title_error,comment: "error title"),
                                            message: message,
                                             buttons: [NSLocalizedString(GlobalString.alert_button_ok, comment: "error button")],
                                             onOkClicked: {_ in },
                                             onSecondButtonClicked: nil)
    }
    
    //when certian permission is not enabled, need prompt user to open setting page
    func onErrorWithSettings(title: String, message: String) {
        showAlert(title,
            message: message,
            buttons: [NSLocalizedString(GlobalString.alert_button_ok, comment: "OK"),
            NSLocalizedString(GlobalString.error_setting, comment: "settings")],
            onOkClicked: {_ in },
            onSecondButtonClicked: { _ in
                guard let url = NSURL(string: UIApplicationOpenSettingsURLString) else {
                    return
                }
                
                UIApplication.sharedApplication().openURL(url)
        })
    }
}
