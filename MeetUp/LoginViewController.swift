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
        loginModel = LoginModel(serviceHelper: ServiceHelper.sharedInstance, userDefaults: MeetUpUserDefaults.sharedInstance, listener: self)
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
    
    //MARK: CALL BACK
    func onLoginSuccess(user: User) {
        endActivityIndicator()
        
        showAlert(NSLocalizedString(GlobalString.alert_title_info, comment: "Permission"),
            message: NSLocalizedString(GlobalString.prompt_address_book, comment: "permission prompt") ,
            button: NSLocalizedString(GlobalString.alert_button_ok, comment: "ok button"))
        ContactListModel().getContactList()
        
//        guard let name = user.userName where name.isEmpty else {
//            self.dismissViewControllerAnimated(true, completion: nil)
//            return
//        }

//        Navigator.sharedInstance.navigateToProfilePage(self)
//        dismissViewControllerAnimated(true, completion: nil)
    }
}