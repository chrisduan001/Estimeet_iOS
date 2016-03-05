//
//  LoginViewController.swift
//  MeetUp
//
//  Created by Chris Duan on 25/02/16.
//  Copyright © 2016 Chris. All rights reserved.
//

import UIKit

class LoginViewController : BaseViewController, ServiceListener {
    
    @IBOutlet weak var signInButton: UIButton!
    
    private var loginModel: LoginModel!
    
    //MARK: view lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.initialize()
    }
    
    override func viewWillAppear(animated: Bool) {
        signInButton.setTitle(NSLocalizedString("Login_Signin", comment: "SIGN IN"), forState: .Normal)
    }
    
    func initialize() {
        self.title = NSLocalizedString("Login_title", comment: "title login")
        loginModel = LoginModel(serviceHelper: ServiceHelper.sharedInstance, listener: self)
    }

    //MARK: BUTTON ACTION
    @IBAction func onSignIn(sender: UIButton) {
        DigitsModel.onSignInClicked()
    }
    
    //MARK: CALL BACK
    func onGetSampleData(user: User) {
        print(user.userName)
        print(user.userId)

    }
    
    func onError(message: String) {
        
    }
}