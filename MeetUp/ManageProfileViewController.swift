//
//  ManageProfileViewController.swift
//  MeetUp
//
//  Created by Chris Duan on 25/04/16.
//  Copyright © 2016 Chris. All rights reserved.
//

import UIKit

class ManageProfileViewController: BaseViewController {
    @IBOutlet weak var userDp: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var lblId: UILabel!
    @IBOutlet weak var userIdString: UILabel!
    @IBOutlet weak var lblMobile: UILabel!
    @IBOutlet weak var userMobile: UILabel!
    
    var user: User!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initialize()
    }
    
    func initialize() {
        let model = ModelFactory.sharedInstance.provideManageProfileModel(self)
        
        lblName.text = NSLocalizedString(GlobalString.profile_name, comment: "Name")
        lblId.text = NSLocalizedString(GlobalString.profile_id, comment: "Id")
        lblMobile.text = NSLocalizedString(GlobalString.profile_mobile, comment: "Mobile")
        
        userName.text = user.userName
        userIdString.text = "No available at the moment"
        userMobile.text = user.phoneNumber
        
        if user.image == nil {
            ImageFactory.sharedInstance.loadImageFromUrl(userDp,
                                                         fromUrl: NSURL(string: user.dpUri!)!,
                                                     placeHolder: nil,
                                               completionHandler: { (image, error, cacheType, imageURL) in
                                                    let data = UIImagePNGRepresentation(image!)
                                                    model.saveUserImage(data!)
                                                    self.user.image = data
            })
        } else {
            userDp.image = UIImage(data: user.image!)
        }
    }
}
