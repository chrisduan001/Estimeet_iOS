//
//  ProfileViewController.swift
//  MeetUp
//
//  Created by Chris Duan on 6/03/16.
//  Copyright © 2016 Chris. All rights reserved.
//

import UIKit
import Kingfisher

class ProfileViewController: DpBaseViewController, ProfileListener, FriendListListener, FbCallbackListener {

    @IBOutlet weak var lblEnterName: UILabel!
    @IBOutlet weak var tfUserName: UITextField!
    @IBOutlet weak var btnGetStart: UIButton!
    @IBOutlet weak var lblOr: UILabel!
    @IBOutlet weak var btn_facebook: UIButton!

    //MARK: LIFE CYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        
        isRegisterController = true
        setUpLabelDisplay()
    }

    func setUpLabelDisplay() {
        self.lblEnterName.text = NSLocalizedString(GlobalString.profile_enter_name, comment: "enter name")
        self.btnGetStart.setTitle(NSLocalizedString(GlobalString.profile_btn_start, comment: "start button"), forState: .Normal)
        self.btn_facebook.setTitle(NSLocalizedString(GlobalString.profile_facebook, comment: "facebook"), forState: .Normal)
        self.lblOr.text = NSLocalizedString(GlobalString.profile_lbl_or, comment: "label or")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: BUTTON ACTION

    @IBAction func onGetStart(sender: UIButton) {
        guard let userName = tfUserName.text where !userName.isEmpty else {
            showAlert(NSLocalizedString(GlobalString.alert_title_error, comment: "alert title"),
                message: NSLocalizedString(GlobalString.error_empty_name, comment: "empty name"),
                 buttons: [NSLocalizedString(GlobalString.alert_button_ok, comment: "error button")],
            onOkClicked: { _ in },
            onSecondButtonClicked: nil)
            return
        }
        
        ModelFactory.sharedInstance.provideProfileModel(self)
            .onStartUpdateProfile(userName, imageString: getImageDataEncode(), isRegister: true)

        startActivityIndicator()
    }
    
    @IBAction func onFacebookClicked(sender: UIButton) {
        FacebookModel().onStartFacebookLogin(self, listener: self)
    }
    
    //MARK: CALL BACK
    func onProfileUpdated() {
        ModelFactory.sharedInstance.provideFriendListModel(self).getFriendList()
    }
    
    func onResetUserProfile(user: User) {
        //method not implemented
    }
    
    func onFacebookSuccessful(id: String, userName: String) {
        tfUserName.text = userName
        let dpUri = "https://graph.facebook.com/" + id + "/picture?type=large";
        //TODO: add placeholder image, just incase user click get start before image load
        imgUserDp.kf_setImageWithURL(NSURL(string: dpUri)!, placeholderImage: nil)
    }
    
    func onGetFriendList(friends: [FriendEntity]?) {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let mainVc = appDelegate.window!.rootViewController as! MainViewController
        mainVc.isAnyFriends = friends != nil && friends?.count > 0
        mainVc.user = MeetUpUserDefaults.sharedInstance.getUserFromDefaults()
        endActivityIndicator()
        self.view.window?.rootViewController?.dismissViewControllerAnimated(false, completion: nil)
    }
    
    func setFriendFetchedResultsController(fetchedResultsController: NSFetchedResultsController) {
        NSException(name: "Not implement exception", reason: "This method has to be implemented", userInfo: nil).raise()
    }
}