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
    @IBOutlet weak var iosTesterView: UIView!
    @IBOutlet weak var testerName: UITextField!
    @IBOutlet weak var testerPassword: UITextField!
    
    private var loginModel: LoginModel!
    
    //MARK: view lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        iosTesterView.hidden = true
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
        
        if viewTapped >= 10 {
            iosTesterView.hidden = false
            viewTapped = 0
        }
    }
    
    @IBAction func onTesterSignIn(sender: UIButton) {
        if let name = testerName.text, password = testerPassword.text {
            loginModel.onManualSignin(name, password: password)
        }
    }
    
    //MARK: CALL BACK
    func setUser(user: User) {
        endActivityIndicator()
        
        if user.userName != nil && !user.userName!.isEmpty {
            //go to main page
            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            appDelegate.setMainRootViewController()
            self.dismissViewControllerAnimated(true, completion: nil)
            return
        }
        
        Navigator.sharedInstance.navigateToInitPermissionPage(self)
    }
}