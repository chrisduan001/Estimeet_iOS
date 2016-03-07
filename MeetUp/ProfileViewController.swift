//
//  ProfileViewController.swift
//  MeetUp
//
//  Created by Chris Duan on 6/03/16.
//  Copyright © 2016 Chris. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import FBSDKCoreKit

class ProfileViewController: BaseViewController, ProfileListener,UINavigationControllerDelegate, UIImagePickerControllerDelegate{

    @IBOutlet weak var imgUserDp: UIImageView!
    @IBOutlet weak var lblEnterName: UILabel!
    @IBOutlet weak var tfUserName: UITextField!
    @IBOutlet weak var btnGetStart: UIButton!
    @IBOutlet weak var lblOr: UILabel!
    @IBOutlet weak var btn_facebook: UIButton!

    var imagePicker: UIImagePickerController!
    var profileModel: ProfileModel!
    
    //MARK: LIFE CYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        
        profileModel = ProfileModel(serviceHelper: ServiceHelper.sharedInstance, userDefaults: MeetUpUserDefaults.sharedInstance, listener: self)
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
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: Selector("userDpTapped"))
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
        let imageData = UIImagePNGRepresentation(imgUserDp.image!)!
        profileModel.onStartUpdateProfile("chris", imageString: imageData.base64EncodedStringWithOptions(.Encoding64CharacterLineLength))
        startActivityIndicator()
    }
    
    @IBAction func onFacebookClicked(sender: UIButton) {
        let fbLoginManager = FBSDKLoginManager()
        if FBSDKAccessToken.currentAccessToken() != nil {
            self.getFbData()
        } else {
            fbLoginManager.logInWithReadPermissions(["public_profile"], fromViewController: self) {
                (result, error) -> Void in
                guard result.token != nil else {
                    return
                }
                self.getFbData()
            }
        }
    }
    
    //MARK: CALL BACK
    func onProfileUpdated() {
        self.dismissViewControllerAnimated(true, completion: nil)
        endActivityIndicator()
    }
    
    //MARK: IMAGE
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        imagePicker.dismissViewControllerAnimated(true, completion: nil)
        self.imgUserDp.image = info[UIImagePickerControllerOriginalImage] as? UIImage
    }
    
    //MARK: FACEBOOK
    func getFbData() {
        let graphRequest: FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me?fields=id,name", parameters: nil)
        graphRequest.startWithCompletionHandler({ (connection, result:AnyObject!, error) -> Void in
            
            if error != nil {
                
            } else {
                let id = result.valueForKey("id") as! String
                let userName = result.valueForKey("name") as! String
                
                print("id \(id), name \(userName)")
            }
        })
    }
}





