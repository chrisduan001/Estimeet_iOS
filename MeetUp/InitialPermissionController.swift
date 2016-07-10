//
//  InitialPermissionViewController.swift
//  MeetUp
//
//  Created by Chris Duan on 10/07/16.
//  Copyright © 2016 Chris. All rights reserved.
//

import UIKit

class InitialPermissionController: BaseViewController, LoginListener {
    @IBOutlet weak var contactBookLbl: UILabel!
    @IBOutlet weak var contactTopLbl: UILabel!
    @IBOutlet weak var contactBottomLbl: UILabel!
    @IBOutlet weak var grantPermissionBtn: RoundButton!
    @IBOutlet weak var permissionDesLbl: UILabel!
    
    private var loginModel: LoginModel!

    override func viewDidLoad() {
        super.viewDidLoad()

        contactBookLbl.text = NSLocalizedString(GlobalString.perm_contact_book, comment: "Contact Book")
        contactTopLbl.text = NSLocalizedString(GlobalString.perm_contact_top_lbl, comment: "Top label")
        contactBottomLbl.text = NSLocalizedString(GlobalString.perm_contact_btn_lbl, comment: "Bottom label")
        grantPermissionBtn.setTitle(NSLocalizedString(GlobalString.perm_btn, comment: "Button label"), forState: .Normal)
        permissionDesLbl.text = NSLocalizedString(GlobalString.perm_des_lbl, comment: "Bottom description")
        
        loginModel = ModelFactory.sharedInstance.provideLoginModel(self)
    }
    
    @IBAction func onGrantPermission(sender: UIButton) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)) {
            self.startActivityIndicator()
            self.loginModel.sendContactList(ContactListModel().getContactList())
            
            dispatch_async(dispatch_get_main_queue()) {
                self.endActivityIndicator()
                Navigator.sharedInstance.navigateToProfilePage(self)
            }
        }
    }
    
    func setUser(user: User) {
        NSException(name: "Method not implemented", reason: "", userInfo: nil).raise()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
