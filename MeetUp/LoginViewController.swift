//
//  LoginViewController.swift
//  MeetUp
//
//  Created by Chris Duan on 25/02/16.
//  Copyright © 2016 Chris. All rights reserved.
//

import UIKit

class LoginViewController : BaseViewController, LoginListener {
    
    @IBOutlet weak var signInButton: UIButton!
    
    private var loginModel: LoginModel!
    
    //MARK: view lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.initialize()
    }
    
    override func viewWillAppear(animated: Bool) {
        signInButton.setTitle(NSLocalizedString(GlobalString.login_SignIn, comment: "SIGN IN"), forState: .Normal)
    }
    
    func initialize() {
        self.title = NSLocalizedString(GlobalString.login_title, comment: "title login")
        loginModel = ModelFactory.sharedInstance.provideLoginModel(self)
    }

    //MARK: BUTTON ACTION
    @IBAction func onSignIn(sender: UIButton) {
        DigitsModel.onSignInClicked {
            signinAuth in
            guard signinAuth != nil else {
                return
            }
            self.startActivityIndicator()
            self.loginModel.onStartSignin(signinAuth!)
        }
    }
    
    var viewTapped = 0
    @IBAction func manualSignIn(sender: UITapGestureRecognizer) {
        viewTapped += 1
        
        if viewTapped == 5 {
            loginModel.onManualSignin()
            viewTapped = 0
        }
    }
    //MARK: CALL BACK
    func onLoginSuccess(user: User) {
        endActivityIndicator()
        
        //dialog shows before ask user for permission
        showAlert(NSLocalizedString(GlobalString.alert_title_info, comment: "Permission"),
                  message: NSLocalizedString(GlobalString.prompt_address_book, comment: "permission prompt") ,
                   buttons: [NSLocalizedString(GlobalString.alert_button_ok, comment: "ok button")],
              onOkClicked:{ (alert: UIAlertAction!) in
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)) {
                    self.startActivityIndicator()
                    self.loginModel.sendContactList(ContactListModel().getContactList())
                    
                    dispatch_async(dispatch_get_main_queue()) {
                        self.endActivityIndicator()
                        
                        if user.userName != nil && !user.userName!.isEmpty {
                            //go to main page
                            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                            appDelegate.setMainRootViewController()
                            self.dismissViewControllerAnimated(true, completion: nil)
                            return
                        }
                
                        Navigator.sharedInstance.navigateToProfilePage(self)
                    }
                }
                
        },
              onSecondButtonClicked: nil)
    }
}