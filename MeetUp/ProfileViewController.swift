//
//  ProfileViewController.swift
//  MeetUp
//
//  Created by Chris Duan on 6/03/16.
//  Copyright © 2016 Chris. All rights reserved.
//

import UIKit

class ProfileViewController: BaseViewController, ProfileListener, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

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
        
        profileModel = ProfileModel(serviceHelper: ServiceHelper.sharedInstance, listener: self)
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
//        self.dismissViewControllerAnimated(true, completion: nil)
        profileModel.onStartUpdateProfile("", imageString: "")
    }
    
    @IBAction func onFacebookClicked(sender: UIButton) {
    }
    
    //MARK: CALL BACK
    func onProfileUpdated() {
        
    }
    
    //MARK: IMAGE
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        imagePicker.dismissViewControllerAnimated(true, completion: nil)
        self.imgUserDp.image = info[UIImagePickerControllerOriginalImage] as? UIImage
    }
}





