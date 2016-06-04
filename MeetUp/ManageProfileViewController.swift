//
//  ManageProfileViewController.swift
//  MeetUp
//
//  Created by Chris Duan on 25/04/16.
//  Copyright © 2016 Chris. All rights reserved.
//

import UIKit

class ManageProfileViewController: BaseViewController, UIImagePickerControllerDelegate,
    UINavigationControllerDelegate{
    @IBOutlet weak var userDp: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var lblId: UILabel!
    @IBOutlet weak var userIdString: UILabel!
    @IBOutlet weak var lblMobile: UILabel!
    @IBOutlet weak var userMobile: UILabel!
    
    var user: User!
    
    private lazy var imagePicker: UIImagePickerController = self.setupImagePicker()
    private var model: ManageProfileModel!
    
    //MARK: LIFE CYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initialize()
    }
    
    func initialize() {
        model = ModelFactory.sharedInstance.provideManageProfileModel(self)
        
        setUpView()
        setupUserImage()
    }
    
    private func setUpView() {
        lblName.text = NSLocalizedString(GlobalString.profile_name, comment: "Name")
        lblId.text = NSLocalizedString(GlobalString.profile_id, comment: "Id")
        lblMobile.text = NSLocalizedString(GlobalString.profile_mobile, comment: "Mobile")
        
        userName.text = user.userName
        userIdString.text = "No available at the moment"
        userMobile.text = user.phoneNumber
    }
    
    private func setupUserImage() {
        userDp.layer.cornerRadius = self.userDp.frame.size.width / 2
        userDp.clipsToBounds = true
        
        if user.image == nil {
            ImageFactory.sharedInstance.loadImageFromUrl(userDp,
                                                         fromUrl: NSURL(string: user.dpUri!)!,
                                                         placeHolder: nil,
                                                         completionHandler: { (image, error, cacheType, imageURL) in
                                                            let data = UIImagePNGRepresentation(image!)
                                                            self.model.saveUserImage(data!)
                                                            self.user.image = data
            })
        } else {
            userDp.image = UIImage(data: user.image!)
        }
    }
    
    private func setupImagePicker() -> UIImagePickerController {
        let imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .PhotoLibrary
        imagePicker.delegate = self
        
        return imagePicker
    }
    
    //MARK: OTHER LOGIC
    private func getImageDataEncode() -> String {
        let imageData = UIImagePNGRepresentation(userDp.image!)!
        return imageData.base64EncodedStringWithOptions(.Encoding64CharacterLineLength)
    }
    
    //MARK: BUTTON ACTION
    @IBAction func onDpClicked(sender: UITapGestureRecognizer) {
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    //MARK: IMAGE
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        imagePicker.dismissViewControllerAnimated(true, completion: nil)
        userDp.image = info[UIImagePickerControllerOriginalImage] as? UIImage
    }
}
