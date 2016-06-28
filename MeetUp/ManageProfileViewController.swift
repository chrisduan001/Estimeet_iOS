//
//  ManageProfileViewController.swift
//  MeetUp
//
//  Created by Chris Duan on 25/04/16.
//  Copyright © 2016 Chris. All rights reserved.
//

import UIKit

class ManageProfileViewController: BaseViewController, UIImagePickerControllerDelegate,
    UINavigationControllerDelegate, ProfileListener{
    @IBOutlet weak var userDp: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var lblId: UILabel!
    @IBOutlet weak var userIdString: UILabel!
    @IBOutlet weak var lblMobile: UILabel!
    @IBOutlet weak var userMobile: UILabel!
    
    var user: User!
    
    private lazy var imagePicker: UIImagePickerController = self.setupImagePicker()
    private var model: ProfileModel!
    
    //MARK: LIFE CYCLE & VIEW
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initialize()
    }
    
    func initialize() {
        model = ModelFactory.sharedInstance.provideProfileModel(self)
        
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
        
        removeSaveDpButton()
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
        imagePicker.allowsEditing = true
        imagePicker.sourceType = .PhotoLibrary
        imagePicker.delegate = self
        
        return imagePicker
    }
    
    private func addSaveDpButton() {
        let saveButtonItem:UIBarButtonItem = UIBarButtonItem(title: "Save", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(ManageProfileViewController.saveTapped))
        navigationItem.setRightBarButtonItem(saveButtonItem, animated: true)
    }
    
    private func removeSaveDpButton() {
        navigationItem.setRightBarButtonItem(nil, animated: true)
    }
    
    @objc private func saveTapped() {
        startActivityIndicator()
        model.onStartUpdateProfile(user.userName!, imageString: getImageDataEncode(), isRegister: false)
    }
    
    //MARK: DELEGATE
    func onProfileUpdated() {
        endActivityIndicator()
        removeSaveDpButton()
        model.saveUserImage(UIImagePNGRepresentation(userDp.image!)!)
    }
    
    func onResetUserProfile(user: User) {
        self.user = user
    }
    
    override func onAuthFail() {
        onUpdateProfileFailed()
    }
    
    override func onError(message: String) {
        super.onError(message)
        onUpdateProfileFailed()
    }
    
    private func onUpdateProfileFailed() {
        endActivityIndicator()
        model.resetUserProfile()
    }
    
    //MARK: OTHER LOGIC
    private func getImageDataEncode() -> String {
        let imageData = UIImagePNGRepresentation(userDp.image!)!
        print("image size: \(imageData.length / 1024))")
        return imageData.base64EncodedStringWithOptions(.Encoding64CharacterLineLength)
    }
    
    //MARK: BUTTON ACTION
    @IBAction func onDpClicked(sender: UITapGestureRecognizer) {
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    //MARK: IMAGE
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        imagePicker.dismissViewControllerAnimated(true, completion: nil)
        let image = info[UIImagePickerControllerOriginalImage] as? UIImage
//        let compress = UIImageJPEGRepresentation(image!, 0.01)
//        let compress2 = UIImageJPEGRepresentation(image!, 0.2)
//        self.userDp.image = info[UIImagePickerControllerOriginalImage] as? UIImage
        let compressed = scaleDown(image!, withSize: CGSize(width: 90, height: 90))
        let data = UIImagePNGRepresentation(compressed)
        self.userDp.image = compressed
        addSaveDpButton()
    }
    
    func scaleDown(image: UIImage, withSize: CGSize) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(withSize, true, 0.0)
        image.drawInRect(CGRectMake(0, 0, withSize.width, withSize.height))
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return scaledImage
    }
}
