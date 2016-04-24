//
//  ProfileViewController.swift
//  MeetUp
//
//  Created by Chris Duan on 6/03/16.
//  Copyright © 2016 Chris. All rights reserved.
//

import UIKit
import Kingfisher

class ProfileViewController: BaseViewController, ProfileListener, FriendListListener, FbCallbackListener, UINavigationControllerDelegate, UIImagePickerControllerDelegate{

    @IBOutlet weak var imgUserDp: UIImageView!
    @IBOutlet weak var lblEnterName: UILabel!
    @IBOutlet weak var tfUserName: UITextField!
    @IBOutlet weak var btnGetStart: UIButton!
    @IBOutlet weak var lblOr: UILabel!
    @IBOutlet weak var btn_facebook: UIButton!

    var imagePicker: UIImagePickerController!
    
    //MARK: LIFE CYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpLabelDisplay()
        setUpImageAction()
    }

    func setUpLabelDisplay() {
        self.lblEnterName.text = NSLocalizedString(GlobalString.profile_enter_name, comment: "enter name")
        self.btnGetStart.setTitle(NSLocalizedString(GlobalString.profile_btn_start, comment: "start button"), forState: .Normal)
        self.btn_facebook.setTitle(NSLocalizedString(GlobalString.profile_facebook, comment: "facebook"), forState: .Normal)
        self.lblOr.text = NSLocalizedString(GlobalString.profile_lbl_or, comment: "label or")
    }
    
    func setUpImageAction() {
        self.imgUserDp.layer.cornerRadius = self.imgUserDp.frame.size.width / 2
        self.imgUserDp.clipsToBounds = true
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(ProfileViewController.userDpTapped))
        self.imgUserDp.addGestureRecognizer(tapRecognizer)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: BUTTON ACTION
    func userDpTapped() {
        imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .PhotoLibrary
        imagePicker.delegate = self
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func onGetStart(sender: UIButton) {
        guard let userName = tfUserName.text where !userName.isEmpty else {
            showAlert(NSLocalizedString(GlobalString.alert_title_error, comment: "alert title"),
                message: NSLocalizedString(GlobalString.error_empty_name, comment: "empty name"),
                 button: NSLocalizedString(GlobalString.alert_button_ok, comment: "error button"),
            onOkClicked: { _ in })
            return
        }
        
        let imageData = UIImagePNGRepresentation(imgUserDp.image!)!
        ModelFactory.sharedInstance.provideProfileModel(self)
            .onStartUpdateProfile(userName, imageString: imageData.base64EncodedStringWithOptions(.Encoding64CharacterLineLength))

        startActivityIndicator()
    }
    
    @IBAction func onFacebookClicked(sender: UIButton) {
        FacebookModel().onStartFacebookLogin(self, listener: self)
    }
    
    //MARK: CALL BACK
    func onProfileUpdated() {
        ModelFactory.sharedInstance.provideFriendListModel(self).getFriendList()
    }
    
    func onFacebookSuccessful(id: String, userName: String) {
        tfUserName.text = userName
        let dpUri = "https://graph.facebook.com/" + id + "/picture?type=large";
        //TODO: add placeholder image, just incase user click get start before image load
        imgUserDp.kf_setImageWithURL(NSURL(string: dpUri)!, placeholderImage: nil)
    }
    
    func onGetFriendList(listItem: ListItem<FriendEntity>?) {        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let mainVc = appDelegate.window!.rootViewController as! MainViewController
        mainVc.friendList = listItem?.items
        endActivityIndicator()
        self.view.window?.rootViewController?.dismissViewControllerAnimated(false, completion: nil)
    }
    
    //MARK: IMAGE
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        imagePicker.dismissViewControllerAnimated(true, completion: nil)
        imgUserDp.image = info[UIImagePickerControllerOriginalImage] as? UIImage
    }
}