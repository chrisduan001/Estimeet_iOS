//
//  ProfileViewController.swift
//  MeetUp
//
//  Created by Chris Duan on 6/03/16.
//  Copyright © 2016 Chris. All rights reserved.
//

import UIKit

class ProfileViewController: BaseViewController {

    @IBOutlet weak var imgUserDp: UIImageView!
    @IBOutlet weak var lblEnterName: UILabel!
    @IBOutlet weak var tfUserName: UITextField!
    @IBOutlet weak var btnGetStart: UIButton!
    @IBOutlet weak var lblOr: UILabel!
    @IBOutlet weak var btn_facebook: UIButton!
    
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
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: Selector("userDpTapped"))
        self.imgUserDp.addGestureRecognizer(tapRecognizer)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: BUTTON ACTION
    func userDpTapped() {

    }
}





