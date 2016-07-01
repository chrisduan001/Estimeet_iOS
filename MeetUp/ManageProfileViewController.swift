//
//  ManageProfileViewController.swift
//  MeetUp
//
//  Created by Chris Duan on 25/04/16.
//  Copyright © 2016 Chris. All rights reserved.
//

import UIKit

class ManageProfileViewController: DpBaseViewController, ProfileListener{
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var lblId: UILabel!
    @IBOutlet weak var userIdString: UILabel!
    @IBOutlet weak var lblMobile: UILabel!
    @IBOutlet weak var userMobile: UILabel!
    
    var user: User?
    
    private var model: ProfileModel!
    
    //MARK: LIFE CYCLE & VIEW
    override func viewDidLoad() {
        super.viewDidLoad()
        
        isRegisterController = false
        initialize()
    }
    
    func initialize() {
        model = ModelFactory.sharedInstance.provideProfileModel(self)
        
        if user == nil {
            model.getUserFromLocalStorage()
        }
        setUpView()
        setupUserImage()
    }
    
    private func setUpView() {
        lblName.text = NSLocalizedString(GlobalString.profile_name, comment: "Name")
        lblId.text = NSLocalizedString(GlobalString.profile_id, comment: "Id")
        lblMobile.text = NSLocalizedString(GlobalString.profile_mobile, comment: "Mobile")
        
        userName.text = user!.userName
        userIdString.text = "No available at the moment"
        userMobile.text = user!.phoneNumber
        
        removeSaveDpButton()
    }
    
    private func setupUserImage() {
        if user!.image == nil {
            ImageFactory.sharedInstance.loadImageFromUrl(imgUserDp,
                                                         fromUrl: NSURL(string: user!.dpUri!)!,
                                                         placeHolder: nil,
                                                         completionHandler: { (image, error, cacheType, imageURL) in
                                                            let data = UIImagePNGRepresentation(image!)
                                                            self.model.saveUserImage(data!)
                                                            self.user!.image = data
            })
        } else {
            imgUserDp.image = UIImage(data: user!.image!)
        }
    }
    
    private func removeSaveDpButton() {
        navigationItem.setRightBarButtonItem(nil, animated: true)
    }
    
    func saveTapped() {
        startActivityIndicator()
        model.onStartUpdateProfile(user!.userName!, imageString: getImageDataEncode(), isRegister: false)
    }
    
    //MARK: DELEGATE
    func onProfileUpdated() {
        endActivityIndicator()
        removeSaveDpButton()
        model.saveUserImage(UIImagePNGRepresentation(imgUserDp.image!)!)
    }
    
    func onReterieveUser(user: User) {
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
        model.getUserFromLocalStorage()
    }
}
